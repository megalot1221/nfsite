#!/bin/bash
# ============================================================
# Netflix Relay – Domain: nf.kengkoy.com | Port: 8090
# ============================================================

set -e

echo "🧨 Netflix Trial Relay – nf.kengkoy.com"
echo "========================================="
echo "🌐 Domain: nf.kengkoy.com"
echo "🔌 HTTP Port: 8090"
echo "📡 WebSocket Port: 8765"

# ---- Update system ----
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# ---- Install dependencies ----
echo "🐍 Installing Python3 and pip..."
sudo apt install -y python3 python3-pip python3-venv git ufw nginx certbot python3-certbot-nginx

# ---- Create project directory ----
echo "📁 Creating project directory..."
mkdir -p /opt/netflix-relay
cd /opt/netflix-relay

# ---- Create virtual environment ----
echo "🔧 Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# ---- Install Python packages ----
echo "📥 Installing Python dependencies..."
pip install --upgrade pip
pip install fastapi uvicorn aiohttp python-multipart

# ---- Create server.py ----
echo "📝 Writing server.py (port 8090)..."
cat > server.py << 'EOF'
# PASTE THE UPDATED server.py CODE HERE
EOF

# ---- Create client.html ----
echo "📝 Writing client.html..."
cat > client.html << 'EOF'
# PASTE THE UPDATED client.html CODE HERE
EOF

# ---- Create systemd service ----
echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/netflix-relay.service > /dev/null << 'EOF'
[Unit]
Description=Netflix Trial Relay (nf.kengkoy.com)
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/netflix-relay
Environment="PATH=/opt/netflix-relay/venv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/opt/netflix-relay/venv/bin/python3 /opt/netflix-relay/server.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=netflix-relay
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# ---- Configure Nginx ----
echo "🌐 Configuring Nginx for nf.kengkoy.com..."
sudo tee /etc/nginx/sites-available/nf.kengkoy.com > /dev/null << 'EOF'
server {
    listen 80;
    server_name nf.kengkoy.com;

    location / {
        proxy_pass http://127.0.0.1:8090;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
        proxy_connect_timeout 60s;
    }

    location /ws {
        proxy_pass http://127.0.0.1:8765/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 60s;
        proxy_connect_timeout 60s;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/nf.kengkoy.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# ---- Configure firewall ----
echo "🛡️ Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8090/tcp
sudo ufw allow 8765/tcp
sudo ufw --force enable

# ---- Start the service ----
echo "🚀 Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable netflix-relay.service
sudo systemctl start netflix-relay.service

# ---- SSL Certificate (Let's Encrypt) ----
echo "🔒 Setting up SSL certificate..."
sudo certbot --nginx -d nf.kengkoy.com --non-interactive --agree-tos --email admin@kengkoy.com || echo "⚠️ SSL setup skipped (manual intervention needed)"

# ---- Check status ----
echo "✅ Deployment complete!"
echo "========================================="
echo "🌐 Domain: https://nf.kengkoy.com"
echo "🔌 HTTP Port: 8090 (internal)"
echo "📡 WebSocket: wss://nf.kengkoy.com/ws"
echo ""
echo "🔍 Check service status:"
echo "   sudo systemctl status netflix-relay"
echo ""
echo "📋 View logs:"
echo "   sudo journalctl -u netflix-relay -f"
echo ""
echo "🌍 Access the web interface:"
echo "   https://nf.kengkoy.com"
echo "========================================="