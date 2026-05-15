FROM rust:1.87-slim AS builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY apps ./apps
RUN cargo build --release -p timnormark-web

FROM debian:bookworm-slim AS runtime

RUN useradd --create-home --shell /usr/sbin/nologin app
WORKDIR /app
COPY --from=builder /app/target/release/timnormark-web /usr/local/bin/timnormark-web
COPY apps/web/public ./apps/web/public
USER app

ENV PORT=3000
EXPOSE 3000

CMD ["timnormark-web"]
