# Macb-NAS

Este projeto automatiza a instalação do File Browser no TrueNAS Scale e a criação de um túnel Cloudflare para acesso remoto seguro, usando domínio e nome de túnel configuráveis na execução do script.

## Como usar

1. Acesse seu TrueNAS Scale via terminal raiz (root).
2. Execute o comando para iniciar a instalação automática:

´´´bash
bash <(curl -sSL https://raw.githubusercontent.com/macbservices/Macb-NAS/main/setup.sh)


3. Informe o domínio completo (ex: cloud.grythprogress.com.br) e o nome do túnel (ex: macb-nas) quando solicitado.
4. Faça login na Cloudflare a partir do navegador que abrirá para autenticação.
5. Após o script finalizar, configure um registro CNAME no painel DNS da Cloudflare apontando o seu domínio para o túnel.
6. Acesse seu File Browser via https://seu-dominio

## Segurança

- O File Browser exige login com usuário e senha para acessar os arquivos.
- É possível criar links públicos para compartilhamento, sem necessidade de conta.
- O acesso externo é feito via túnel Cloudflare, sem expor IP público.

---

Autor e dono do projeto: macbservices  
Repositório: https://github.com/macbservices/Macb-NAS

---

Se tiver dúvidas ou sugestões, abra uma issue no repositório.

