#!/bin/bash

# Define the platforms
platforms=("A100T" "A200T484" "A200T676" "K325T")

# Define the directories to process
directories=("_Arcade" "_Console" "_Utility" "_Computer" "_Other")

# Platform configuration file
platform_config="/media/fat/mistex_platform.ini"

# Persistent git directory
git_dir="/media/fat/Scripts/.config/mistex_updater"

# Function to prompt user for platform selection
select_platform() {
    echo "Select a platform:"
    select platform in "${platforms[@]}"; do
        if [[ " ${platforms[*]} " =~ " ${platform} " ]]; then
            echo "Selected platform: $platform"
            echo "PLATFORM=$platform" > "$platform_config"
            return
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Function to get platform
get_platform() {
    if [[ -f "$platform_config" ]]; then
        platform=$(grep PLATFORM "$platform_config" | cut -d= -f2)
        if [[ " ${platforms[*]} " =~ " ${platform} " ]]; then
            echo "Using platform: $platform"
            return
        fi
    fi
    select_platform
}

# Function to clone specific directories
clone_specific_dirs() {
    local platform="$1"
    
    echo "Updating specific directories for $platform..."
    
    mkdir -p "$git_dir"
    cd "$git_dir"
    
    if [ ! -d ".git" ]; then
        git init 2>/dev/null
        git config --local init.defaultBranch main
        git remote add origin https://github.com/MiSTeX-devel/MiSTeX-bin.git
        git config core.sparseCheckout true
    fi
    
    # Clear existing sparse-checkout file
    > .git/info/sparse-checkout
    
    # Update sparse-checkout file
    echo "_Arcade_$platform/*" >> .git/info/sparse-checkout
    for dir in "${directories[@]}"; do
        if [ "$dir" != "_Arcade" ]; then
            echo "$dir/*_$platform.bit" >> .git/info/sparse-checkout
        fi
    done
    
    # Fetch the latest changes
    if ! git fetch --depth=1 origin main; then
        echo "Error: Failed to fetch from repository. Please check your internet connection and try again."
        cd - > /dev/null 2>&1
        return 1
    fi
    
    # Update the working directory to match the new sparse-checkout configuration
    if ! git checkout main; then
        echo "Error: Failed to checkout main branch. Please try again."
        cd - > /dev/null 2>&1
        return 1
    fi
    
    # Pull the latest changes
    if ! git pull --depth=1 origin main; then
        echo "Error: Failed to pull from repository. Please check your internet connection and try again."
        cd - > /dev/null 2>&1
        return 1
    fi
    
    cd - > /dev/null 2>&1
}

# Function to clean up and update cores
cleanup_and_update() {
    local base_dir="/media/fat"
    local temp_dir="$1"
    local platform="$2"
    
    echo "Cleaning up and updating cores for $platform..."
    
    # Handle Arcade cores
    if [ -d "$temp_dir/_Arcade_$platform" ]; then
        if [ -d "$base_dir/_Arcade" ]; then
            rm -rf "$base_dir/_Arcade"/*
        else
            mkdir -p "$base_dir/_Arcade"
        fi
        cp -r "$temp_dir/_Arcade_$platform"/* "$base_dir/_Arcade/"
    else
        echo "Warning: Arcade cores not found in the repository."
    fi
    
    # Remove other _Arcade_* directories
    for dir in "$base_dir"/_Arcade_*; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
        fi
    done
    
    # Handle other directories (Console, Utility, Computer, Other)
    for dir in "${directories[@]}"; do
        if [ "$dir" != "_Arcade" ]; then
            mkdir -p "$base_dir/$dir"
            
            # Update or add cores from the repository
            if [ -d "$temp_dir/$dir" ]; then
                for source_file in "$temp_dir/$dir"/*_"$platform".bit; do
                    if [ -f "$source_file" ]; then
                        local base_name=$(basename "$source_file" _"$platform".bit)
                        local dest_file="$base_dir/$dir/${base_name}.bit"
                        
                        # Check if the file has changed
                        if ! cmp -s "$source_file" "$dest_file"; then
                            # Remove old platform-specific files
                            rm -f "$base_dir/$dir/${base_name}"_*.bit
                            # Copy new file
                            cp "$source_file" "$dest_file"
                        fi
                    fi
                done
            else
                echo "Warning: $dir cores not found in the repository."
            fi
        fi
    done
}

# Function to cleanup git directory
cleanup_git_dir() {
    if [ -d "$git_dir" ]; then
        echo "Cleaning up git directory..."
        rm -rf "$git_dir"
        echo "Cleanup complete."
    else
        echo "Git directory not found. Nothing to clean up."
    fi
}

# Function to display help menu
show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Update MiSTeX cores for a specific platform."
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message and exit"
    echo "  -a, --ask      Force platform selection prompt"
    echo "  -p PLATFORM    Specify platform (A100T, A200T484, A200T676, K325T)"
    echo "  -c, --cleanup  Remove the git directory and exit"
    echo
    echo "If no option is provided, the script will use the stored platform"
    echo "or prompt for selection if no platform is stored."
}

# Main script
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -a|--ask)
        select_platform
        ;;
    -p)
        if [ -z "$2" ]; then
            echo "Error: -p option requires a platform argument."
            show_help
            exit 1
        elif [[ " ${platforms[*]} " =~ " $2 " ]]; then
            platform="$2"
            echo "PLATFORM=$platform" > "$platform_config"
        else
            echo "Error: Invalid platform specified."
            echo "Please choose from: ${platforms[*]}"
            exit 1
        fi
        ;;
    -c|--cleanup)
        cleanup_git_dir
        exit 0
        ;;
    "")
        get_platform
        ;;
    *)
        echo "Error: Unknown option $1"
        show_help
        exit 1
        ;;
esac

if clone_specific_dirs "$platform"; then
    cleanup_and_update "$git_dir" "$platform"
else
    echo "Error: Failed to update repository. Aborting update."
fi

echo "Script execution completed."