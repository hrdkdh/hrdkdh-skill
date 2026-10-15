# Corporate CA handling

Use this reference only when image pulls, OS package installation, or Python package installation fails with a corporate TLS inspection certificate error.

## Diagnosis

Identify the failing layer before changing TLS behavior:

- host or WSL cannot reach the registry;
- Docker can pull the base image, but `microdnf` or `dnf` fails inside Rocky;
- OS packages install, but `pip` fails;
- the certificate is untrusted; or
- Rocky/OpenSSL reports `CA certificate key too weak`.

Do not disable certificate verification globally. Do not bake a private CA or authenticated mirror URL into the image.

## BuildKit secret pattern

Pass the CA as a secret so it does not enter the build context:

```powershell
docker build --platform linux/amd64 `
  --secret id=corporate_ca,src=<CA-file-visible-to-Docker> `
  -t <image>:<tag> .
```

Use a secret mount in the package-installing `RUN` instruction:

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=secret,id=corporate_ca,required=false \
    if [ -f /run/secrets/corporate_ca ]; then \
        cp /run/secrets/corporate_ca /etc/pki/ca-trust/source/anchors/corporate-ca.crt \
        && update-ca-trust; \
    fi \
    && microdnf install -y <packages> \
    && microdnf clean all \
    && rm -f /etc/pki/ca-trust/source/anchors/corporate-ca.crt \
    && update-ca-trust
```

If Rocky rejects a legacy corporate CA with `CA certificate key too weak`, confirm the active OpenSSL crypto-policy files first. Rocky 9 images may reference both:

```text
/etc/crypto-policies/back-ends/opensslcnf.config
/etc/crypto-policies/back-ends/openssl.config
```

Lower `@SECLEVEL` only for the package download transaction. In the final runtime stage, back up both files before relaxation and restore both in the same `RUN` instruction after package installation. Remove the temporary CA anchor and regenerate trust before the layer completes. A builder stage may remain relaxed only if it is discarded and no builder filesystem is copied except intended artifacts such as wheels.

After building, verify the runtime image contains neither the temporary CA file nor a weakened `SECLEVEL`. Do not infer this merely from multi-stage structure; inspect the final image.

## Offline wheelhouse alternative

Use an offline wheelhouse when policy prohibits even a temporary OpenSSL security-level change, or when Windows can validate the corporate TLS chain but the Rocky build stage cannot.

1. From a trusted Windows Python environment, download the complete dependency set while normal certificate verification uses the Windows trust store.
2. Target the container explicitly: Linux, amd64, the image's Python implementation/version/ABI, and a manylinux tag compatible with the Rocky release. Use binary wheels only unless a separately reviewed Linux build environment produces the missing wheel.
3. Verify that every transitive dependency is present and that no Windows wheel was selected. Preserve hashes or an approved lock file when available.
4. Make the wheelhouse available only to the builder, then install with `pip --no-index --find-links=<wheelhouse>`. Copy only the installed environment or intended artifacts into the final runtime stage.
5. Confirm the wheelhouse, download credentials, and temporary CA files are excluded from the runtime image and deployment TAR unless policy explicitly requires otherwise.

Do not assume a wheel downloaded on Windows is suitable merely because `pip download` succeeded. Validate tags against the target Python ABI and platform, then start a real Linux container and import the packages that include native extensions.
