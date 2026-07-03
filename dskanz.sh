#!/bin/bash
# ==============================================================================
# DISK ANALYZER NEXTGEN - DSKANZ (v1.7 Enterprise Log Edition)
# Script profissional de auditoria de disco usando ferramentas 100% nativas.
# Exige privilégios de Superusuário (ROOT).
# ==============================================================================

# Cores modernas para a interface (XTerm 256 cores / ANSI)
AZUL_NEON='\033[1;36m'
ROXO='\033[1;35m'
VERDE_SUCESSO='\033[1;32m'
AMARELO_ALERTA='\033[1;33m'
VERMELHO_ERRO='\033[1;31m'
RESET='\033[0m'

# [TRAVA DE SEGURANÇA] Verifica se o usuário é ROOT ou está via SUDO
if [ "$EUID" -ne 0 ]; then
    echo -e "${VERMELHO_ERRO}◢◤ [ERRO ACESSO NEGADO]: Este script exige privilegios de ROOT."
    echo -e "Por favor, execute novamente utilizando: sudo $0${RESET}"
    exit 1
fi

# Diretório alvo (padrão é a raiz '/' se nenhum for passado)
TARGET_DIR="${1:-/}"

# Verifica se o diretório existe
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${VERMELHO_ERRO}◢◤ [ERRO] Diretorio '$TARGET_DIR' nao encontrado.${RESET}"
    exit 1
fi

# Resolve o caminho absoluto
ABS_PATH=$(cd "$TARGET_DIR" && pwd)

# Coleta de métricas antes de limpar a tela
DISK_INFO=$(df -h "$ABS_PATH" | tail -n 1)
PART_USAGE=$(echo "$DISK_INFO" | awk '{print $5}')
PART_FREE=$(echo "$DISK_INFO" | awk '{print $4}')
INODE_USAGE=$(df -i "$ABS_PATH" | tail -n 1 | awk '{print $5}')

clear
# Renderização da Logo Escolhida
echo -e "${AZUL_NEON}"
echo " ◢██████◣   ◢██████◣ █▄  ▄█  ◢██████◣ █▄  ██ ◤███████◣"
echo " ██  ◤═██  ███  ◤═██ ██  ██  ███  ◤═██ ███ ██   ▄▄█◤═◤"
echo " ██    ██  ◤██████◣  ██▄▄██  █████████ ███▄██  ▄██◤    "
echo " ██  ▄ ██  ▄▄  ◤███  ██  ██  ███  ◤═██ ██ ███ ▄██▄▄▄▄█ "
echo " ◥██████◤  ◥██████◤  █◤  ▀█  █◤    ▀█  █◤  ◥█ ◥███████◤"
echo -e " [ ENGINE: DU NATIVE ] ───────────────────────── [ SECURITY: ROOT ]${RESET}"

echo -e "\n${ROXO}▪ OPERATING SYSTEM ..: $(uname -s -r)"
echo -e "▪ TARGET PATH .......: ${AZUL_NEON}$ABS_PATH${ROXO}"
echo -e "▪ METRICAS DO DISCO .: Global: $PART_USAGE ocupado ($PART_FREE livre) | Inodes: $INODE_USAGE"
echo -e "▪ TIMESTAMP .........: $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo -e "${AZUL_NEON}═◢◤ LOADING AUDIT DATA ═════════════════════════════════════════${RESET}"
echo -e "${AMARELO_ALERTA}[!] Executando varredura profunda... Por favor, aguarde.${RESET}\n"

# Criar arquivos temporários seguros
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Captura o espaço total ocupado no diretório base para cálculo de porcentagem
TOTAL_KB=$(du -sk "$ABS_PATH" 2>/dev/null | cut -f1)
if [ -z "$TOTAL_KB" ] || [ "$TOTAL_KB" -eq 0 ]; then
    TOTAL_KB=1
fi

# --- FUNÇÃO AUXILIAR PARA FORMATAR TAMANHO ---
format_size() {
    local -i KB_VAL=$1
    if [ "$KB_VAL" -ge 1048576 ]; then
        printf "%.1fG" $(echo "scale=2; $KB_VAL/1048576" | bc -l)
    elif [ "$KB_VAL" -ge 1024 ]; then
        printf "%.1fM" $(echo "scale=2; $KB_VAL/1024" | bc -l)
    else
        echo "${KB_VAL}K"
    fi
}

