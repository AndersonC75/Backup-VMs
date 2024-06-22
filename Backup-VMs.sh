#!/bin/bash
# Script de backup para VM's Xen-Server (VM's a QUENTE)
####################################################################################

# Define o UUID do armazenamento de backup.
storagebkp="9aee4ad3-9db2-315b-1bc6-401fea6ba74a"

# Define a data e hora atuais em um formato específico para uso nas etapas do backup.
dhvm=$(date +%d-%m-%Y_%H-%M-%S)

# Armazena a data atual em segundos desde 1970-01-01 00:00:00 UTC.
datain=$(date +%s)

# Define o nome da VM que será feita o backup.
vmname="Debian9"

# Define o caminho de destino para armazenar o backup.
bkpdestino="/mnt/backup"

# Adiciona uma linha de separação no log do backup.
echo "==============================================================================" >> /var/log/backup/vms/bkp-${vmname}.log

# Registra no log que o backup da VM está iniciando.
echo "Iniciando backup da vm ${vmname} em ${dhvm}" >> /var/log/backup/vms/bkp-${vmname}.log

# Registra a data e hora atual.
data=$(date +%c)

# Registra no log a criação de um snapshot da VM.
echo "1) Cria snapshot da maquina em ${data}." >> /var/log/backup/vms/bkp-${vmname}.log

# Cria um snapshot da VM e captura o UUID do snapshot.
idvm=$(xe vm-snapshot vm=${vmname} new-name-label=${vmname}_snapshot 2>> /var/log/backup/vms/bkp-${vmname}.log)

# Verifica se a criação do snapshot foi bem-sucedida.
if [ $? -eq 0 ]; then
    # Registra no log o sucesso da criação do snapshot e seu UUID.
    echo "Id Snapshot criado: ${idvm}" >> /var/log/backup/vms/bkp-${vmname}.log
    echo "Executou com sucesso." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkp-${vmname}.log
else
    # Registra no log que houve um problema e sai do script com código de erro.
    echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "==============================================================================" >> /var/log/backup/vms/bkp-${vmname}.log
    exit 1
fi

# Registra a data e hora atual.
data=$(date +%c)

# Registra no log a conversão do snapshot para um template.
echo "2)Convertendo o snapshot criado em template em ${data}." >> /var/log/backup/vms/bkp-${vmname}.log

# Converte o snapshot para um template.
xe template-param-set is-a-template=false uuid=${idvm} 2>> /var/log/backup/vms/bkp-${vmname}.log

# Verifica se a conversão para template foi bem-sucedida.
if [ $? -eq 0 ]; then
    echo "Executou com sucesso." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkp-${vmname}.log
else
    echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "==============================================================================" >> /var/log/backup/vms/bkp-${vmname}.log
    exit 1
fi

# Registra a data e hora atual.
data=$(date +%c)

# Registra no log a conversão do template para uma VM.
echo "3)Convertendo o template em VM em ${data}" >> /var/log/backup/vms/bkp-${vmname}.log

# Copia a VM a partir do template e armazena o UUID da nova VM criada.
cvvm=$(xe vm-copy vm=${vmname}_snapshot sr-uuid=${storagebkp} new-name-label=${vmname}_${dhvm} 2>> /var/log/backup/vms/bkp-${vmname}.log)

# Verifica se a cópia da VM foi bem-sucedida.
if [ $? -eq 0 ]; then
    echo "Executou com sucesso." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkp-${vmname}.log
else
    echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "==============================================================================" >> /var/log/backup/vms/bkp-${vmname}.log
    exit 1
fi

# Registra a data e hora atual.
data=$(date +%c)

# Registra no log a exportação da VM para um arquivo no HD externo.
echo "4)Exportando VM criada para o HD externo em ${data}." >> /var/log/backup/vms/bkp-${vmname}.log

# Exporta a VM para um arquivo .xva no destino especificado.
xe vm-export vm=${cvvm} filename="/mnt/backup/bkpvms/${vmname}/${vmname}_${dhvm}.xva" &>> /var/log/backup/vms/bkp-${vmname}.log

# Verifica se a exportação da VM foi bem-sucedida.
if [ $? -eq 0 ]; then
    echo "Executou com sucesso." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkp-${vmname}.log
else
    echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "==============================================================================" >> /var/log/backup/vms/bkp-${vmname}.log
    exit 1
fi

# Registra a data e hora atual.
data=$(date +%c)

# Registra no log a deleção da VM e seu VDI.
echo "5)Deletando VM e seu VDI criado em ${data}." >> /var/log/backup/vms/bkp-${vmname}.log

# Deleta a VM e seu VDI.
xe vm-uninstall vm=${cvvm} force=true &>> /var/log/backup/vms/bkp-${vmname}.log

# Verifica se a deleção da VM e VDI foi bem-sucedida.
if [ $? -eq 0 ]; then
    echo "Executou com sucesso." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkp-${vmname}.log
else
    echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "==============================================================================" >> /var/log/backup/vms/bkp-${vmname}.log
    exit 1
fi

# Registra a data e hora atual.
data=$(date +%c)

# Registra no log a deleção do snapshot criado anteriormente.
echo "6)Deletando Snapshot criado em ${data}." >> /var/log/backup/vms/bkp-${vmname}.log

# Deleta o snapshot.
xe vm-uninstall --force uuid=${idvm} &>> /var/log/backup/vms/bkp-${vmname}.log

# Verifica se a deleção do snapshot foi bem-sucedida.
if [ $? -eq 0 ]; then
    echo "Executou com sucesso." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkp-${vmname}.log
else
    echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "==============================================================================" >> /var/log/backup/vms/bkp-${vmname}.log
    exit 1
fi

# Registra a data e hora atual.
data=$(date +%c)

# Registra no log a exclusão de backups duplicados.
echo "7)Excluindo backups duplicados em ${data}" >> /var/log/backup/vms/bkp-${vmname}.log

# Exclui backups duplicados, mantendo apenas os dois backups mais recentes.
ls -td1 ${bkpdestino}/${vmname}/* | sed -e '1,2d' | xargs -d '\n' rm -rif &>> /var/log/backup/vms/bkp-${vmname}.log

# Verifica se a exclusão de backups duplicados foi bem-sucedida.
if [ $? -eq 0 ]; then
    echo "Executou com sucesso." >> /var/log/backup/vms/bkp-${vmname}.log
    echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkp-${vmname}.log
    echo "Backup VM ${vmname} concluido em ${data}."
