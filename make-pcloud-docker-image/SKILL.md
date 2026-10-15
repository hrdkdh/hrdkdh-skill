---
name: make-pcloud-docker-image
description: Build, verify, and export Linux amd64 Docker images for P-Cloud from a corporate Windows PC, including WSL Docker checks, internal CA handling, runtime environment variables, ports, volumes, outbound hosts, and TAR evidence. Use for P-Cloud container packaging or when a Windows/WSL Docker build fails before image export. Do not use for ordinary local development that does not involve container delivery.
---

# Make P-Cloud Docker Image

Produce a deployable artifact and evidence, not merely a plausible Dockerfile.

## Workflow

1. Inspect the repository before editing:
   - Read repository instructions and preserve unrelated changes.
   - Identify the application entrypoint, required runtime files, writable paths, health endpoint, listening port, and external integrations.
   - Search for hard-coded credentials, URLs, model names, ports, filesystem paths, debug switches, and proxy settings.
2. Separate configuration classes:
   - Put secrets such as API keys and certificate passwords in runtime environment variables or the platform secret store.
   - Put environment-dependent non-secrets such as API base URLs, model IDs, ports, and public URLs in runtime environment variables.
   - Keep stable application defaults in code only when they are safe across environments.
   - Ensure process environment values override any local `.env`; ignore `.env` and include a placeholder-only `.env.example`.
3. Build a Linux image appropriate for the target:
   - Prefer the requested RHEL-family base; use Rocky Linux when P-Cloud compatibility calls for it.
   - Set the platform explicitly to `linux/amd64` unless the target says otherwise.
   - Use a multi-stage build and a non-root runtime user.
   - Copy only runtime files. Exclude `.git`, `.env`, databases, logs, local virtual environments, build outputs, and development artifacts with `.dockerignore`.
   - Add a health check that exercises the local application without requiring upstream LLM or LP connectivity.
4. Run the read-only preflight script before a substantial build:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/docker_preflight.ps1 `
     -ProjectPath <repository> -Distro Ubuntu-24.04
   ```

   Run the script from this skill's directory or use its absolute path. Treat Docker CLI presence and Docker daemon connectivity as separate checks.
5. Build and preserve complete evidence:

   ```powershell
   wsl -d Ubuntu-24.04 -u root -- docker build `
     --platform linux/amd64 `
     --progress plain `
     -t <image>:<tag> `
     <wsl-repository-path>
   ```

   If a corporate CA is required, read [references/corporate-ca.md](references/corporate-ca.md) before changing the Dockerfile or build command.
6. Verify before export:
   - `docker image inspect` must show `linux/amd64`.
   - Start a real container with representative non-secret settings.
   - Confirm the container is running and healthy, query the health endpoint, inspect non-secret effective configuration, and inspect logs.
   - When practical, verify one real upstream operation. An HTTP 401 proves routing only, not authentication or application success.
7. Export and verify the deliverable:

   ```powershell
   wsl -d Ubuntu-24.04 -u root -- docker save `
     -o <wsl-output-path>/<image>-<tag>-linux-amd64.tar `
     <image>:<tag>
   Get-FileHash <windows-output-path> -Algorithm SHA256
   ```

   Report the absolute artifact path, size, SHA-256, image ID, OS/architecture, health result, and test results. Do not say the image is complete if the build stopped during `exporting layers`, the image cannot be inspected, or the TAR is absent.

## P-Cloud handoff

Document these values for the operator:

- container port and P-Cloud-assigned host/NAT port;
- health-check path;
- required and optional environment variables, with secrets marked for the platform secret store;
- persistent volume mount paths and single-replica limitations;
- outbound hostnames, protocols, and ports;
- Extra Hosts only when internal DNS cannot resolve a required hostname;
- restart policy, entrypoint/command, and proxy-header trust settings;
- whether a public base URL is required for generated links.

Never treat Extra Hosts as an API endpoint setting: it changes name resolution only. Keep the endpoint environment variable explicit.

## WSL failure handling

If `wsl.exe` returns `-1`, produces no useful output, shows `ExpectedMessage LxInitMessageExitStatus`, or a build ends with `context canceled`, stop treating it as a Dockerfile failure. Read [references/wsl-recovery.md](references/wsl-recovery.md), preserve the exact error evidence, and avoid repeated builds until the WSL control path is healthy.
