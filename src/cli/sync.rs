use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;
use colored::Colorize;
use serde_json;
use walkdir;

use crate::{
    config::Config,
    ext::PathExt,
    project,
    server,
};

/// Sync local plugin code to Studio
#[derive(Parser)]
pub struct Sync {
    /// Project path
    #[arg()]
    project: Option<PathBuf>,
    
    /// Watch for changes and sync automatically
    #[arg(short, long)]
    watch: bool,
    
    /// Port to use for communication with Studio
    #[arg(short, long, default_value = "8080")]
    port: u16,
}

impl Sync {
    pub fn main(self) -> Result<()> {
        println!("{}", "🔄 Starting sync with Studio...".blue().bold());
        
        let project_path = project::resolve(self.project.clone().unwrap_or_default())?;
        
        Config::load_workspace(project_path.get_parent());
        
        // First validate the project
        println!("{}", "Validating project before sync...".cyan());
        let validate_cmd = super::validate::Validate {
            project: self.project.clone(),
            skip_metadata: false,
            skip_api_check: false,
            skip_structure: false,
            verbose: false,
        };
        
        if let Err(e) = validate_cmd.main() {
            println!("{}", "❌ Validation failed. Fix errors before syncing.".red());
            return Err(e);
        }
        
        // Check if Studio is running and has the Fluxo plugin
        if !self.check_studio_connection()? {
            println!("{}", "❌ Could not connect to Studio. Make sure:".red());
            println!("  {} Roblox Studio is running", "•".red());
            println!("  {} Fluxo Studio plugin is installed and enabled", "•".red());
            return Err(anyhow::anyhow!("Studio connection failed"));
        }
        
        println!("{}", "✅ Connected to Studio".green());
        
        // Perform initial sync
        self.sync_files(&project_path)?;
        
        if self.watch {
            println!("{}", "👁️  Watching for changes... (Press Ctrl+C to stop)".yellow());
            self.start_watcher(&project_path)?;
        } else {
            println!("{}", "✅ Sync completed!".green().bold());
        }
        
        Ok(())
    }
    
    fn check_studio_connection(&self) -> Result<bool> {
        // Try to connect to Studio plugin via HTTP
        println!("{}", "🔍 Checking Studio connection...".cyan());
        
        let url = format!("http://localhost:{}/health", self.port + 1000); // Fluxo HTTP port
        
        // Use blocking reqwest for simplicity in CLI
        match reqwest::blocking::get(&url) {
            Ok(response) => {
                if response.status().is_success() {
                    println!("{}", "✅ Studio plugin connection verified".green());
                    Ok(true)
                } else {
                    println!("{}", "❌ Studio plugin not responding".red());
                    Ok(false)
                }
            },
            Err(_) => {
                println!("{}", "❌ Cannot reach Studio plugin".red());
                Ok(false)
            }
        }
    }
    
    fn sync_files(&self, project_path: &std::path::Path) -> Result<()> {
        println!("{}", "📁 Syncing files...".cyan());
        
        // Read project files
        let src_dir = project_path.join("src");
        let mut files = std::collections::HashMap::new();
        
        if src_dir.exists() {
            for entry in walkdir::WalkDir::new(&src_dir) {
                let entry = entry?;
                if entry.file_type().is_file() {
                    let relative_path = entry.path().strip_prefix(&src_dir)?;
                    let content = std::fs::read_to_string(entry.path())?;
                    files.insert(relative_path.to_string_lossy().to_string(), content);
                }
            }
        }
        
        // Read metadata if it exists
        let meta_file = project_path.join("plugin.meta.json");
        let metadata = if meta_file.exists() {
            let meta_content = std::fs::read_to_string(meta_file)?;
            serde_json::from_str(&meta_content)?
        } else {
            serde_json::json!({})
        };
        
        // Prepare sync data
        let sync_data = serde_json::json!({
            "files": files,
            "metadata": metadata,
            "projectPath": project_path.to_string_lossy()
        });
        
        // Send to Studio plugin
        let client = reqwest::blocking::Client::new();
        let url = format!("http://localhost:{}/sync", self.port + 1000);
        
        println!("{}", "📡 Sending sync request to Studio...".cyan());
        
        match client.post(&url)
            .json(&sync_data)
            .send() 
        {
            Ok(response) => {
                if response.status().is_success() {
                    if let Ok(result) = response.json::<serde_json::Value>() {
                        if result["success"].as_bool().unwrap_or(false) {
                            println!("{} Sync completed successfully!", "✅".green());
                            
                            // Log file details
                            if !files.is_empty() {
                                println!("  Synced files:");
                                for filename in files.keys() {
                                    println!("    {} {}", "📄".blue(), filename);
                                }
                            }
                        } else {
                            let error = result["error"].as_str().unwrap_or("Unknown error");
                            println!("{} Sync failed: {}", "❌".red(), error);
                        }
                    } else {
                        println!("{} Sync request sent successfully!", "✅".green());
                    }
                } else {
                    println!("{} Studio sync failed: {}", "❌".red(), response.status());
                }
            },
            Err(e) => {
                println!("{} Failed to send sync request: {}", "❌".red(), e);
                println!("💡 Make sure 'fluxo serve' is running and Studio is open");
            }
        }
        
        Ok(())
    }
    
    fn start_watcher(&self, project_path: &std::path::Path) -> Result<()> {
        use notify::{Watcher, RecursiveMode, watcher};
        use std::sync::mpsc::channel;
        use std::time::Duration;
        
        let (tx, rx) = channel();
        let mut watcher = watcher(tx, Duration::from_secs(1))?;
        
        watcher.watch(&project_path.join("src"), RecursiveMode::Recursive)?;
        
        let meta_file = project_path.join("plugin.meta.json");
        if meta_file.exists() {
            watcher.watch(&meta_file, RecursiveMode::NonRecursive)?;
        }
        
        loop {
            match rx.recv() {
                Ok(event) => {
                    println!("{} File changed: {:?}", "🔄".yellow(), event);
                    if let Err(e) = self.sync_files(project_path) {
                        println!("{} Sync error: {}", "❌".red(), e);
                    }
                },
                Err(e) => {
                    println!("{} Watch error: {}", "❌".red(), e);
                    break;
                }
            }
        }
        
        Ok(())
    }
}
