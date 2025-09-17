# yadm Dotfiles Management

This directory contains the configuration for `yadm`, a dotfiles manager. It's used to bootstrap and manage the user's development environment.

## Project Overview

This project is a collection of scripts and configuration files designed to automate the setup of a development environment, particularly on macOS. It uses `yadm` (Yet Another Dotfiles Manager) to manage dotfiles and a `bootstrap` script to orchestrate the installation process.

### Key Components

1.  **`bootstrap`**: The main entry point script. It executes all executable files in the `bootstrap.d` directory in sorted order.
2.  **`bootstrap.d/`**: Contains modular scripts for different setup tasks:
    *   `0_prepare.sh`: (Likely) Initial setup tasks.
    *   `1_packages##os.Darwin,e.sh`: Installs Homebrew and packages listed in `Brewfile` on macOS.
    *   `2_languages,e.sh`: Installs programming languages like Node.js (via `nvm`), Go, and Rust.
    *   `3_omz,e.sh`: Installs `oh-my-zsh` and related plugins.
    *   `4_tmux,e.sh`: (Commented out) Intended for setting up `tmux` and its plugins.
    *   `5_some_projects.sh`: Creates common project directories.
3.  **`Brewfile`**: Defines Homebrew taps, formulae, casks, and VS Code extensions to be installed.
4.  **`utils.sh`**: Provides helper functions for logging (`step`, `note`, `info`, `warn`, `error`), checking for executables/files/directories, and running commands.
5.  **`config`**: Likely the `yadm` configuration file.
6.  **`encrypt`**: (Likely) Used for managing encrypted files with `yadm`.
7.  **`Casks`**: (Present but commented out in `1_packages##os.Darwin,e.sh`) Potentially for listing Homebrew casks.

## Bootstrapping the Environment

To set up the environment, run the `bootstrap` script:

```bash
~/.config/yadm/bootstrap
```

This script will:

1.  Prompt for the user's password (to keep `sudo` session alive).
2.  Execute each script in `bootstrap.d` in alphabetical order.
3.  Handle errors and provide feedback during the process.

### Script Details

*   **`1_packages##os.Darwin,e.sh`**: Installs Xcode Command Line Tools, Homebrew, and then uses `brew bundle` to install packages from `Brewfile`.
*   **`2_languages,e.sh`**: Downloads and installs the latest LTS Node.js via `nvm`, the latest stable Go, and Rust via `rustup`.
*   **`3_omz,e.sh`**: Installs `oh-my-zsh` and several popular plugins (powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, etc.).
*   **`5_some_projects.sh`**: Creates a set of common project directories under `~/Projects`.

## Development Conventions

*   **Modularity**: The bootstrap process is divided into modular scripts within `bootstrap.d`, making it easier to manage and extend.
*   **Idempotency**: Scripts are generally written to be idempotent, meaning they can be run multiple times without causing errors if the desired state is already achieved (e.g., checking if a tool is already installed before installing it).
*   **Helper Functions**: Common tasks like logging and command execution are handled by functions in `utils.sh` to ensure consistency.
*   **Conditional Execution**: Scripts like `1_packages##os.Darwin,e.sh` use OS-specific suffixes (`##os.Darwin`) to ensure they only run on the correct operating system.