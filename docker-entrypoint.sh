#!/bin/sh

print_banner() {
    echo "================================================"
    echo "   n8n with Puppeteer - Environment Details"
    echo "================================================"
    echo "Node.js version: $(node -v)"
    echo "npm version: $(npm -v)"
    
    # Check n8n version
    if command -v n8n >/dev/null 2>&1; then
        echo "n8n version: $(n8n --version 2>/dev/null || echo 'n8n command not available')"
    else
        echo "n8n: command not found"
    fi
    
    # Check Chromium
    if [ -f "$PUPPETEER_EXECUTABLE_PATH" ]; then
        CHROME_VERSION=$("$PUPPETEER_EXECUTABLE_PATH" --version 2>/dev/null || echo "Error getting version")
        echo "Chromium version: $CHROME_VERSION"
        echo "Chromium path: $PUPPETEER_EXECUTABLE_PATH"
    else
        echo "Chromium: NOT FOUND at $PUPPETEER_EXECUTABLE_PATH"
    fi
    
    # Check Puppeteer installation
    PUPPETEER_VERSION=$(node -e "try { console.log(require('puppeteer/package.json').version); } catch(e) { console.log('not installed globally'); }" 2>/dev/null)
    echo "Puppeteer core version: $PUPPETEER_VERSION"
    
    # Check n8n-nodes-puppeteer
    PUPPETEER_NODE_VERSION=$(node -e "try { console.log(require('n8n-nodes-puppeteer/package.json').version); } catch(e) { console.log('not found'); }" 2>/dev/null)
    echo "n8n-nodes-puppeteer version: $PUPPETEER_NODE_VERSION"
    
    # Check custom nodes directory
    if [ -d "/opt/custom-nodes" ]; then
        echo "Custom nodes directory: EXISTS"
        echo "Custom nodes contents: $(ls -la /opt/custom-nodes 2>/dev/null || echo 'cannot list')"
    else
        echo "Custom nodes directory: NOT FOUND"
    fi
    
    echo "NODE_PATH: ${NODE_PATH:-'not set'}"
    echo "N8N_CUSTOM_EXTENSIONS: ${N8N_CUSTOM_EXTENSIONS:-'not set'}"
    echo "================================================"
}

# Set up NODE_PATH to include global modules and custom nodes
export NODE_PATH="/usr/local/lib/node_modules:/opt/custom-nodes/node_modules:${NODE_PATH}"

# Set up custom extensions path
export N8N_CUSTOM_EXTENSIONS="/opt/custom-nodes:/usr/local/lib/node_modules:${N8N_CUSTOM_EXTENSIONS}"

# Ensure Puppeteer can find Chromium
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
export CHROME_BIN=/usr/bin/chromium-browser
export CHROME_PATH=/usr/bin/chromium-browser

# Print environment information
print_banner

echo "Starting n8n..."

# Check if we're running the default n8n command
if [ "$1" = "n8n" ] || [ $# -eq 0 ]; then
    # Execute n8n with proper environment
    exec n8n start
else
    # Execute whatever command was passed
    exec "$@"
fi