#!/bin/bash

# Define cores para output no terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Função para exibir mensagens de erro
error_message() {
  echo -e "${RED}Erro: $1${NC}"
}

# Função para exibir mensagens de sucesso
success_message() {
  echo -e "${GREEN}Sucesso: $1${NC}"
}

# Obtém o ano atual
ano_atual=$(date +%Y)

# Cria o diretório base com o ano atual
mkdir "/home/allansousa/$ano_atual" || { error_message "Erro ao criar diretório base para o ano atual"; exit 1; }

# Array com os nomes dos meses
meses=("janeiro" "fevereiro" "março" "abril" "maio" "junho" "julho" "agosto" "setembro" "outubro" "novembro" "dezembro")

# Cria os diretórios dos meses e os subdiretórios de backup
for mes in "${meses[@]}"; do
  mkdir "/home/allansousa/$ano_atual/$mes" || { error_message "Erro ao criar diretório para o mês $mes"; continue; }
  mkdir "/home/allansousa/$ano_atual/$mes/backup-aplicacoes" || { error_message "Erro ao criar subdiretório backup-aplicacoes em $mes"; continue; }
  mkdir "/home/allansousa/$ano_atual/$mes/backup-banco-de-dados" || { error_message "Erro ao criar subdiretório backup-banco-de-dados em $mes"; continue; }
done

# Obtém a data atual no formato dia-mês-ano
data_atual=$(date +%d-%m-%Y)

# Diretório dos sites
site_dir="/var/www/html"

# Verifica se os diretórios dos sites existem
if [ ! -d "$site_dir/site-institucional-dev" ]; then
  error_message "Diretório '$site_dir/site-institucional-dev' não encontrado."
  exit 1
fi

if [ ! -d "$site_dir/site-institucional-qas" ]; then
  error_message "Diretório '$site_dir/site-institucional-qas' não encontrado."
  exit 1
fi

# Comprime os diretórios dos sites
tar -czvf "site-institucional-dev_$data_atual.tar.gz" "$site_dir/site-institucional-dev" || { error_message "Erro ao comprimir o diretório site-institucional-dev"; exit 1; }
success_message "Diretório '$site_dir/site-institucional-dev' comprimido com sucesso."

tar -czvf "site-institucional-qas_$data_atual.tar.gz" "$site_dir/site-institucional-qas" || { error_message "Erro ao comprimir o diretório site-institucional-qas"; exit 1; }
success_message "Diretório '$site_dir/site-institucional-qas' comprimido com sucesso."

# Cria o diretório de logs, caso não exista
mkdir -p /home/allansousa/logs-backups || { error_message "Erro ao criar diretório de logs"; exit 1; }

# Cria o arquivo de log backup-aplicacao.log
touch /home/allansousa/logs-backups/backup-aplicacao.log || { error_message "Erro ao criar arquivo de log"; exit 1; }

# Função para mover os arquivos comprimidos
mover_backup() {
  mes_atual=$(date +%B)
  mv "site-institucional-dev_$data_atual.tar.gz" "/home/allansousa/$ano_atual/$mes_atual/backup-aplicacoes/" || { error_message "Erro ao mover o backup do site-institucional-dev"; return 1; }
  mv "site-institucional-qas_$data_atual.tar.gz" "/home/allansousa/$ano_atual/$mes_atual/backup-aplicacoes/" || { error_message "Erro ao mover o backup do site-institucional-qas"; return 1; }
  success_message "Arquivos de backup movidos com sucesso para /home/allansousa/$ano_atual/$mes_atual/backup-aplicacoes"
}

# Chama a função para mover os arquivos
mover_backup

# Registra no log
echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup dos sites realizado com sucesso." >> /home/allansousa/logs-backups/backup-aplicacao.log