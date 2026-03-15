#!/bin/bash
# Opacity picker with live preview for Ghostty
# Edits ghostty config + sends SIGUSR2 to reload

CONFIG="$HOME/.config/ghostty/config"
[ ! -f "$CONFIG" ] && exit 1

# Helper script for fzf to call on navigation
cat > /tmp/fzf_set_opacity.sh << 'EOF'
#!/bin/bash
CONFIG="$HOME/.config/ghostty/config"
sed -i '' "s/^background-opacity = .*/background-opacity = $1/" "$CONFIG"
pkill -SIGUSR2 ghostty
EOF
chmod +x /tmp/fzf_set_opacity.sh

# Read current opacity to highlight and revert on Escape
CURRENT=$(grep '^background-opacity' "$CONFIG" | awk '{print $3}')
[ -z "$CURRENT" ] && CURRENT="1.0"

# Build list and find default position
OPTIONS='█████ 1.0
████░ 0.95
████░ 0.9
███░░ 0.85
███░░ 0.8
██░░░ 0.75
██░░░ 0.7
█░░░░ 0.65
█░░░░ 0.6
░░░░░ 0.55
░░░░░ 0.5'

# Find 1-indexed line of current opacity for fzf default position
DEFAULT_POS=$(echo "$OPTIONS" | grep -n " ${CURRENT}$" | cut -d: -f1)
[ -z "$DEFAULT_POS" ] && DEFAULT_POS=1

CHOICE=$(echo "$OPTIONS" | \
  fzf --reverse --no-info --pointer='▸' --prompt='' --no-separator --no-input \
      --bind "start:pos($DEFAULT_POS)" \
      --bind 'up:up+execute-silent(/tmp/fzf_set_opacity.sh {2})' \
      --bind 'down:down+execute-silent(/tmp/fzf_set_opacity.sh {2})' \
      --bind 'k:up+execute-silent(/tmp/fzf_set_opacity.sh {2})' \
      --bind 'j:down+execute-silent(/tmp/fzf_set_opacity.sh {2})')

if [ -z "$CHOICE" ]; then
  # Escape — revert to original
  sed -i '' "s/^background-opacity = .*/background-opacity = $CURRENT/" "$CONFIG"
  pkill -SIGUSR2 ghostty
fi
