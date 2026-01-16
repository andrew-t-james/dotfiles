#!/bin/bash
# https://www.reddit.com/r/omarchy/comments/1nuzcsr/change_default_webapp_from_chrome_to_zen_browser/

# Define source directories within your dotfiles repo
SOURCE_DIR="$HOME/dotfiles/web-apps/.local/share/applications"
ICON_DIR="$SOURCE_DIR/icons"
DESKTOP_DIR="$SOURCE_DIR/applications"

# Define destination directories
DEST_ICON_DIR="$HOME/.local/share/applications/icons"
DEST_DESKTOP_DIR="$HOME/.local/share/applications"

# Make sure destination directories exist
mkdir -p "$DEST_ICON_DIR"
mkdir -p "$DEST_DESKTOP_DIR"

# Move icons to the correct location
echo "Moving icons..."
mv "$ICON_DIR"/* "$DEST_ICON_DIR"

# Move .desktop files to the correct location
echo "Moving .desktop files..."
mv "$DESKTOP_DIR"/*.desktop "$DEST_DESKTOP_DIR"

# Loop through each .desktop file and modify it
for desktop_file in "$DEST_DESKTOP_DIR"/*.desktop; do
    if [[ -f "$desktop_file" ]]; then
        echo "Modifying $desktop_file..."

        # Extract the app name from the .desktop file (assumes Name=AppName in the file)
        app_name=$(grep -i "Name=" "$desktop_file" | cut -d '=' -f2 | tr -d '[:space:]')

        # Check if the icon file exists
        icon_file="$DEST_ICON_DIR/$app_name.png"
        if [[ -f "$icon_file" ]]; then
            # Replace the Icon line in the .desktop file with the correct path
            sed -i "s|Icon=.*|Icon=$icon_file|g" "$desktop_file"
        else
            echo "Warning: Icon for $app_name not found!"
        fi

        # Modify the Exec line for the Zen Browser command
        sed -i "s|Exec=.*|Exec=zen-browser --new-instance -P web-app --new-window https://app.$app_name.com|g" "$desktop_file"

        # Ensure the desktop file has the correct permissions
        chmod +x "$desktop_file"
    fi
done

echo "Web apps setup complete!"
