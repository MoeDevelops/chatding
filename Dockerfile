FROM alpine:edge
LABEL org.opencontainers.image.source=https://github.com/MoeDevelops/chatding

# Install packages
RUN apk update && \
    apk add gleam rebar3 erlang

# Build project
WORKDIR /build
COPY . .
RUN gleam deps download && \
    gleam export erlang-shipment && \
    mv /build/build/erlang-shipment /app

# Clean up
RUN rm -rf /build
RUN apk del gleam rebar3 && \
    apk cache clean

# Start container
WORKDIR /app
EXPOSE 5001
ENTRYPOINT [ "./entrypoint.sh", "run" ]
