#!/usr/bin/env zsh

set -e

# Default values
typeset -a COMPONENTS
COMPONENTS=()
SKIP_CONFIRMATION=false
INTERACTIVE_COMPONENTS=false
CURRENT_OPERATION=""
SCRIPT_DIR="${0:a:h}"

# Source colors
source "${SCRIPT_DIR}/utils/colors.sh"

# Cleanup function
cleanup() {
	local exit_code=$?

	if [[ $exit_code -ne 0 ]] && [[ -n "$CURRENT_OPERATION" ]]; then
		echo ""
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo "  Uninstall interrupted during: $CURRENT_OPERATION"
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo ""
		echo "You can resume by running:"
		echo "  ./uninstall.sh --component ${(j:,:)COMPONENTS}"
		echo ""
	fi
}

# Signal handlers
handle_interrupt() {
	echo ""
	echo ""
	echo "${Red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Color_Off}"
	echo "${Red}  Uninstall cancelled by user${Color_Off}"
	echo "${Red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Color_Off}"
	echo ""

	if [[ -n "$CURRENT_OPERATION" ]]; then
		echo "Stopped during: $CURRENT_OPERATION"
		echo ""
		echo "To resume, run:"
		echo "  ./uninstall.sh --component ${(j:,:)COMPONENTS}"
		echo ""
	fi

	cleanup
	exit 130
}

# Set up traps
trap cleanup EXIT
trap handle_interrupt INT TERM

# Helper functions
print_header() {
	echo ""
	echo "${BBlue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Color_Off}"
	echo "${BBlue}  $1${Color_Off}"
	echo "${BBlue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Color_Off}"
	echo ""
}

print_success() {
	echo "${Green}${CHECK_MARK} $1${Color_Off}"
}

print_error() {
	echo "${Red}${CROSS_MARK} $1${Color_Off}"
}

print_warning() {
	echo "${Yellow}⚠️  $1${Color_Off}"
}

print_info() {
	echo "${Cyan}ℹ️  $1${Color_Off}"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		--component)
			# Support comma-separated values
			IFS=',' read -rA comp_array <<< "$2"
			COMPONENTS+=("${comp_array[@]}")
			shift 2
			;;
		-i|--interactive)
			INTERACTIVE_COMPONENTS=true
			shift
			;;
		-y|--yes)
			SKIP_CONFIRMATION=true
			shift
			;;
		-h|--help)
			echo "Usage: uninstall.sh [OPTIONS]"
			echo ""
			echo "Options:"
			echo "  --component COMP      Component(s) to uninstall (comma-separated or multiple flags)"
			echo "                        Options: all, brew, plugins, asdf, config, nvim, venv, apps"
			echo "  -i, --interactive     Choose components interactively"
			echo "  -y, --yes             Skip confirmation prompts"
			echo "  -h, --help            Show this help message"
			echo ""
			echo "Examples:"
			echo "  uninstall.sh                                    # Interactive mode"
			echo "  uninstall.sh --component all                    # Uninstall all components"
			echo "  uninstall.sh --component brew,plugins           # Uninstall Homebrew and plugins"
			echo "  uninstall.sh --component nvim --component config # Uninstall Neovim and config"
			echo "  uninstall.sh -i                                 # Choose components interactively"
			echo "  uninstall.sh -y --component all                 # Uninstall all without confirmation"
			exit 0
			;;
		*)
			echo "${Red}Unknown option: $1${Color_Off}"
			echo "Run './uninstall.sh --help' for usage information"
			exit 1
			;;
	esac
done

# Interactive component selection
if [[ $INTERACTIVE_COMPONENTS == true ]]; then
	print_header "Select Components to Uninstall"
	echo "Choose which components to uninstall:"
	echo ""
	echo "  1) All components"
	echo "  2) Homebrew packages (from Brewfile)"
	echo "  3) Zsh plugins"
	echo "  4) ASDF and tools"
	echo "  5) Config files (unstow)"
	echo "  6) Neovim files"
	echo "  7) Python venv"
	echo "  8) AppleScript apps"
	echo ""
	echo -n "Enter numbers (space-separated, e.g., '2 3 6'): "
	read -r selections

	for sel in ${(s: :)selections}; do
		case $sel in
			1) COMPONENTS=(all) ; break ;;
			2) COMPONENTS+=(brew) ;;
			3) COMPONENTS+=(plugins) ;;
			4) COMPONENTS+=(asdf) ;;
			5) COMPONENTS+=(config) ;;
			6) COMPONENTS+=(nvim) ;;
			7) COMPONENTS+=(venv) ;;
			8) COMPONENTS+=(apps) ;;
			*)
				print_error "Invalid selection: $sel"
				exit 1
				;;
		esac
	done
fi

