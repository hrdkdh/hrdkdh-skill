# WSL and Docker recovery

Use this reference when Docker builds on Windows through WSL2 fail unexpectedly.

## Distinguish the failure layer

1. Check `wsl --status` and `wsl -l -v`.
2. Confirm the selected distribution exists and is WSL2.
3. Inside that distribution, separately check:
   - `uname -m` is `x86_64` for an amd64 build host;
   - `docker version` returns both Client and Server sections;
   - `docker info` reports Linux and a usable storage driver;
   - `docker build --help` includes the required BuildKit options such as `--secret`.
4. Prove the daemon with a real container run when the environment is healthy; CLI installation alone is insufficient.

Run WSL commands from an ASCII-only Windows working directory such as `C:\` and pass the Linux build-context path explicitly. This avoids adding path-translation ambiguity when the repository path contains non-ASCII characters.

For recovery helpers, also use an ASCII-only Windows directory and set `WSL_UTF8=1`. Prefer `Start-Process` with `wsl.exe --exec` and file-based stdout/stderr redirection over a long PowerShell pipeline. Do not embed a Korean or other non-ASCII project path in a generated Linux helper script. If discovery inside WSL is necessary, constrain the glob to the known parent and repository name, require exactly one match, and record the resolved path before building.

## Relay failure signature

Treat these together as a WSL control-plane failure rather than an application build failure:

- Windows observes WSL exit code `-1`;
- stdout/stderr is missing or truncated;
- the WSL journal reports `ExpectedMessage LxInitMessageExitStatus, but socket Control was closed`;
- BuildKit reports `context canceled` immediately after the Windows-side client disappears;
- `wsl --system` can see `dockerd`, but ordinary distribution commands fail.

An exit code of `-1` can mean that the Windows-side output/control relay failed even though the distribution, Docker Engine, or a detached command is still healthy. Check Linux-side log and status files plus daemon state before restarting anything. A command writing fresh progress to a mounted project log is stronger evidence than the missing Windows console output.

`wsl --system` plus `nsenter` is useful for collecting process, journal, and daemon evidence. It is not a reliable production build path: it may not keep the user distribution alive, and losing the client cancels BuildKit during layer export.

## Bounded launch and detached build

1. Set `WSL_UTF8=1` and create one task-specific helper directory under an ASCII-only Windows path.
2. Invoke a short probe such as `/bin/true` through `Start-Process`, `--exec`, and redirected output files. Retry only a small fixed number of times. Do not use a full image build as the probe.
3. Once probes succeed, start the real build inside the distribution with a uniquely named transient `systemd-run` unit. Make the Linux command write a build log and a machine-readable exit-status file to the Windows-mounted project. This lets Windows verify progress without depending on the original output relay.
4. Poll the status file, unit state, log modification time, and image existence until a fixed deadline. Treat a stale log plus an inactive/failed unit as a failure; do not infer success from a disconnected launcher.

`systemd-run` detaches the build from one `wsl.exe` client, but it does not by itself guarantee that the WSL VM remains alive. A single long `/bin/sleep` command also may not provide a reliable keepalive. If the build repeatedly stops only when no short WSL client is active, use a bounded Windows pulse loop that launches `/bin/true` about every 0.5-1 second. Keep it active through layer export and `docker save`, then stop it explicitly. Give both the pulse loop and the overall build a deadline so a wedged relay cannot run forever.

On one proven host, the progression was:

1. no keepalive: WSL stopped during `microdnf`;
2. one long sleep: WSL stopped during `exporting layers`;
3. short pulse keepalive after one controlled WSL restart: build, container verification, and `docker save` completed.

Treat this as a diagnostic pattern, not a requirement on every machine. Prefer an ordinary foreground build whenever the relay remains stable.

## Recovery order

1. Preserve the exact failure text and confirm whether any other WSL workloads are active.
2. Run bounded short-command probes from the ASCII-only helper directory, optionally with `--cd /`.
3. If a helper process wedges, stop only the exact PID created for that helper. Recheck other distributions and WSL workloads.
4. If safe for all running WSL workloads, run `wsl --shutdown` once, restart the pulse if it is needed, and relaunch the detached operation once.
5. Check WSL service state, relevant journal entries, free disk space, Docker daemon logs, and the Linux-side build status.
6. Stop after repeated identical control-socket failures. Ask the user to restart Windows or authorize a WSL service repair/update before further mutation.

Do not repeatedly restart services, kill WSL processes, or create large distribution clones without a clear cleanup plan.

## Docker Desktop alternative

Docker Desktop with a Hyper-V Linux backend can be a valid fallback when it is installed, licensed for the organization, and authorized by local policy. Do not infer that it is installed or usable merely because Docker lists a `desktop-linux` context. Confirm the application, backend, daemon connectivity, and target architecture. A working WSL-hosted Docker Engine remains sufficient; on the host that produced the pulse-keepalive evidence, Docker Desktop was absent and the WSL Engine completed the image.

## Temporary distribution rules

- Prefer `wsl --export` followed by `wsl --import` so the imported filesystem receives an independent identity.
- Do not register a raw copy of an ext4 VHD with `--import-in-place` unless its filesystem UUID has been made unique while unmounted. Duplicate UUIDs can make mount and diagnosis results ambiguous.
- Keep temporary distribution names and paths explicit.
- Before unregistering, confirm the registry entry and resolved base path match the intended temporary target.
- `wsl --unregister` deletes that distribution's filesystem. Never run it against the user's working distribution.
- Clean only artifacts created by the task. Prefer recoverable deletion for large temporary exports when practical.

## Completion boundary

A successful dependency-install log is not a successful image build. Completion requires all of the following:

1. build command exits successfully;
2. the tagged image exists;
3. OS and architecture are inspected;
4. a real container starts and its health endpoint responds;
5. the exported TAR exists and has a recorded checksum.

Keep the pulse alive through the final `docker save` when it was required for the build. After verification, stop only the exact helper PID and transient unit created by the task, then remove only that task's temporary helper directory.
