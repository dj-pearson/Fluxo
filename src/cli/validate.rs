use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;
use colored::Colorize;

use crate::{
    config::Config,
    ext::PathExt,
    project,
};

/// Validate plugin code and metadata before publishing
#[derive(Parser)]
pub struct Validate {
    /// Project path
    #[arg()]
    project: Option<PathBuf>,
    
    /// Skip metadata validation
    #[arg(long)]
    skip_metadata: bool,
    
    /// Skip banned API check
    #[arg(long)]
    skip_api_check: bool,
    
    /// Skip structure validation
    #[arg(long)]
    skip_structure: bool,
    
    /// Show verbose validation output
    #[arg(short, long)]
    verbose: bool,
}

impl Validate {
    pub fn main(self) -> Result<()> {
        println!("{}", "🔍 Validating plugin...".blue().bold());
        
        let project_path = project::resolve(self.project.clone().unwrap_or_default())?;
        
        Config::load_workspace(project_path.get_parent());
        
        let mut errors = Vec::new();
        let mut warnings = Vec::new();
        
        // 1. Validate project structure
        if !self.skip_structure {
            if let Err(e) = self.validate_structure(&project_path) {
                errors.push(format!("Structure validation failed: {}", e));
            } else {
                println!("{}", "✅ Project structure is valid".green());
            }
        }
        
        // 2. Validate metadata
        if !self.skip_metadata {
            match self.validate_metadata(&project_path) {
                Ok(metadata_warnings) => {
                    warnings.extend(metadata_warnings);
                    println!("{}", "✅ Metadata validation passed".green());
                },
                Err(e) => {
                    errors.push(format!("Metadata validation failed: {}", e));
                }
            }
        }
        
        // 3. Check for banned APIs
        if !self.skip_api_check {
            match self.check_banned_apis(&project_path) {
                Ok(api_warnings) => {
                    warnings.extend(api_warnings);
                    if api_warnings.is_empty() {
                        println!("{}", "✅ No banned APIs detected".green());
                    }
                },
                Err(e) => {
                    errors.push(format!("API validation failed: {}", e));
                }
            }
        }
        
        // Report results
        if !warnings.is_empty() {
            println!("\n{}", "⚠️  Warnings:".yellow().bold());
            for warning in &warnings {
                println!("  {} {}", "•".yellow(), warning);
            }
        }
        
        if !errors.is_empty() {
            println!("\n{}", "❌ Errors:".red().bold());
            for error in &errors {
                println!("  {} {}", "•".red(), error);
            }
            return Err(anyhow::anyhow!("Validation failed with {} errors", errors.len()));
        }
        
        println!("\n{}", "✅ Plugin validation completed successfully!".green().bold());
        Ok(())
    }
    
    fn validate_structure(&self, project_path: &std::path::Path) -> Result<()> {
        // Check for required files and folders
        let src_dir = project_path.join("src");
        if !src_dir.exists() {
            return Err(anyhow::anyhow!("Missing 'src' directory"));
        }
        
        let meta_file = project_path.join("plugin.meta.json");
        if !meta_file.exists() {
            return Err(anyhow::anyhow!("Missing 'plugin.meta.json' file"));
        }
        
        let config_file = project_path.join("fluxo.config.json");
        if !config_file.exists() {
            return Err(anyhow::anyhow!("Missing 'fluxo.config.json' file"));
        }
        
        Ok(())
    }
    
    fn validate_metadata(&self, project_path: &std::path::Path) -> Result<Vec<String>> {
        let mut warnings = Vec::new();
        
        let meta_file = project_path.join("plugin.meta.json");
        let metadata: serde_json::Value = serde_json::from_str(
            &std::fs::read_to_string(meta_file)?
        )?;
        
        // Check required fields
        if metadata.get("name").is_none() || metadata["name"].as_str().unwrap_or("").is_empty() {
            return Err(anyhow::anyhow!("Plugin name is required"));
        }
        
        if metadata.get("description").is_none() || metadata["description"].as_str().unwrap_or("").is_empty() {
            warnings.push("Plugin description is empty".to_string());
        }
        
        if metadata.get("version").is_none() {
            return Err(anyhow::anyhow!("Plugin version is required"));
        }
        
        // Validate version format (semver)
        if let Some(version) = metadata["version"].as_str() {
            if !version.contains('.') {
                warnings.push("Version should follow semantic versioning (e.g., 1.0.0)".to_string());
            }
        }
        
        Ok(warnings)
    }
    
    fn check_banned_apis(&self, project_path: &std::path::Path) -> Result<Vec<String>> {
        let mut warnings = Vec::new();
        let banned_apis = vec!["loadstring", "getfenv", "setfenv", "debug.getupvalue"];
        
        let src_dir = project_path.join("src");
        
        for entry in walkdir::WalkDir::new(src_dir) {
            let entry = entry?;
            if entry.file_type().is_file() {
                if let Some(ext) = entry.path().extension() {
                    if ext == "lua" || ext == "luau" {
                        let content = std::fs::read_to_string(entry.path())?;
                        
                        for api in &banned_apis {
                            if content.contains(api) {
                                warnings.push(format!(
                                    "Potentially banned API '{}' found in {}",
                                    api,
                                    entry.path().display()
                                ));
                            }
                        }
                    }
                }
            }
        }
        
        Ok(warnings)
    }
}
