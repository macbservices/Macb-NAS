#!/bin/bash

echo "Iniciando setup do File Browser no TrueNAS Scale com Cloudflare Tunnel..."

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar File Browser
/bin/bash -c "$(curl -fsSL https://filebrowser.org/install.sh)"

# Variáveis para File Browser
FILEBINARY=$(command -v filebrowser)
FILEB_ROOT="/mnt"  # ajuste para o dataset do TrueNAS onde ficam os arquivos

# Criar usuário system para File Browser
sudo useradd -r -s /bin/false filebrowser 2>/dev/null || true

# Criar serviço systemd para File Browser
sudo tee /etc/systemd/system/filebrowser.service > /dev/null <<EOF
[Unit]
Description=File Browser
After=network.target

[Service]
User=filebrowser
ExecStart=$FILEBINARY -r $FILEB_ROOT --no-auth=false --username=admin --password=adminpass
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable filebrowser
sudo systemctl start filebrowser

echo "File Browser instalado e rodando em http://localhost:8080 (admin / adminpass). Lembre-se de mudar a senha após o primeiro login."

# Instalar cloudflared
curl -L -o /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /usr/local/bin/cloudflared

# Perguntar domínio e nome do túnel
read -p "Informe o domínio completo para o túnel (ex: cloud.grythprogress.com.br): " DOMINIO
read -p "Informe o nome do túnel (ex: macb-nas): " NOME_TUNEL

# Login no Cloudflare via navegador
echo "Abrindo navegador para autenticar Cloudflare Tunnel..."
cloudflared tunnel login

# Criar túnel
echo "Criando túnel com o nome $NOME_TUNEL ..."
cloudflared tunnel create $NOME_TUNEL

# Capturar arquivo de credenciais automaticamente (corrigido)
ARQUIVO_CREDENCIAIS=$(ls ~/.cloudflared/*.json | head -1)
TUNNEL_ID=$(basename $ARQUIVO_CREDENCIAIS .json)

# Criar config.yml para o cloudflared
sudo tee /etc/cloudflared/config.yml > /dev/null <<EOF
tunnel: $TUNNEL_ID
credentials-file: $ARQUIVO_CREDENCIAIS

ingress:
  - hostname: $DOMINIO
    service: http://localhost:8080
  - service: http_status:404
EOF

# Mostrar instruções para configurar DNS (feito manualmente no painel Cloudflare)
echo "ATENÇÃO: Crie um registro CNAME no DNS da Cloudflare:"
echo "Nome: $DOMINIO"
echo "Aponta para: $TUNNEL_ID.cfargotunnel.com"

# Instalar serviço do cloudflared para rodar no boot
sudo cloudflared service install

sudo systemctl enable cloudflared
sudo systemctl start cloudflared

echo "Configuração concluída com sucesso!"
echo "Acesse seu File Browser via https://$DOMINIO"
echo "Use login 'admin' e senha 'adminpass' (recomendo a troca imediata)."
echo "Links públicos podem ser criados para compartilhamento, mesmo sem conta, assim como no Google Drive."
