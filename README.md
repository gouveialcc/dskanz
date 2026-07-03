# ◢◤ DSKANZ - NextGen Disk Analyzer

> **Enterprise System Integrity Architecture // Disk Audit Tool**
> Uma ferramenta profissional em Shell Script para auditoria profunda, rápida e precisa de espaço em disco, utilizando a engine 100% nativa do ecossistema Linux.

[![Linux Shell](https://img.shields.io/badge/Shell-Script-brightgreen.svg?style=flat-square&logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Audit Status](https://img.shields.io/badge/Security-Root%20Required-red.svg?style=flat-square)](#-trava-de-segurança)

---

## 💻 O Projeto

O **DSKANZ** foi desenvolvido para suprir a necessidade de times de Engenharia de Infraestrutura e DevOps que precisam monitorar o consumo de storages e volumes em produção sem a possibilidade ou permissão de instalar dependências externas (como `ncdu`). 

Com uma interface moderna inspirada em painéis operacionais de alta visibilidade (*Cyberpunk Console*), o script extrai o máximo do comando nativo `du`, isolando instantaneamente os vilões de armazenamento em duas tabelas limpas de **Top 10**.

```text
 ◢██████◣   ◢██████◣ █▄  ▄█  ◢██████◣ █▄  ██ ◤███████◣
 ██  ◤═██  ███  ◤═██ ██  ██  ███  ◤═██ ███ ██   ▄▄█◤═◤
 ██    ██  ◤██████◣  ██▄▄██  █████████ ███▄██  ▄██◤    
 ██  ▄ ██  ▄▄  ◤███  ██  ██  ███  ◤═██ ██ ███ ▄██▄▄▄▄█ 
 ◥██████◤  ◥██████◤  █◤  ▀█  █◤    ▀█  █◤  ◥█ ◥███████◤
 [ ENGINE: DU NATIVE ] ───────────────────────── [ SECURITY: ROOT ]

🔥 Funcionalidades Coletadas
O DSKANZ não analisa apenas o tamanho bruto. Ele entrega contexto operacional para tomadas de decisão rápidas:

Métricas Globais de Partição: Exibe o espaço total ocupado e livre do ponto de montagem atual (df -h).

Monitoramento de Inodes: Alerta sobre a taxa de ocupação de Inodes (df -i) para evitar o travamento do SO por excesso de arquivos pequenos.

Top 10 Diretórios Recursivos: Lista as 10 pastas mais pesadas de forma hierárquica profunda, gerando uma barra de progresso em blocos sólidos (████░░░░) com cores dinâmicas baseadas em criticidade (Verde, Amarelo e Vermelho).

Top 10 Arquivos Individuais: Expõe de forma cirúrgica os maiores arquivos isolados dentro do diretório alvo (excelente para caçar dumps antigos ou logs inflados de serviços).

Exportação Inteligente de Logs: Pergunta interativamente ao operador se deseja exportar os dados. O relatório é limpo de códigos ANSI de cor, gerando um texto puro legível em qualquer plataforma e nomeado com carimbo de data, hora e caminho sanitizado dentro de /var/log/dskanz/.

🛡️ Trava de Segurança
Para garantir que o cálculo seja preciso e que o script tenha permissão de leitura em pastas críticas do sistema (como /root, /var/lib/docker ou /var/log), o script possui uma trava de segurança EUID. Ele exige privilégios de superusuário para rodar.

🚀 Como Executar
1. Clonar o projeto
git clone [https://github.com/gouveialcc/dskanz.git)
cd dskanz

2. Atribuir permissão de execução
chmod +x analisador_dskanz.sh

3. Modos de Uso
Varredura Completa do Sistema (Raiz /):
sudo ./analisador_dskanz.sh

Varredura de Diretório Específico (Ex: /var):
sudo ./analisador_dskanz.sh /var

📂 Estrutura de Logs Gerada
Ao aceitar a geração do relatório ao final do processo, a ferramenta criará o arquivo padronizado no seguinte formato:

Diretório: /var/log/dskanz/ (Se o script não tiver permissão de escrita local, gerará na pasta atual do script).

Nome do arquivo: dskanz_audit_[caminho_analisado]_[data_hora].log

Exemplo: /var/log/dskanz/dskanz_audit__var_log_20260703_084512.log

💙 Apoie este Projeto Open Source
Se este software te ajudou, considere fazer uma contribuição para ajudar a manter o desenvolvimento ativo e as atualizações de segurança:

⚡ Pix (Brasil)
Use a chave aleatória abaixo no aplicativo do seu banco: a850f586-0189-4867-bae3-93830e58dcff

₿ Bitcoin
Envie qualquer valor para o endereço oficial do projeto: bc1qr5ka6pjhtkh4rk7k4tgppy3k7svksa2nllr560wrvsjgskz3lm5qxy7f6p

Toda contribuição é opcional, direcionada integralmente à sustentabilidade técnica da ferramenta e altamente apreciada!
