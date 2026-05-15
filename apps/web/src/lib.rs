use std::path::PathBuf;

use axum::{http::StatusCode, response::Html, routing::get, Json, Router};
use serde::Serialize;
use tower_http::{services::ServeDir, trace::TraceLayer};

const INDEX_HTML: &str = include_str!("../public/index.html");
const TOOLS_HTML: &str = include_str!("../public/tools.html");

#[derive(Serialize)]
struct ApiIndex {
    name: &'static str,
    endpoints: [&'static str; 2],
}

#[derive(Serialize)]
struct ApiStatus {
    status: &'static str,
    service: &'static str,
}

pub fn app() -> Router {
    Router::new()
        .route("/", get(index))
        .route("/tools", get(tools))
        .route("/api", get(api_index))
        .route("/api/status", get(api_status))
        .route("/health", get(health))
        .nest_service("/assets", ServeDir::new(assets_dir()))
        .layer(TraceLayer::new_for_http())
}

fn assets_dir() -> PathBuf {
    std::env::var_os("STATIC_ASSETS_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(concat!(env!("CARGO_MANIFEST_DIR"), "/public/assets")))
}

async fn index() -> Html<&'static str> {
    Html(INDEX_HTML)
}

async fn tools() -> Html<&'static str> {
    Html(TOOLS_HTML)
}

async fn api_index() -> Json<ApiIndex> {
    Json(ApiIndex {
        name: "timnormark.com API",
        endpoints: ["/api/status", "/health"],
    })
}

async fn api_status() -> Json<ApiStatus> {
    Json(ApiStatus {
        status: "ok",
        service: "timnormark-web",
    })
}

async fn health() -> StatusCode {
    StatusCode::NO_CONTENT
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::{body::Body, http::Request};
    use http_body_util::BodyExt;
    use tower::ServiceExt;

    #[tokio::test]
    async fn serves_landing_page() {
        let response = app()
            .oneshot(Request::builder().uri("/").body(Body::empty()).unwrap())
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body = std::str::from_utf8(&body).unwrap();
        assert!(body.contains("Tim Normark"));
    }

    #[tokio::test]
    async fn serves_tools_page() {
        let response = app()
            .oneshot(
                Request::builder()
                    .uri("/tools")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body = std::str::from_utf8(&body).unwrap();
        assert!(body.contains("Tools"));
    }

    #[tokio::test]
    async fn health_returns_no_content() {
        let response = app()
            .oneshot(
                Request::builder()
                    .uri("/health")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::NO_CONTENT);
    }

    #[tokio::test]
    async fn api_status_returns_json() {
        let response = app()
            .oneshot(
                Request::builder()
                    .uri("/api/status")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let payload: serde_json::Value = serde_json::from_slice(&body).unwrap();
        assert_eq!(payload["status"], "ok");
        assert_eq!(payload["service"], "timnormark-web");
    }
}
