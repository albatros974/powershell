write-host "============================================================================="
write-host "===============Auteur Lauboudou DIA  ========================================"
write-host "=============  Bienvenue dans le script TP1 Hyper-V =========================" 
write-host "=============  Création des Machines Virtuelles avec des disques en type differenciation ======" 
write-host "==================================================================="
write-host ""
write-host ""


$ParentPath = "C:\Hyper-V\Master\Master.vhdx"
$BaseDD = "Hote-0"
$PathBase = "C:\Hyper-V\"
$Extension = ".vhdx"


$MemoryStartupBytes= 4GB
$ProcessorCount = 2
$Generation = 2
$SwitchName = "INTERNE"

$DCName = "DC-01"
$DCPath = $PathBase+$DCName+"\"+$DCName+$Extension


write-host "=============  Création du Disque Dur $DCName ==================="
write-host "========================================================================="
write-host ""
write-host ""

write-host "Commande ====>   New-VHD -ParentPath $ParentPath -Path $DCPath -Differencing"
New-VHD -ParentPath $ParentPath -Path $DCPath -Differencing


write-host "=============  Création de la Machine Virtuelle $DCName ==================="
write-host "Commande ====>   New-VM -name $DCName -MemoryStartupBytes $MemoryStartupBytes -VHDPath $DCPath -Generation $Generation -SwitchName $SwitchName"

New-VM -name $DCName -MemoryStartupBytes $MemoryStartupBytes -VHDPath $DCPath -Generation $Generation -SwitchName $SwitchName

write-host "=============================================================================="
write-host "===========  Activer les tools (services d’invités) sur la VM $DCName =========="
write-host "=============================================================================="
write-host "Commande ====>   Enable-VMIntegrationService -VMName $DCName -Name Interface*"
write-host ""
write-host ""

Enable-VMIntegrationService -VMName $DCName -Name Interface*

write-host "===========  Modifier les CPU de la VM $DCName =========="
write-host "=============================================================================="
write-host "Commande ====>   set-vm -name $DCName -processorCount $ProcessorCount"
write-host ""
write-host ""
set-vm -name $DCName -processorCount $ProcessorCount

write-host "=============================================================================="
write-host "===========  Désactiver le checkpoint Type sur la VM $DCName  =========="
write-host ""
write-host ""
write-host "Commande ====>    set-vm -name $DCName -checkpointType Disabled"

set-vm -name $DCName -checkpointType Disabled


write-host "===================================================================================================="
write-host "=============  Création des disques et Machines Virtuelles prefixées par Hote- ==================="
write-host "===================================================================================================="

$NbDisque = Read-Host "Combien des Disques Dur souhaitez-vous créer, renseigner un nombre"
write-host "Votre choix est : $NbDisque"
write-host "=============================================================================="
For($i=1; $i -le $NbDisque; $i++) 
            { 
                     
                     $DDName = $BaseDD+$i+$Extension
                     write-host "La création du disque $DDName"
                     write-host "=============================================================================="
                     $Path= $PathBase+$BaseDD+$i+"\"+$BaseDD+$i+$Extension
		
                     write-host "Commande ====>    New-VHD -ParentPath $ParentPath -Path $Path -Differencing"
                     write-host "=============================================================================="
                     New-VHD -ParentPath $ParentPath -Path $Path -Differencing

                     $VMName = $BaseDD+$i
                    
                     write-host "La création de la Machine Virtuelle $VMName"
                     write-host "=============================================================================="
                  
                     $VHDPath = $Path
                      
                     write-host "Commande ====>    New-VM -name $VMName -MemoryStartupBytes $MemoryStartupBytes -VHDPath $VHDPath -Generation $Generation -SwitchName $SwitchName"
                     write-host ""
                     write-host ""

                     New-VM -name $VMName -MemoryStartupBytes $MemoryStartupBytes -VHDPath $VHDPath -Generation $Generation -SwitchName $SwitchName

                     write-host "=============================================================================="
                     write-host "===========  Activer les tools (services d’invités) sur la VM $VMName =========="
                     write-host "Commande ====>    Enable-VMIntegrationService -VMName $VMName -Name Interface*"
                     Enable-VMIntegrationService -VMName $VMName -Name Interface*

                     write-host ""
                     write-host ""

                     write-host "=============================================================================="
                     write-host "===========  Modifier les CPU de la VM VMName =========="
                     write-host "=============================================================================="
                     write-host "Commande ====>    set-vm -name $VMName -processorCount $ProcessorCount"
                     write-host ""
                     write-host ""

                     
                     set-vm -name $VMName -processorCount $ProcessorCount

                     write-host "=============================================================================="
                     write-host "===========  Désactiver le checkpoint Type de la VM $VMName  =========="
                     write-host "=============================================================================="
                     write-host "Commande ====>    set-vm -name $VMName -checkpointType Disabled"
                     write-host "=============================================================================="
                     
                     set-vm -name $VMName -checkpointType Disabled

            } 

  write-host ""
  write-host ""

  write-host "=================================================="
  write-host "===========  Fin de script TP1-Hyper-V1 =========="
  write-host "=================================================="



