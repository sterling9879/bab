#!/bin/bash
# ==========================================
# Instalação do Quiz - 12 Frequências
# Para Ubuntu 22.04 VPS
# ==========================================

set -e

echo "=========================================="
echo "  INSTALAÇÃO DO QUIZ - 12 FREQUÊNCIAS"
echo "  Ubuntu 22.04 VPS"
echo "=========================================="
echo ""

# Atualizar sistema
echo "[1/4] Atualizando sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar Nginx
echo "[2/4] Instalando Nginx..."
sudo apt install -y nginx

# Configurar diretório do site
echo "[3/4] Configurando arquivos do site..."
SITE_DIR="/var/www/quiz"
sudo mkdir -p "$SITE_DIR"
sudo cp index.html "$SITE_DIR/index.html"
sudo chown -R www-data:www-data "$SITE_DIR"
sudo chmod -R 755 "$SITE_DIR"

# Configurar Nginx
echo "[4/4] Configurando Nginx..."
sudo tee /etc/nginx/sites-available/quiz > /dev/null <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/quiz;
    index index.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    # Cache de assets estáticos
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Segurança
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip
    gzip on;
    gzip_types text/plain text/css application/javascript text/html;
    gzip_min_length 1000;
}
NGINX

# Ativar site e desativar default
sudo ln -sf /etc/nginx/sites-available/quiz /etc/nginx/sites-enabled/quiz
sudo rm -f /etc/nginx/sites-enabled/default

# Testar e reiniciar Nginx
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Abrir porta 80 no firewall (se UFW estiver ativo)
if command -v ufw &> /dev/null; then
    sudo ufw allow 'Nginx Full' 2>/dev/null || true
fi

echo ""
echo "=========================================="
echo "  INSTALAÇÃO CONCLUÍDA!"
echo "=========================================="
echo ""
echo "  Acesse seu quiz em: http://$(hostname -I | awk '{print $1}')"
echo ""
echo "  Para HTTPS (recomendado), instale o Certbot:"
echo "    sudo apt install certbot python3-certbot-nginx"
echo "    sudo certbot --nginx -d seudominio.com"
echo ""
