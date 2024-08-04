use axum::{
    http::StatusCode,
    routing::{get, post},
    Json, Router,
};
use serde::Deserialize;

#[tokio::main]
async fn main() {
    // initialize tracing
    tracing_subscriber::fmt::init();

    // build our application with a route
    let app = Router::new()
        .route("/", get(root))
        .route("/data", post(record_temperature));

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    tracing::info!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

// basic handler that responds with a static string
async fn root() -> &'static str {
    "Hello, World!"
}

async fn record_temperature(Json(payload): Json<TempMessage>) -> (StatusCode, String) {
    // insert your application logic here
    tracing::info!("Received: {:?}", payload);

    if (payload.0).len() == 0 {
        return (StatusCode::BAD_REQUEST, "No data received".to_string());
    }

    (StatusCode::CREATED, "Gotcha".to_string())
}

#[derive(Deserialize, Debug)]
struct TempMessage(Vec<TempReading>);

#[derive(Deserialize, Debug)]
struct TempReading {
    addr: String,
    temp: f64,
}
