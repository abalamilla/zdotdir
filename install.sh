#!/usr/bin/env zsh

set -e

# Default values
BRANCH_NAME="main"
RUN_MODE="auto"  # auto, initial, update
typeset -a COMPONENTS
COMPONENTS=()
SKIP_CONFIRMATION=false
INTERACTIVE_COMPONENTS=false
CURRENT_OPERATION=""

# Cleanup function
cleanup() {
	local exit_code=$?

	# Unset environment variables we may have set
	unset HOMEBREW_NO_AUTO_UPDATE

	if [[ $exit_code -ne 0 ]] && [[ -n "$CURRENT_OPERATION" ]]; then
		echo ""
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo "  Installation interrupted during: $CURRENT_OPERATION"
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
		echo ""
		echo "You can resume by running:"
		echo "  ./install.sh --component ${(j:,:)COMPONENTS}"
		echo ""
	fi
}

# Signal handlers
handle_interrupt() {
	echo ""
	echo ""
	echo "${Red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Color_Off}"
	echo "${Red}  Installation cancelled by user${Color_Off}"
	echo "${Red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Color_Off}"
	echo ""

	if [[ -n "$CURRENT_OPERATION" ]]; then
		echo "Stopped during: $CURRENT_OPERATION"
		echo ""
		echo "To resume, run:"
		echo "  ./install.sh --component ${(j:,:)COMPONENTS}"
		echo ""
	fi

	cleanup
	exit 130
}

# Set up traps
trap cleanup EXIT
trap handle_interrupt INT TERM

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		--branch)
			BRANCH_NAME="$2"
			shift 2
			;;
		--mode)
			RUN_MODE="$2"
			shift 2
			;;
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
			echo "Usage: install.sh [OPTIONS]"
			echo ""
			echo "Options:"
			echo "  --branch BRANCH        Git branch to use (default: main)"
			echo "  --mode MODE           Run mode: auto|initial|update (default: auto)"
			echo "  --component COMP      Component(s) to install/update (comma-separated or multiple flags)"
			echo "                        Options: all, brew, brew-upgrade, plugins, asdf, config, macos, apps"
			echo "  -i, --interactive     Choose components interactively"
			echo "  -y, --yes             Skip confirmation prompts"
			echo "  -h, --help            Show this help message"
			echo ""
			echo "Examples:"
			echo "  install.sh                                      # Interactive mode"
			echo "  install.sh --component all                      # All components (no brew upgrade)"
			echo "  install.sh --component all,brew-upgrade -y      # All components + brew upgrade"
			echo "  install.sh --component brew -y                  # Install missing packages only (fast)"
			echo "  install.sh --component brew-upgrade -y          # Install + upgrade all packages"
			echo "  install.sh --component brew,plugins             # Homebrew and plugins"
			echo "  install.sh -i                                   # Interactive component selection"
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			echo "Use --help for usage information"
			exit 1
			;;
	esac
done

# If no components specified, enable interactive mode
if [[ ${#COMPONENTS[@]} -eq 0 ]] && [[ "$INTERACTIVE_COMPONENTS" == false ]]; then
	INTERACTIVE_COMPONENTS=true
fi

MY_ZDOTDIR=$HOME/zdotdir
ZDOTDIR_PLUGINS="$MY_ZDOTDIR/plugins"
UTILS_PATH=$MY_ZDOTDIR/utils
ZDOTDIR_THEMES=$MY_ZDOTDIR/themes

print_message() {
	# prints a message
	MESSAGE=$1
	CMD_STATUS=${2:-0}

	case $CMD_STATUS in
		-2) echo "${Purple} Skipping: ${Color_Off} $MESSAGE";;
		-1) echo "${Cyan} Processing: ${Color_Off} $MESSAGE";;
		0) echo "${Green}${CHECK_MARK} Success: ${Color_Off} $MESSAGE";;
		*) echo "${Red}${CROSS_MARK} Error: ${Color_Off} $MESSAGE";;
	esac
}

