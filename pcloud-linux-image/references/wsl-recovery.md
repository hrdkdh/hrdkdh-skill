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

## Relay failure signature

Treat these together as a WSL control-plane failure rather than an application build failure:

- Windows observes WSL exit code `-1`;
- stdout/stderr is missing or truncated;
- the WSL journal reports `ExpectedMessage LxInitMessageExitStatus, but socket Control was closed`;
- BuildKit reports `context canceled` immediately after the Windows-side client disappears;
- `wsl --system` can see `dockerd`, but ordinary distribution commands fail.

`wsl --system` plus `nsenter` is useful for collecting process, journal, and daemon evidence. It is not a reliable production build path: it may not keep the user distribution alive, and losing the client cancels BuildKit during layer export.

## Recovery order

1. Preserve the exact failure text and confirm whether any other WSL workloads are active.
2. Retry one short command from `C:\`, optionally with `--cd /`.
3. If safe for all running WSL workloads, run `wsl --shutdown` once and retry.
4. Check WSL service state, relevant journal entries, free disk space, and Docker daemon logs.
5. Stop after repeated identical control-socket failures. Ask the user to restart Windows or authorize a WSL service repair/update before further mutation.

Do not repeatedly restart services, kill WSL processes, or create large distribution clones without a clear cleanup plan.

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