# Default to interactive if no components specified
if [[ ${#COMPONENTS[@]} -eq 0 ]]; then
	print_warning "No components specified. Use -i for interactive mode or --help for usage."
	exit 1
fi

# Expand "all" component
if [[ " ${COMPONENTS[@]} " =~ " all " ]]; then
	COMPONENTS=(brew plugins asdf config nvim venv apps)
fi

# Helper function to list apps that will be removed
list_apps_to_remove() {
	local apps_found=()

	if [[ -d "$HOME/Applications" ]]; then
		for app in "$HOME/Applications"/*.app; do
			[[ ! -e "$app" ]] && continue

			local app_name=$(basename "$app")
			local source_name=$(echo "$app_name" | sed 's/\.app$//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
			local source_file="${SCRIPT_DIR}/automator/${source_name}.applescript"

			if [[ -f "$source_file" ]]; then
				apps_found+=("$app_name")
			fi
		done
	fi

	echo "${apps_found[@]}"
}

# Show what will be uninstalled
print_header "Uninstall Plan"
echo "The following components will be uninstalled:"
echo ""
for comp in "${COMPONENTS[@]}"; do
	case $comp in
		brew)
			echo "  ${Red}•${Color_Off} Homebrew packages (from Brewfile)"
			;;
		plugins)
			echo "  ${Red}•${Color_Off} Zsh plugins (./plugins directory)"
			;;
		asdf)
			echo "  ${Red}•${Color_Off} ASDF and all installed tools (~/.asdf)"
			;;
		config)
			echo "  ${Red}•${Color_Off} Config files (unstow from $HOME)"
			;;
		nvim)
			echo "  ${Red}•${Color_Off} Neovim files (~/.config/nvim, ~/.local/share/nvim, ~/.cache/nvim)"
			;;
		venv)
			echo "  ${Red}•${Color_Off} Python virtual environment (./.venv)"
			;;
		apps)
			local apps_list=($(list_apps_to_remove))
			if [[ ${#apps_list[@]} -gt 0 ]]; then
				echo "  ${Red}•${Color_Off} AppleScript apps:"
				for app in "${apps_list[@]}"; do
					echo "    - ~/Applications/$app"
				done
			else
				echo "  ${Red}•${Color_Off} AppleScript apps (none found)"
			fi
			;;
		*)
			print_error "Unknown component: $comp"
			exit 1
			;;
	esac
done
echo ""

# Confirmation prompt
if [[ $SKIP_CONFIRMATION == false ]]; then
	echo "${BRed}WARNING: This operation cannot be easily undone!${Color_Off}"
	echo ""
	echo -n "Are you sure you want to continue? [y/N]: "
	read -r confirmation
	if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
		print_info "Uninstall cancelled."
		exit 0
	fi
	echo ""
fi

# Component uninstall functions
uninstall_venv() {
	CURRENT_OPERATION="Removing Python venv"
	print_header "$CURRENT_OPERATION"

	if [[ -d "${SCRIPT_DIR}/.venv" ]]; then
		rm -rf "${SCRIPT_DIR}/.venv"
		print_success "Python venv removed"
	else
		print_info "Python venv not found, skipping"
	fi
}

uninstall_asdf() {
	CURRENT_OPERATION="Removing ASDF and tools"
	print_header "$CURRENT_OPERATION"

	if [[ -d "$HOME/.asdf" ]]; then
		rm -rf "$HOME/.asdf"
		print_success "ASDF and all tools removed"
	else
		print_info "ASDF not found, skipping"
	fi
}

uninstall_config() {
	CURRENT_OPERATION="Unstowing config files"
	print_header "$CURRENT_OPERATION"

	if [[ -d "${SCRIPT_DIR}/config" ]]; then
		if command -v stow &> /dev/null; then
			if (cd "${SCRIPT_DIR}" && stow -D config -t ~) 2>&1; then
				print_success "Config files unstowed"
			else
				print_error "Failed to unstow config files"
				print_info "You may need to manually remove symlinks from $HOME"
			fi
		else
			print_error "GNU Stow not found, cannot unstow config files"
			print_info "You may need to manually remove symlinks from $HOME"
		fi
	else
		print_info "Config directory not found, skipping"
	fi
}

uninstall_brew() {
	CURRENT_OPERATION="Removing Homebrew packages"
	print_header "$CURRENT_OPERATION"

	if ! command -v brew &> /dev/null; then
		print_info "Homebrew not found, skipping"
		return
	fi

	if [[ ! -f "${SCRIPT_DIR}/Brewfile" ]]; then
		print_warning "Brewfile not found, cannot determine packages to remove"
		return
	fi

	print_info "Reading Brewfile to determine packages..."

	# Extract formulas from Brewfile
	local formulas=(${(f)"$(grep '^brew ' "${SCRIPT_DIR}/Brewfile" | sed 's/^brew "\(.*\)"$/\1/' | sed "s/^brew '\(.*\)'$/\1/")"})

	# Extract casks from Brewfile
	local casks=(${(f)"$(grep '^cask ' "${SCRIPT_DIR}/Brewfile" | sed 's/^cask "\(.*\)"$/\1/' | sed "s/^cask '\(.*\)'$/\1/")"})

	# Remove formulas
	if [[ ${#formulas[@]} -gt 0 ]]; then
		print_info "Removing ${#formulas[@]} Homebrew formulas..."
		for formula in "${formulas[@]}"; do
			if brew list --formula | grep -q "^${formula}$"; then
				echo "  Removing formula: $formula"
				brew uninstall --force "$formula" 2>&1 || print_warning "Failed to remove: $formula"
			fi
		done
	fi

	# Remove casks
	if [[ ${#casks[@]} -gt 0 ]]; then
		print_info "Removing ${#casks[@]} Homebrew casks..."
		for cask in "${casks[@]}"; do
			if brew list --cask | grep -q "^${cask}$"; then
				echo "  Removing cask: $cask"
				brew uninstall --cask --force "$cask" 2>&1 || print_warning "Failed to remove: $cask"
			fi
		done
	fi

	print_success "Homebrew packages processed"
	print_info "Note: Homebrew itself was not uninstalled. To remove Homebrew:"
	print_info "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)\""
}

uninstall_nvim() {
	CURRENT_OPERATION="Removing Neovim files"
	print_header "$CURRENT_OPERATION"

	local removed=false

	if [[ -d "$HOME/.config/nvim" ]]; then
		rm -rf "$HOME/.config/nvim"
		print_success "Removed ~/.config/nvim"
		removed=true
	fi

	if [[ -d "$HOME/.local/share/nvim" ]]; then
		rm -rf "$HOME/.local/share/nvim"
		print_success "Removed ~/.local/share/nvim"
		removed=true
	fi

	if [[ -d "$HOME/.cache/nvim" ]]; then
		rm -rf "$HOME/.cache/nvim"
		print_success "Removed ~/.cache/nvim"
		removed=true
	fi

	if [[ $removed == false ]]; then
		print_info "No Neovim files found, skipping"
	fi
}

uninstall_plugins() {
	CURRENT_OPERATION="Removing Zsh plugins"
	print_header "$CURRENT_OPERATION"

	if [[ -d "${SCRIPT_DIR}/plugins" ]]; then
		rm -rf "${SCRIPT_DIR}/plugins"
		print_success "Zsh plugins removed"
	else
		print_info "Plugins directory not found, skipping"
	fi

	# Also remove themes directory mentioned in original script
	if [[ -d "${SCRIPT_DIR}/themes" ]]; then
		rm -rf "${SCRIPT_DIR}/themes"
		print_success "Zsh themes removed"
	fi
}

uninstall_apps() {
	CURRENT_OPERATION="Removing AppleScript apps"
	print_header "$CURRENT_OPERATION"

	local removed=false

	# Find all .app files in ~/Applications that were built from this repo
	if [[ -d "$HOME/Applications" ]]; then
		# Look for apps that match the naming pattern from our build script
		# The build script creates apps with Title Case names and spaces
		for app in "$HOME/Applications"/*.app; do
			[[ ! -e "$app" ]] && continue

			local app_name=$(basename "$app")
			# Convert app name to lowercase and replace spaces with hyphens
			# to check if it matches our source files
			local source_name=$(echo "$app_name" | sed 's/\.app$//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
			local source_file="${SCRIPT_DIR}/automator/${source_name}.applescript"

			# Only remove if we have the source file
			if [[ -f "$source_file" ]]; then
				rm -rf "$app"
				print_success "Removed $app_name"
				removed=true
			fi
		done
	fi

	if [[ $removed == false ]]; then
		print_info "No AppleScript apps found, skipping"
	fi
}

# Execute uninstall for each component
for component in "${COMPONENTS[@]}"; do
	case $component in
		venv)
			uninstall_venv
			;;
		asdf)
			uninstall_asdf
			;;
		config)
			uninstall_config
			;;
		brew)
			uninstall_brew
			;;
		nvim)
			uninstall_nvim
			;;
		plugins)
			uninstall_plugins
			;;
		apps)
			uninstall_apps
			;;
	esac
done

# Final summary
print_header "Uninstall Complete"
print_success "All selected components have been processed"
echo ""
print_info "Next steps:"
echo "  1. Reload your shell environment: exec zsh"
echo "  2. If you unstowed config files, check $HOME for any remaining symlinks"
echo "  3. To completely remove Homebrew, run the official uninstall script"
echo ""