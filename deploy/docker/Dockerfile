# syntax=docker/dockerfile:1
# Build from the repo root: docker build -f deploy/docker/Dockerfile .
#
# Two stages: `build` compiles/bundles your app into /out, `runtime` ships only /out.
# Swap the base images and commands for your stack; keep the structure.

# ---- build ----------------------------------------------------------------
FROM alpine:3.24 AS build
WORKDIR /src

# Copy dependency manifests first and install them here, so the layer caches.
COPY . .

# ponytail: placeholder build writes a static page so the stack runs out of the box.
# Replace with your build command, writing artifacts to /out.
RUN mkdir -p /out && echo "ok" > /out/index.html

# ---- runtime --------------------------------------------------------------
# Pick the smallest base that runs your artifact (distroless, a language runtime, nginx, scratch...).
FROM busybox:1.37 AS runtime
WORKDIR /app
COPY --from=build /out/ ./

# Run as an unprivileged user (65534 = nobody).
USER 65534:65534

ENV PORT=8080
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q --spider "http://127.0.0.1:${PORT}/" || exit 1

# Replace with your app's entrypoint.
CMD ["httpd", "-f", "-p", "8080", "-h", "/app"]
