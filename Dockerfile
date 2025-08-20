# --- Stage 1: Build DuckDB binary with Nix ---
FROM nixos/nix:latest AS builder

WORKDIR /build
COPY . .
# Build our Nix environment
RUN nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    build

# Copy the full Nix store closure for duckdb
RUN mkdir -p /tmp/nix-store-closure && \
    cp -R $(nix-store -qR result/) /tmp/nix-store-closure && \
    DDB_PATH=$(readlink -f result/bin/duckdb) && \
    mkdir -p /tmp/bin && \
    ln -s "$DDB_PATH" /tmp/bin/duckdb

# --- Stage 2: Minimal SCRATCH image with DuckDB binary and all dependencies ---
FROM scratch
# Copy the full Nix store closure
COPY --from=builder /tmp/nix-store-closure /nix/store
# Copy the /bin/duckdb symlink
COPY --from=builder /tmp/bin/duckdb /bin/duckdb

ENTRYPOINT ["/bin/duckdb"]
CMD ["--help"]