FROM ghcr.io/gleam-lang/gleam:v1.8.1-erlang-slim AS builder

WORKDIR /build

COPY *.toml .
RUN gleam deps download

COPY . .
RUN gleam export erlang-shipment

FROM erlang:alpine

WORKDIR /app
COPY --from=builder /build/build/erlang-shipment /app
ENTRYPOINT [ "./entrypoint.sh", "run" ]
