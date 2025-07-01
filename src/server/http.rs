use std::sync::Arc;
use tokio::sync::Mutex;
use warp::Filter;
use serde_json::Value;
use std::collections::HashMap;
use std::convert::Infallible;

use crate::project::Project;

pub struct HttpServer {
    port: u16,
    project: Arc<Mutex<Option<Project>>>,
}

impl HttpServer {
    pub fn new(port: u16) -> Self {
        Self {
            port,
            project: Arc::new(Mutex::new(None)),
        }
    }

    pub async fn start(&self) -> Result<(), Box<dyn std::error::Error>> {
        let project = self.project.clone();

        // Health check endpoint
        let health = warp::path("health")
            .and(warp::get())
            .map(|| warp::reply::json(&serde_json::json!({
                "status": "ok",
                "service": "fluxo-cli"
            })));

        // Sync endpoint - sends files to Studio
        let sync = warp::path("sync")
            .and(warp::post())
            .and(warp::body::json())
            .and(with_project(project.clone()))
            .and_then(handle_sync);

        // Validate endpoint
        let validate = warp::path("validate")
            .and(warp::post())
            .and(warp::body::json())
            .and(with_project(project.clone()))
            .and_then(handle_validate);

        // Publish endpoint
        let publish = warp::path("publish")
            .and(warp::post())
            .and(warp::body::json())
            .and(with_project(project.clone()))
            .and_then(handle_publish);

        let routes = health
            .or(sync)
            .or(validate)
            .or(publish)
            .with(warp::cors()
                .allow_any_origin()
                .allow_headers(vec!["content-type"])
                .allow_methods(vec!["GET", "POST", "OPTIONS"])
            );

        println!("🚀 Fluxo HTTP server starting on port {}", self.port);
        
        warp::serve(routes)
            .run(([127, 0, 0, 1], self.port))
            .await;

        Ok(())
    }

    pub async fn set_project(&self, project: Project) {
        let mut p = self.project.lock().await;
        *p = Some(project);
    }
}

fn with_project(
    project: Arc<Mutex<Option<Project>>>,
) -> impl Filter<Extract = (Arc<Mutex<Option<Project>>>,), Error = Infallible> + Clone {
    warp::any().map(move || project.clone())
}

async fn handle_sync(
    _body: Value,
    project: Arc<Mutex<Option<Project>>>,
) -> Result<impl warp::Reply, warp::Rejection> {
    let project_guard = project.lock().await;
    
    if let Some(proj) = project_guard.as_ref() {
        // Read all source files
        let files = proj.get_source_files().unwrap_or_default();
        
        let response = serde_json::json!({
            "success": true,
            "files": files,
            "projectPath": proj.path().to_string_lossy(),
            "metadata": proj.metadata()
        });
        
        Ok(warp::reply::with_status(
            warp::reply::json(&response),
            warp::http::StatusCode::OK
        ))
    } else {
        let error = serde_json::json!({
            "success": false,
            "error": "No project loaded"
        });
        Ok(warp::reply::with_status(
            warp::reply::json(&error),
            warp::http::StatusCode::BAD_REQUEST
        ))
    }
}

async fn handle_validate(
    _body: Value,
    project: Arc<Mutex<Option<Project>>>,
) -> Result<impl warp::Reply, warp::Rejection> {
    let project_guard = project.lock().await;
    
    if let Some(proj) = project_guard.as_ref() {
        let validation_result = proj.validate();
        Ok(warp::reply::with_status(
            warp::reply::json(&validation_result),
            warp::http::StatusCode::OK
        ))
    } else {
        let error = serde_json::json!({
            "success": false,
            "error": "No project loaded"
        });
        Ok(warp::reply::with_status(
            warp::reply::json(&error),
            warp::http::StatusCode::BAD_REQUEST
        ))
    }
}

async fn handle_publish(
    body: Value,
    project: Arc<Mutex<Option<Project>>>,
) -> Result<impl warp::Reply, warp::Rejection> {
    let project_guard = project.lock().await;
    
    if let Some(proj) = project_guard.as_ref() {
        // Prepare publish data for Studio
        let publish_data = serde_json::json!({
            "success": true,
            "metadata": body,
            "projectPath": proj.path().to_string_lossy(),
            "files": proj.get_source_files().unwrap_or_default()
        });
        
        Ok(warp::reply::with_status(
            warp::reply::json(&publish_data),
            warp::http::StatusCode::OK
        ))
    } else {
        let error = serde_json::json!({
            "success": false,
            "error": "No project loaded"
        });
        Ok(warp::reply::with_status(
            warp::reply::json(&error),
            warp::http::StatusCode::BAD_REQUEST
        ))
    }
}
