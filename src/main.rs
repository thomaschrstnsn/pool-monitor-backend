use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use core::fmt;
use serde::Deserialize;
use sqlx::postgres::{PgPool, PgPoolOptions};
use std::time::Duration;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let db_connection_str = std::env::var("DATABASE_URL").expect("env DATABASE_URL");

    let pool = PgPoolOptions::new()
        .max_connections(20)
        .acquire_timeout(Duration::from_secs(3))
        .connect(&db_connection_str)
        .await;

    if let Err(e) = pool {
        tracing::error!("Failed to connect to database: {:?}", e);
        return;
    }
    let pool = pool.expect("handled");

    // build our application with a route
    let app = Router::new()
        .route("/", get(root))
        .route("/data", post(record_temperature))
        .with_state(pool);

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    tracing::info!("listening on {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}

// basic handler that responds with a static string
async fn root() -> &'static str {
    "Hello, World!"
}

async fn record_temperature(
    State(pool): State<PgPool>,
    Json(payload): Json<TempMessage>,
) -> Result<(StatusCode, String), AppError> {
    // insert your application logic here
    tracing::info!("Received: {:?}", payload);

    if (payload.0).len() == 0 {
        return Err(AppError::RequestError(RequestError::NoDataReceived));
    }

    let resp = sqlx::query_scalar("select 'hello world from pg'::text")
        .fetch_one(&pool)
        .await?;

    Ok((StatusCode::CREATED, resp))
}

#[derive(Deserialize, Debug)]
struct TempMessage(Vec<TempReading>);

#[derive(Deserialize, Debug)]
struct TempReading {
    addr: String,
    temp: f64,
}

#[derive(Debug)]
enum RequestError {
    NoDataReceived,
}

impl fmt::Display for RequestError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

enum AppError {
    DatabaseError(sqlx::Error),
    RequestError(RequestError),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        match self {
            AppError::DatabaseError(err) => {
                (StatusCode::INTERNAL_SERVER_ERROR, err.to_string()).into_response()
            }
            AppError::RequestError(err) => {
                (StatusCode::BAD_REQUEST, err.to_string()).into_response()
            }
        }
    }
}

impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        AppError::DatabaseError(err)
    }
}
