#!/bin/bash
# tproxy installer with bash completion

SCRIPT_NAME="tproxy"
INSTALL_PATH="/usr/local/bin/$SCRIPT_NAME"
COMPLETION_FILE="/etc/bash_completion.d/$SCRIPT_NAME"

echo "🚀 Installing $SCRIPT_NAME..."

# Ensure script is executable
chmod +x tproxy.sh

# Copy to /usr/local/bin so it's globally accessible
sudo cp tproxy.sh $INSTALL_PATH

# Install bash completion
echo "_${SCRIPT_NAME}_completion() {
    local cmds=\"set disable toggle show help\"
    COMPREPLY=( \$(compgen -W \"\$cmds\" -- \${COMP_WORDS[1]}) )
}
complete -F _${SCRIPT_NAME}_completion $SCRIPT_NAME" | sudo tee $COMPLETION_FILE > /dev/null

# Reload bash completion without reboot
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# Confirm installation
if [[ -f "$INSTALL_PATH" ]]; then
    echo "✅ Installed successfully!"
    echo "💡 You can now run '$SCRIPT_NAME' from anywhere."
else
    echo "❌ Installation failed."
    exit 1
fi

