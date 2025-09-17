#!/bin/bash

# This file contains shared constants and configuration variables used across bootstrap scripts.

# Default directories
DEFAULT_PROJECTS_DIR="${HOME}/Projects"
DEFAULT_XDG_CONFIG_HOME="${HOME}/.config"
DEFAULT_XDG_DATA_HOME="${HOME}/.local/share"
DEFAULT_XDG_STATE_HOME="${HOME}/.local/state"
DEFAULT_XDG_CACHE_HOME="${HOME}/.cache"

# Common package lists could be defined here if needed
# COMMON_PACKAGES=(git vim curl wget)

# Function to source this file safely
# source_constants() {
#     if [[ -f "${BASH_SOURCE[0]}" ]]; then
#         source "${BASH_SOURCE[0]}"
#     else
#         echo "Error: Unable to source constants file" >&2
#         exit 1
#     fi
# }