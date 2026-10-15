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
