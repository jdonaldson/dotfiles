#!/bin/bash
# Opacity picker with live preview via fzf execute-silent
SOCKET=$(ls /tmp/kitty-socket-* 2>/dev/null | head -1)
[ -z "$SOCKET" ] && exit 0

# Bake socket into helper so fzf can call it
cat > /tmp/fzf_set_opacity.sh << EOF
#!/bin/bash
kitty @ --to "unix:$SOCKET" set-background-opacity "\$1"
EOF
chmod +x /tmp/fzf_set_opacity.sh

# Save current opacity to revert on Escape
CURRENT=$(kitty @ --to "unix:$SOCKET" get-background-opacity 2>/dev/null || echo "0.85")

CHOICE=$(printf '█████ 1.0\n████░ 0.9\n███░░ 0.8\n██░░░ 0.7\n█░░░░ 0.6\n░░░░░ 0.5' | \
  fzf --reverse --no-info --pointer=' ' --prompt='' --no-separator --no-input \
      --bind 'up:up+execute-silent(/tmp/fzf_set_opacity.sh {2})' \
      --bind 'down:down+execute-silent(/tmp/fzf_set_opacity.sh {2})' \
      --bind 'k:up+execute-silent(/tmp/fzf_set_opacity.sh {2})' \
      --bind 'j:down+execute-silent(/tmp/fzf_set_opacity.sh {2})')

if [ -z "$CHOICE" ]; then
  # Escape — revert
  kitty @ --to "unix:$SOCKET" set-background-opacity "$CURRENT"
fi
