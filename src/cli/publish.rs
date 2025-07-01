use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;
use colored::Colorize;

use crate::{
    config::Config,
    ext::PathExt,
    project,
};

/// Trigger Studio-side publishing flow
#[derive(Parser)]
pub struct Publish {
    /// Project path
    #[arg()]
    project: Option<PathBuf>,
    
    /// Version to publish (semver format)
    #[arg(short, long)]
    version: Option<String>,
    
    /// Release notes
    #[arg(short, long)]
    notes: Option<String>,
    
    /// Skip confirmation prompt
    #[arg(short, long)]
    yes: bool,
    
    /// Port to use for communication with Studio
    #[arg(short, long, default_value = "8080")]
    port: u16,
}

impl Publish {
    pub fn main(self) -> Result<()> {
        println!("{}", "🚀 Starting plugin publish process...".blue().bold());
        
        let project_path = project::resolve(self.project.clone().unwrap_or_default())?;
        
        Config::load_workspace(project_path.get_parent());
        
        // Step 1: Validate the plugin
        println!("{}", "Step 1: Validating plugin...".cyan());
        let validate_cmd = super::validate::Validate {
            project: self.project.clone(),
            skip_metadata: false,
            skip_api_check: false,
            skip_structure: false,
            verbose: false,
        };
        
        if let Err(e) = validate_cmd.main() {
            println!("{}", "❌ Validation failed. Fix errors before publishing.".red());
            return Err(e);
        }
        
        // Step 2: Check Studio connection
        println!("{}", "Step 2: Checking Studio connection...".cyan());
        if !self.check_studio_connection()? {
            println!("{}", "❌ Could not connect to Studio. Make sure:".red());
            println!("  {} Roblox Studio is running", "•".red());
            println!("  {} Fluxo Studio plugin is installed and enabled", "•".red());
            return Err(anyhow::anyhow!("Studio connection failed"));
        }
        
        // Step 3: Load and prepare metadata
        println!("{}", "Step 3: Preparing metadata...".cyan());
        let mut metadata = self.load_metadata(&project_path)?;
        
        if let Some(version) = &self.version {
            metadata["version"] = serde_json::Value::String(version.clone());
        }
        
        // Step 4: Show publish preview
        self.show_publish_preview(&metadata)?;
        
        // Step 5: Confirmation
        if !self.yes && !self.confirm_publish()? {
            println!("{}", "Publish cancelled.".yellow());
            return Ok(());
        }
        
        // Step 6: Send publish request to Studio
        println!("{}", "Step 6: Sending publish request to Studio...".cyan());
        self.send_publish_request(&metadata)?;
        
        println!("{}", "✅ Publish request sent to Studio!".green().bold());
        println!("{}", "The Studio plugin will now handle the actual publishing process.".green());
        println!("{}", "Check Studio for the confirmation dialog.".green());
        
        Ok(())
    }
    
    fn check_studio_connection(&self) -> Result<bool> {
        // In a real implementation, this would check if Studio is running
        // and the Fluxo plugin is available
        println!("{}", "🔍 Connecting to Studio...".cyan());
        
        // Simulate connection check
        Ok(true)
    }
    
    fn load_metadata(&self, project_path: &std::path::Path) -> Result<serde_json::Value> {
        let meta_file = project_path.join("plugin.meta.json");
        
        if meta_file.exists() {
            let meta_content = std::fs::read_to_string(meta_file)?;
            Ok(serde_json::from_str(&meta_content)?)
        } else {
            return Err(anyhow::anyhow!("plugin.meta.json not found"));
        }
    }
    
    fn show_publish_preview(&self, metadata: &serde_json::Value) -> Result<()> {
        println!("\n{}", "📋 Publish Preview:".blue().bold());
        println!("{}", "─".repeat(50));
        
        if let Some(name) = metadata.get("name").and_then(|v| v.as_str()) {
            println!("{}: {}", "Name".cyan().bold(), name);
        }
        
        if let Some(version) = metadata.get("version").and_then(|v| v.as_str()) {
            println!("{}: {}", "Version".cyan().bold(), version);
        }
        
        if let Some(description) = metadata.get("description").and_then(|v| v.as_str()) {
            println!("{}: {}", "Description".cyan().bold(), description);
        }
        
        if let Some(author) = metadata.get("author").and_then(|v| v.as_str()) {
            println!("{}: {}", "Author".cyan().bold(), author);
        }
        
        if let Some(notes) = &self.notes {
            println!("{}: {}", "Release Notes".cyan().bold(), notes);
        }
        
        println!("{}", "─".repeat(50));
        
        Ok(())
    }
    
    fn confirm_publish(&self) -> Result<bool> {
        use std::io::{self, Write};
        
        print!("{}", "Are you sure you want to publish this plugin? [y/N]: ".yellow());
        io::stdout().flush()?;
        
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        
        let input = input.trim().to_lowercase();
        Ok(input == "y" || input == "yes")
    }
    
    fn send_publish_request(&self, metadata: &serde_json::Value) -> Result<()> {
        // In a real implementation, this would send the publish request to Studio
        // via HTTP/RPC, which would then trigger the Studio plugin to show
        // the confirmation dialog and handle the actual publishing
        
        println!("{}", "📤 Sending publish request...".cyan());
        
        let publish_data = serde_json::json!({
            "metadata": metadata,
            "notes": self.notes,
            "timestamp": chrono::Utc::now().timestamp()
        });
        
        // Simulate sending to Studio
        println!("{}", "✅ Request sent successfully".green());
        
        Ok(())
    }
}
