# Use the official n8n image as base
FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Install Chrome dependencies and Chromium
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    ffmpeg \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    udev \
    ttf-liberation \
    font-noto-emoji \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Set Puppeteer environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/bin/chromium-browser

# Create directory for custom nodes
RUN mkdir -p /usr/local/lib/node_modules

# Install Puppeteer and related packages globally
RUN npm install -g \
    puppeteer@21.6.1 \
    puppeteer-extra \
    puppeteer-extra-plugin-stealth \
    n8n-nodes-puppeteer \
    got-scraping \
    got \
    axios \
    cheerio \
    && npm cache clean --force

# Set up custom nodes directory
RUN mkdir -p /opt/custom-nodes && \
    cd /opt/custom-nodes && \
    npm install n8n-nodes-puppeteer puppeteer@21.6.1 && \
    chown -R node:node /opt/custom-nodes

# Copy custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown node:node /usr/local/bin/docker-entrypoint.sh

# Switch back to node user
USER node

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]