detect_mode() {
	# Auto-detect if this is initial setup or update
	if [[ "$RUN_MODE" != "auto" ]]; then
		echo "$RUN_MODE"
		return
	fi

	# Check if homebrew exists in known locations
	local brew_exists=false
	if command -v brew &> /dev/null; then
		brew_exists=true
	elif [[ -x "/opt/homebrew/bin/brew" ]] || [[ -x "/usr/local/bin/brew" ]] || [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
		brew_exists=true
	fi

	# Check for indicators of existing installation
	if [[ -d "$MY_ZDOTDIR" ]] && [[ -d "$MY_ZDOTDIR/.git" ]] && [[ "$brew_exists" == true ]]; then
		echo "update"
	else
		echo "initial"
	fi
}

should_run_component() {
	# Check if a component should run based on COMPONENTS array
	local component=$1

	# brew-upgrade is opt-in only, never included in "all"
	if [[ "$component" == "brew-upgrade" ]]; then
		if (( ${COMPONENTS[(I)brew-upgrade]} )); then
			return 0
		fi
		return 1
	fi

	# Check if "all" is in the array
	if (( ${COMPONENTS[(I)all]} )); then
		return 0
	fi

	# Check if the specific component is in the array
	if (( ${COMPONENTS[(I)$component]} )); then
		return 0
	fi

	return 1
}

select_components() {
	# Interactive component selection
	echo ""
	echo "Select components to install/update:"
	echo ""
	echo "  [1] All components"
	echo "  [2] Homebrew packages (install missing only)"
	echo "  [3] Homebrew packages + upgrade (full update)"
	echo "  [4] Zsh plugins"
	echo "  [5] ASDF tools"
	echo "  [6] Config files (stow)"
	echo "  [7] macOS settings"
	echo "  [8] AppleScript apps"
	echo ""
	echo "Enter numbers separated by spaces (e.g., '2 4 5'), or press Enter for all:"
	read "selection?> "

	if [[ -z "$selection" ]] || [[ "$selection" =~ "1" ]]; then
		COMPONENTS=("all")
		return
	fi

	# Map numbers to component names
	typeset -A component_map
	component_map[2]="brew"
	component_map[3]="brew-upgrade"
	component_map[4]="plugins"
	component_map[5]="asdf"
	component_map[6]="config"
	component_map[7]="macos"
	component_map[8]="apps"

	# Parse selection
	for num in ${(s: :)selection}; do
		if [[ -n "${component_map[$num]}" ]]; then
			COMPONENTS+=("${component_map[$num]}")
		fi
	done

	# If nothing valid selected, default to all
	if [[ ${#COMPONENTS[@]} -eq 0 ]]; then
		COMPONENTS=("all")
	fi
}

is_initial_setup() {
	[[ "$(detect_mode)" == "initial" ]]
}

is_update() {
	[[ "$(detect_mode)" == "update" ]]
}

clone_repo() {
	# clone a github repository
	GIT_REPO_PATH=$1
	DEST_PATH=$2
	GIT_OPTIONS=${3:-""}
	PROJECT_NAME="$(basename $GIT_REPO_PATH)"
	FINAL_DEST_PATH="$DEST_PATH/$PROJECT_NAME"
	GITHUB_URL="https://github.com"

	print_message "Verifying local path: $FINAL_DEST_PATH" -1
	if [ ! -d $FINAL_DEST_PATH ]; then
		print_message "Cloning repository..." -1
		git clone $GIT_OPTIONS $GITHUB_URL/$GIT_REPO_PATH $FINAL_DEST_PATH
	else
		print_message "Updating repository..." -1
		git -C $FINAL_DEST_PATH pull
	fi

	print_message "Installed on: $FINAL_DEST_PATH" $?
}

install_sh() {
	# gets and execute an installer from sh file
	SH_URL=$1
	COMMAND=$2

	print_message "Attempting to install $COMMAND" -1
	print_message "$(type -w $COMMAND)" -1

	if [ "$(type -w $COMMAND)" = "$COMMAND: none" ]; then
		/bin/bash -c "$(curl -fsSL $SH_URL)"
	else
		print_message "$COMMAND is already installed" -2
	fi

	print_message "Finished processing $COMMAND installation" $?
}

load_scripts() {
	cd $MY_ZDOTDIR
	git checkout $BRANCH_NAME

	print_message "Loading scripts" -1
	source $UTILS_PATH/colors.sh
	source env/autoload_functions.sh $UTILS_PATH
	print_message "Scripts loaded" $?
}

clone_repos() {
	print_message "Cloning plugins and themes" -1

	local INDEX=1
	typeset -a REPOS_TO_CLONE

	REPOS_TO_CLONE=(
		# zsh plugins
		[((INDEX++))]=(["repo"]="Aloxaf/fzf-tab" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-autosuggestions" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-history-substring-search" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-completions" ["dest"]=$ZDOTDIR_PLUGINS)
		[((INDEX++))]=(["repo"]="zsh-users/zsh-syntax-highlighting" ["dest"]=$ZDOTDIR_PLUGINS)
	)

	typeset -A CURRENT_REPO

	for CURRENT_VALUE in $REPOS_TO_CLONE; do
		eval "CURRENT_REPO=$CURRENT_VALUE"

		GIT_URL=$CURRENT_REPO[repo]
		DEST_PATH=$CURRENT_REPO[dest]
		GIT_OPTIONS=$CURRENT_REPO[options]
		CALLBACK=$CURRENT_REPO[callback]

		clone_repo $GIT_URL $DEST_PATH $GIT_OPTIONS

		[[ "$(type -w $CALLBACK)" = "$CALLBACK: function" ]] && $CALLBACK
	done

	print_message "Finished cloning plugins and themes"
}

install_homebrew() {
	# install homebrew
	print_message "Installing homebrew" -1
	NONINTERACTIVE=1 install_sh "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" "brew"
	print_message "Homebrew installed" $?
}

load_homebrew() {
	print_message "Loading homebrew" -1
	if [[ "$OSTYPE" == "darwin"* ]]; then
		if [[ $(uname -m) == "arm64" ]]; then
			# macos sillicon
			eval $(/opt/homebrew/bin/brew shellenv)
		else
			# macos intel
			eval $(/usr/local/bin/brew shellenv)
		fi
	else
		# linux
		eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	fi
}

install_apps() {
	APPS=(
		# "https://nixos.org/nix/install"::"nix-shell"
	)

	for a in $APPS; do
		CURRENT_APP=(${(s(::))a})
		install_sh $CURRENT_APP[1] $CURRENT_APP[2]
	done
}

install_brewfile() {
	print_message "Installing Brewfile" -1

	brew update
	brew upgrade

	# install brewfile dependencies
	brew bundle install --file=$MY_ZDOTDIR/Brewfile

	print_message "Installing Brewfile finished" $?
}

link_file() {
	SOURCE_FILE=$1
	DEST_PATH=$2

	print_message "Linking $SOURCE_FILE file to $DEST_PATH" -1
	if [[ ! -L $DEST_PATH ]]; then
		ln -s $SOURCE_FILE $DEST_PATH
	else
		print_message "File $DEST_PATH already linked" -2
	fi
	print_message "File $DEST_PATH linked" $?
}

configure_docker_buildx() {
	print_message "Configuring docker buildx" -1
	mkdir -p ~/.docker/cli-plugins
	if [[ $(uname -m) == "arm64" ]]; then
		link_file /opt/homebrew/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
	else
		link_file /usr/local/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
	fi
	print_message "Finished configuring docker buildx" $?
}

update_brewfile() {
	CURRENT_OPERATION="Homebrew package updates"

	# Determine if we should upgrade packages
	local should_upgrade=false
	if should_run_component "brew-upgrade"; then
		should_upgrade=true
		print_message "Updating and upgrading Homebrew packages (this may take several minutes)" -1
	else
		print_message "Updating Brewfile packages (install missing only)" -1
	fi

	# Check for outdated packages before operation
	local outdated_count=$(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
	if [[ "$outdated_count" -gt 0 ]]; then
		print_message "$outdated_count package(s) need updating" -1
	fi

	# Skip brew's auto-update for speed (it already ran once)
	export HOMEBREW_NO_AUTO_UPDATE=1

	# Install/update brewfile dependencies
	local brew_cmd="brew bundle install --file=$MY_ZDOTDIR/Brewfile"
	if [[ "$should_upgrade" == false ]]; then
		brew_cmd="$brew_cmd --no-upgrade"
	fi

	if eval "$brew_cmd"; then
		print_message "Brewfile operation finished" 0

		# Show helpful message if packages are still outdated and upgrade wasn't requested
		if [[ "$should_upgrade" == false ]]; then
			local outdated_after=$(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
			if [[ "$outdated_after" -gt 0 ]]; then
				echo ""
				echo "Note: $outdated_after package(s) are outdated but were not upgraded (--no-upgrade mode)"
				echo "To upgrade outdated packages, run:"
				echo "  ./install.sh --component brew-upgrade"
				echo "Or manually: brew upgrade"
				echo ""
			fi
		fi
	else
		local exit_code=$?
		print_message "Brewfile operation completed with some failures" 1
		echo ""
		echo "Some packages may have failed to install (network issues, etc.)"
		echo "You can retry with: ./install.sh --component brew"
		echo "Or manually run: brew bundle install --file=$MY_ZDOTDIR/Brewfile"
		echo ""
	fi

	CURRENT_OPERATION=""
}

update_python_venv() {
	if [[ ! -d $MY_ZDOTDIR/.venv ]]; then
		print_message "Python venv doesn't exist, creating..." -1
		python -m venv $MY_ZDOTDIR/.venv
		source $MY_ZDOTDIR/.venv/bin/activate
		pip install -r $MY_ZDOTDIR/requirements.txt
		print_message "Python venv created" $?
	else
		print_message "Updating python venv packages" -1
		source $MY_ZDOTDIR/.venv/bin/activate
		pip install --upgrade -r $MY_ZDOTDIR/requirements.txt
		print_message "Python venv updated" $?
	fi
}

update_stow_config() {
	print_message "Updating stow configuration" -1

	# Try to stow (will skip existing, error on conflicts)
	local stow_output=$(stow config -t ~ 2>&1)
	local stow_status=$?

	if [[ $stow_status -ne 0 ]]; then
		# Check if the error is about conflicts
		if echo "$stow_output" | grep -q "existing target is not owned by stow"; then
			print_message "Stow conflicts detected" 1
			echo ""
			echo "The following files/symlinks are blocking stow:"
			echo ""

			# Parse and display conflicts
			local conflicts=$(echo "$stow_output" | grep "existing target is not owned by stow" | sed 's/.*: //')
			while IFS= read -r conflict_path; do
				[[ -z "$conflict_path" ]] && continue

				local full_path="$HOME/$conflict_path"
				if [[ -L "$full_path" ]]; then
					local target=$(readlink "$full_path")
					echo "  • $conflict_path (symlink -> $target)"
				elif [[ -e "$full_path" ]]; then
					echo "  • $conflict_path (file/directory)"
				fi
			done <<< "$conflicts"

			echo ""
			echo "To resolve these conflicts, you can:"
			echo "  1. Back up any important files"
			echo "  2. Remove the conflicting items:"
			echo ""
			while IFS= read -r conflict_path; do
				[[ -z "$conflict_path" ]] && continue
				echo "     rm ~/$conflict_path"
			done <<< "$conflicts"
			echo ""
			echo "  3. Re-run: ./install.sh --component config"
			echo ""

			return 1
		else
			# Different error, show it
			echo "$stow_output"
			print_message "Stow configuration failed" 1
			return 1
		fi
	else
		print_message "Stow configuration updated" 0
	fi
}

install_others() {
	# symlink docker buildx
	configure_docker_buildx

	# create python venv
	if [[ ! -d $MY_ZDOTDIR/.venv ]]; then
		print_message "Creating python venv" -1
		python -m venv $MY_ZDOTDIR/.venv
		source $MY_ZDOTDIR/.venv/bin/activate
		pip install -r $MY_ZDOTDIR/requirements.txt
		print_message "Python venv created" $?
	else
		print_message "Python venv already exists" -2
	fi
}

add_asdf_plugin() {
	local plugin=$1
	if asdf plugin list | grep -q "^${plugin}$"; then
		print_message "asdf plugin $plugin already exists" -2
	else
		print_message "Adding asdf plugin $plugin" -1
		asdf plugin add "$plugin" 2>&1 || true
	fi
}

config_asdf() {
	CURRENT_OPERATION="ASDF tool installation"
	print_message "Configuring asdf" -1

	# Load asdf first to enable plugin commands
	source "$(brew --prefix asdf)/libexec/asdf.sh"

	# asdf plugin list | awk '{print "asdf plugin add " $1 }'
	local plugins=(
		argocd aws-sam-cli awscli bun clj-kondo cljstyle colima coursier
		dive dotnet eza fd fzf git golang gradle helm imagemagick java jq
		julia k9s krew kubebuilder kubectl kubectx kubeseal kuttl lazygit
		leiningen lima markdownlint-cli2 maven neovim nodejs python ripgrep
		rust rust-analyzer sbt scala shellcheck shfmt task terraform uv
		vault yarn yq zoxide
	)

	for plugin in "${plugins[@]}"; do
		add_asdf_plugin "$plugin"
	done

	# install tools
	print_message "Installing asdf tools from .tool-versions" -1
	asdf install

	print_message "Finished configuring asdf" $?
	CURRENT_OPERATION=""
}

install_asdf() {
	print_message "Installing asdf" -1
	brew install asdf
	config_asdf
	print_message "Finished installing asdf" $?
}

init_config() {
	# install homebrew
	install_homebrew
	load_homebrew

	# load zdotdir scripts
	load_scripts
}

configure_macos() {
  print_message "Expose groups apps" -1
  # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
  defaults write com.apple.dock expose-group-apps -bool true && killall Dock

  print_message "Spans displays" -1
  # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
  defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
}

build_applescript_apps() {
	CURRENT_OPERATION="AppleScript apps installation"
	print_message "Building and installing AppleScript apps" -1

	# Check if on macOS
	if [[ "$OSTYPE" != "darwin"* ]]; then
		print_message "Skipping AppleScript apps (not on macOS)" -2
		return 0
	fi

	# Check if osacompile is available
	if ! command -v osacompile &> /dev/null; then
		print_message "osacompile not found, skipping AppleScript apps" 1
		return 1
	fi

	# Create ~/Applications if it doesn't exist
	mkdir -p ~/Applications

	# Build each .applescript file in automator/
	local apps_built=0
	local apps_failed=0

	if [[ -d "$MY_ZDOTDIR/automator" ]]; then
		for script_file in "$MY_ZDOTDIR/automator"/*.applescript; do
			# Skip if no .applescript files found
			[[ ! -f "$script_file" ]] && continue

			local script_name=$(basename "$script_file" .applescript)
			# Capitalize first letter and replace hyphens with spaces
			local app_name="$(echo ${script_name:gs/-/ /} | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1').app"
			local temp_app="/tmp/${app_name}"
			local dest_app="$HOME/Applications/${app_name}"

			print_message "Building $app_name" -1

			# Compile AppleScript to app bundle
			if osacompile -o "$temp_app" "$script_file" 2>&1; then
				# Check for custom icon
				local icon_file="$MY_ZDOTDIR/automator/icons/${script_name}.icns"
				if [[ -f "$icon_file" ]]; then
					# Copy icon to app bundle
					cp "$icon_file" "$temp_app/Contents/Resources/applet.icns"
					print_message "Custom icon applied to $app_name" -1
				fi

				# Remove existing app if present
				[[ -d "$dest_app" ]] && rm -rf "$dest_app"

				# Move to Applications
				mv "$temp_app" "$dest_app"

				# Touch the app to refresh Finder's icon cache
				touch "$dest_app"

				print_message "$app_name installed to ~/Applications/" 0
				apps_built=$((apps_built + 1))
			else
				print_message "Failed to build $app_name" 1
				apps_failed=$((apps_failed + 1))
			fi
		done
	fi

	if [[ $apps_built -eq 0 ]] && [[ $apps_failed -eq 0 ]]; then
		print_message "No AppleScript files found in automator/" -2
	elif [[ $apps_failed -gt 0 ]]; then
		print_message "Built $apps_built app(s), $apps_failed failed" 1
	else
		print_message "Successfully built and installed $apps_built app(s)" 0
	fi

	CURRENT_OPERATION=""
}

run_initial_setup() {
	print_message "Starting INITIAL SETUP" -1
	echo ""

	# Clone zdotdir repository
	if should_run_component "all"; then
		clone_repo abalamilla/zdotdir $HOME
	fi

	# Setup initial configuration (homebrew + scripts)
	if should_run_component "all"; then
		init_config
	fi

	# Clone plugins and themes
	if should_run_component "plugins" || should_run_component "all"; then
		clone_repos
	fi

	# Install brewfile
	if should_run_component "brew" || should_run_component "all"; then
		install_brewfile
	fi

	# Stow configuration files
	if should_run_component "config" || should_run_component "all"; then
		stow config -t ~
	fi

	# Configure macOS settings
	if should_run_component "macos" || should_run_component "all"; then
		if [[ "$OSTYPE" == "darwin"* ]]; then
			configure_macos
		else
			print_message "Skipping macOS configuration (not on macOS)" -2
		fi
	fi

	# Install and configure asdf
	if should_run_component "asdf" || should_run_component "all"; then
		install_asdf
	fi

	# Build and install AppleScript apps
	if should_run_component "apps" || should_run_component "all"; then
		build_applescript_apps
	fi

	# Install other apps and configurations
	if should_run_component "all"; then
		install_apps
		install_others
	fi

	echo ""
	print_message "Finish! Enjoy your new environment."
}

run_update() {
	print_message "Starting UPDATE" -1
	echo ""

	# Update zdotdir repository
	if should_run_component "all"; then
		clone_repo abalamilla/zdotdir $HOME
		load_homebrew
		load_scripts
	fi

	# Update plugins
	if should_run_component "plugins" || should_run_component "all"; then
		clone_repos
	fi

	# Update brewfile packages
	if should_run_component "brew" || should_run_component "brew-upgrade" || should_run_component "all"; then
		update_brewfile
	fi

	# Update stow configuration
	if should_run_component "config" || should_run_component "all"; then
		update_stow_config
	fi

	# Re-configure macOS settings (idempotent)
	if should_run_component "macos" || should_run_component "all"; then
		if [[ "$OSTYPE" == "darwin"* ]]; then
			configure_macos
		else
			print_message "Skipping macOS configuration (not on macOS)" -2
		fi
	fi

	# Update asdf and tools
	if should_run_component "asdf" || should_run_component "all"; then
		config_asdf
	fi

	# Build and install AppleScript apps
	if should_run_component "apps" || should_run_component "all"; then
		build_applescript_apps
	fi

	# Update other components
	if should_run_component "all"; then
		configure_docker_buildx
		update_python_venv
	fi

	echo ""
	print_message "Update complete!"
}

show_run_info() {
	local mode=$(detect_mode)

	# Show interactive component selection if needed
	if [[ "$INTERACTIVE_COMPONENTS" == true ]]; then
		select_components
	fi

	# Format components for display
	local components_display
	if (( ${COMPONENTS[(I)all]} )); then
		components_display="all"
	else
		components_display="${(j:, :)COMPONENTS}"
	fi

	echo ""
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "  zdotdir Setup & Configuration"
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo ""
	echo "  Mode:       $mode"
	echo "  Components: $components_display"
	echo "  Branch:     $BRANCH_NAME"
	echo ""
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo ""

	if [[ "$SKIP_CONFIRMATION" == false ]]; then
		read "response?Continue? [Y/n] "
		if [[ "$response" =~ ^[Nn]$ ]]; then
			echo "Aborted."
			exit 0
		fi
	fi
}

# Main execution
() {
	local mode=$(detect_mode)

	# Show run information
	show_run_info

	# Execute based on mode
	if [[ "$mode" == "initial" ]]; then
		run_initial_setup
	else
		run_update
	fi
}

