 Backup VMs
Este script Bash realiza o backup de uma máquina virtual (VM) em um servidor XenServer. Ele automatiza o processo de criação de snapshots, conversão de templates, exportação e limpeza de backups antigos. Aqui está um resumo de suas principais etapas:

Definição de Variáveis:
storagebkp: UUID do armazenamento de destino para o backup.
dhvm: Data e hora atuais para marcação de etapas.
datain: Timestamp inicial para calcular a duração do script.
vmname: Nome da VM a ser feita o backup.
bkpdestino: Caminho de destino para armazenar o backup.

Inicialização do Log:
Cria um log de backup específico para a VM.

Criação de Snapshot:
Cria um snapshot da VM especificada e registra no log.
Verifica o sucesso da operação e continua ou encerra em caso de erro.

Conversão de Snapshot para Template:
Converte o snapshot criado em um template e registra no log.
Verifica o sucesso da operação e continua ou encerra em caso de erro.

Conversão do Template para VM:
Copia o template para criar uma nova VM no armazenamento especificado.
Registra o sucesso ou erro no log.
 
Exportação da VM:
Exporta a nova VM para um arquivo .xva no caminho de destino.
Registra o sucesso ou erro no log.

Deleção da VM e VDI:
Remove a VM criada para o backup, liberando espaço.
Registra o sucesso ou erro no log.

Deleção do Snapshot:
Remove o snapshot original para liberar espaço.
Registra o sucesso ou erro no log.

Exclusão de Backups Antigos:
Mantém apenas os dois backups mais recentes, removendo os mais antigos.
Registra o sucesso ou erro no log.

Cálculo do Tempo de Execução:
Calcula o tempo total de execução do script e registra no log.

Cada etapa do script é registrada em um arquivo de log, permitindo a verificação detalhada do processo de backup e a identificação de possíveis problemas. O script é projetado para ser executado automaticamente, garantindo que backups consistentes e atualizados sejam mantidos sem intervenção manual.