# Criamos uma função de renderização para facilitar a exportação do log depois
render_report() {
    echo "◢◤ TOP 10 MAIORES DIRETÓRIOS RECURSIVOS ─────────────────────────"
    echo "  TAMANHO     PORCENTAGEM    GRAFICO (BARRA)             CAMINHO DO DIRETÓRIO"
    echo "─────────────────────────────────────────────────────────────────"

    while read -r line; do
        [ -z "$line" ] && continue
        DIR_KB=$(echo "$line" | awk '{print $1}')
        DIR_PATH=$(echo "$line" | cut -f2-)

        PCT=$(( 100 * DIR_KB / TOTAL_KB ))
        [ $PCT -gt 100 ] && PCT=100

        SIZE_STR=$(format_size "$DIR_KB")

        NUM_CHARS=$(( PCT / 5 ))
        BAR=""
        for ((i=0; i<20; i++)); do
            if [ $i -lt $NUM_CHARS ]; then BAR="${BAR}█"; else BAR="${BAR}░"; fi
        done

        printf "  %-10s  %-11s    [%-20s]    %-s\n" "$SIZE_STR" "$PCT%" "$BAR" "$DIR_PATH"
    done < "$TMP_DIR/dirs.txt"

    echo ""
    echo "◢◤ TOP 10 MAIORES ARQUIVOS INDIVIDUAIS ─────────────────────────"
    echo "  TAMANHO     CAMINHO COMPLETO DO ARQUIVO"
    echo "─────────────────────────────────────────────────────────────────"

    while read -r line; do
        [ -z "$line" ] && continue
        FILE_BYTES=$(echo "$line" | awk '{print $1}')
        FILE_PATH=$(echo "$line" | cut -f2-)
        FILE_KB=$((FILE_BYTES / 1024))
        
        SIZE_STR=$(format_size "$FILE_KB")

        printf "  %-10s  %s\n" "$SIZE_STR" "$FILE_PATH"
    done < "$TMP_DIR/files.txt"

    TOTAL_HUMAN=$(du -sh "$ABS_PATH" 2>/dev/null | awk '{print $1}')
    echo "─────────────────────────────────────────────────────────────────"
    echo "  ESPACO TOTAL ALOCADO NESTA PASTA : $TOTAL_HUMAN"
    echo "  STATUS DO PROCESSO .............. : EXECUÇÃO CONCLUÍDA COM SUCESSO"
    echo "═════════════════════════════════════════════════════════════════"
}

# Alimenta os arquivos temporários com os dados brutos processados
du -xk "$ABS_PATH" 2>/dev/null | grep -v "^[0-9]*\s\+$ABS_PATH$" | sort -rn | head -n 10 > "$TMP_DIR/dirs.txt"
find "$ABS_PATH" -type f -printf "%s\t%p\n" 2>/dev/null | sort -rn | head -n 10 > "$TMP_DIR/files.txt"

# Exibe o relatório na tela aplicando as cores dinâmicas (com sed inserindo as cores ANSI na função genérica)
render_report | sed \
    -e "s/\(.*%[[:space:]]\+\[████████████████████\].*\)/$(echo -e $VERMELHO_ERRO)\1$(echo -e $RESET)/" \
    -e "s/\(.*%[[:space:]]\+\[███████.*\)/$(echo -e $VERMELHO_ERRO)\1$(echo -e $RESET)/" \
    -e "s/\(.*%[[:space:]]\+\[████.*\)/$(echo -e $AMARELO_ALERTA)\1$(echo -e $RESET)/" \
    -e "s/\(.*%[[:space:]]\+\[█.*\)/$(echo -e $VERDE_SUCESSO)\1$(echo -e $RESET)/" \
    -e "s/\(◢◤.*\)/$(echo -e $AZUL_NEON)\1$(echo -e $RESET)/" \
    -e "s/\(═══.*\)/$(echo -e $AZUL_NEON)\1$(echo -e $RESET)/" \
    -e "s/\(───.*\)/$(echo -e $AZUL_NEON)\1$(echo -e $RESET)/" \
    -e "s/\(  ESPACO TOTAL.*\)/$(echo -e $VERDE_SUCESSO)\1$(echo -e $RESET)/" \
    -e "s/\(  STATUS DO.*\)/$(echo -e $VERDE_SUCESSO)\1$(echo -e $RESET)/"

echo ""
# --- NOVA INTERAÇÃO COM O OPERADOR ---
read -p " Deseja gerar um relatório? [s/N]: " RESP
echo ""

if [[ "$RESP" =~ ^[Ss]$ ]]; then
    # Define a pasta de logs padrão da TI ou cai para o diretório atual se falhar
    LOG_DIR="/var/log/dskanz"
    mkdir -p "$LOG_DIR" 2>/dev/null || LOG_DIR="."
    
    SANITISED_NAME=$(echo "$ABS_PATH" | tr '/' '_')
    LOG_FILE="$LOG_DIR/dskanz_audit_${SANITISED_NAME}_$(date '+%Y%m%d_%H%M%S').log"
    
    # Monta o arquivo de texto limpo para leitura imediata (sem caracteres especiais de cor)
    {
        echo "================================================================="
        echo "           DSKANZ SYSTEM AUDIT LOG - REPORT FILE                 "
        echo "================================================================="
        echo " OS VERSION : $(uname -s -r)"
        echo " AUDIT PATH : $ABS_PATH"
        echo " DISK STATS : Global: $PART_USAGE | Free: $PART_FREE | Inodes: $INODE_USAGE"
        echo " LOG DATE   : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "================================================================="
        echo ""
        render_report
    } > "$LOG_FILE"
    
    echo -e " ${VERDE_SUCESSO}[✓] Relatório salvo com sucesso em:${RESET}"
    echo -e " ${AZUL_NEON}$LOG_FILE${RESET}\n"
else
    echo -e " ${AMARELO_ALERTA}[!] Relatório descartado pelo operador.${RESET}\n"
fi
