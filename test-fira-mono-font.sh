#!/usr/bin/env bash

# Test script to verify FiraMono Nerd Font installation

echo "=== Testing FiraMono Nerd Font Installation ==="
echo ""

# Check if font files exist in system fonts directory
FONT_DIR="/Library/Fonts"
FIRA_MONO_FONTS=$(find "$FONT_DIR" -name "*FiraMono*" -type f 2>/dev/null)

if [ -z "$FIRA_MONO_FONTS" ]; then
  echo "❌ ERROR: No FiraMono Nerd Font files found in $FONT_DIR"
  echo ""
  echo "To install the font, run:"
  echo "  darwin-rebuild switch --flake .#defaultMac"
  exit 1
else
  echo "✅ Found FiraMono Nerd Font files:"
  echo "$FIRA_MONO_FONTS" | while read font; do
    echo "   - $(basename "$font")"
  done
  echo ""
fi

# Check if font is available to the system
echo "Checking font availability using system_profiler..."
if system_profiler SPFontsDataType 2>/dev/null | grep -i "FiraMono" > /dev/null; then
  echo "✅ Font is registered with macOS"
else
  echo "⚠️  Font files exist but may not be registered yet"
  echo "   Try restarting your terminal or applications"
fi
echo ""

# Test font rendering with a simple command
echo "Testing font rendering (if fc-list is available)..."
if command -v fc-list &> /dev/null; then
  if fc-list | grep -i "FiraMono" > /dev/null; then
    echo "✅ Font is available via fontconfig"
    fc-list | grep -i "FiraMono" | head -3
  else
    echo "⚠️  Font not found via fontconfig (may need fontconfig setup)"
  fi
else
  echo "ℹ️  fc-list not available (install fontconfig if needed)"
fi
echo ""

# Display font information
echo "=== Font Information ==="
echo "To use FiraMono Nerd Font in your terminal:"
echo "  1. Open your terminal preferences"
echo "  2. Go to Font settings"
echo "  3. Select 'FiraMono Nerd Font' or 'FiraMono Nerd Font Mono'"
echo ""
echo "To verify in a terminal, you can test with:"
echo "  echo -e '\uf489 \uf490 \uf491'  # Should show Nerd Font icons"
echo ""

echo "=== Test Complete ==="

