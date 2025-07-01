use anyhow::Result;
use clap::{ColorChoice, Parser, Subcommand};
use clap_verbosity_flag::Verbosity;
use env_logger::fmt::WriteStyle;
use log::LevelFilter;
use std::env;

use crate::util;

mod build;
mod config;
mod debug;
mod doc;
mod exec;
mod init;
mod plugin;
mod publish;  // New for Fluxo
mod serve;
mod sourcemap;
mod stop;
mod studio;
mod sync;     // New for Fluxo
mod update;
mod validate; // New for Fluxo

macro_rules! about {
	() => {
		concat!("Fluxo ", env!("CARGO_PKG_VERSION"))
	};
}

macro_rules! long_about {
	() => {
		concat!(
			"Argon ",
			env!("CARGO_PKG_VERSION"),
			"\n",
			env!("CARGO_PKG_DESCRIPTION"),
			"\n",
			"Made with <3 by ",
			env!("CARGO_PKG_AUTHORS")
		)
	};
}

#[derive(Parser)]
#[clap(about = about!(), long_about = long_about!(), version)]
pub struct Cli {
	#[command(subcommand)]
	command: Commands,

	#[command(flatten)]
	verbose: Verbosity,

	/// Automatically answer to any prompts
	#[arg(short, long, global = true)]
	yes: bool,

	/// Print full backtrace on panic
	#[arg(short = 'B', long, global = true)]
	backtrace: bool,

	#[arg(long, hide = true, global = true)]
	profile: bool,

	/// Output coloring: auto, always, never
	#[arg(
		long,
		short = 'C',
		global = true,
		value_name = "WHEN",
		default_value = "auto",
		hide_default_value = true,
		hide_possible_values = true
	)]
	pub color: ColorChoice,
}

impl Cli {
	pub fn new() -> Cli {
		Cli::parse()
	}

	pub fn profile(&self) -> bool {
		self.profile
	}

	pub fn yes(&self) -> bool {
		if env::var("RUST_YES").is_ok() {
			return util::env_yes();
		}

		self.yes
	}

	pub fn backtrace(&self) -> bool {
		if env::var("RUST_BACKTRACE").is_ok() {
			return util::env_backtrace();
		}

		self.backtrace
	}

	pub fn verbosity(&self) -> LevelFilter {
		if env::var("RUST_VERBOSE").is_ok() {
			return util::env_verbosity();
		}

		self.verbose.log_level_filter()
	}

	pub fn log_style(&self) -> WriteStyle {
		if env::var("RUST_LOG_STYLE").is_ok() {
			return util::env_log_style();
		}

		match self.color {
			ColorChoice::Always => WriteStyle::Always,
			ColorChoice::Never => WriteStyle::Never,
			_ => WriteStyle::Auto,
		}
	}

	pub fn main(self) -> Result<()> {
		match self.command {
			Commands::Init(command) => command.main(),
			Commands::Build(command) => command.main(),
			Commands::Validate(command) => command.main(),
			Commands::Sync(command) => command.main(),
			Commands::Publish(command) => command.main(),
			Commands::Serve(command) => command.main(),
			Commands::Stop(command) => command.main(),
			Commands::Studio(command) => command.main(),
			Commands::Plugin(command) => command.main(),
			Commands::Config(command) => command.main(),
			Commands::Update(command) => command.main(),
			// Backward compatibility commands
			Commands::Sourcemap(command) => command.main(),
			Commands::Debug(command) => command.main(),
			Commands::Exec(command) => command.main(),
			Commands::Doc(command) => command.main(),
		}
	}
}

#[derive(Subcommand)]
pub enum Commands {
	Init(init::Init),
	Build(build::Build),
	Validate(validate::Validate), // New command for plugin validation
	Sync(sync::Sync),            // New command for syncing to Studio
	Publish(publish::Publish),   // New command for publishing plugins
	Serve(serve::Serve),
	Stop(stop::Stop),
	Studio(studio::Studio),
	Plugin(plugin::Plugin),
	Config(config::Config),
	Update(update::Update),
	// Keep these for backward compatibility for now
	Sourcemap(sourcemap::Sourcemap),
	Debug(debug::Debug),
	Exec(exec::Exec),
	Doc(doc::Doc),
}
