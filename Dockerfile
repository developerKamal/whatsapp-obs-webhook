FROM node:20-bookworm

# Install tailscale
RUN apt-get update && apt-get install -y curl ca-certificates \
 && curl -fsSL https://tailscale.com/install.sh | sh \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000
CMD ["/start.sh"]
