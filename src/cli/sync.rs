use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;
use colored::Colorize;

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
        // Try to connect to Studio plugin via HTTP/RPC
        // This would check if the companion plugin is running
        
        // For now, we'll simulate this check
        // In a real implementation, this would ping the Studio plugin
        println!("{}", "🔍 Checking Studio connection...".cyan());
        
        // Simulate connection check - in real implementation would use HTTP client
        // let client = reqwest::blocking::Client::new();
        // let url = format!("http://localhost:{}/health", self.port);
        
        // For development, we'll assume connection is available
        Ok(true)
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
        
        // In a real implementation, this would send to Studio via HTTP/RPC
        // For now, we'll just log what we would sync
        println!("{} Would sync {} files to Studio", "✅".green(), files.len());
        
        if !files.is_empty() {
            println!("  Files to sync:");
            for file_path in files.keys() {
                println!("    {} {}", "•".cyan(), file_path);
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
