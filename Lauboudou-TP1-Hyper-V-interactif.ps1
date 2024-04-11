write-host "============================================================================="
write-host "=============  Bienvenue dans le script TP1 Hyper-V =========================" 
write-host "=============  Création des Machines Virtuelles avec les disques créés ======" 
write-host "==================================================================="
write-host ""
write-host ""


write-host "=============  Création des Disques Dur -Differencing ==================="
write-host "============================================================================="

$NbDisque = Read-Host "Combien des Disques Dur souhaitez-vous créer, renseigner un nombre"
write-host "Votre choix est : $NbDisque"
For($i=1; $i -le $NbDisque; $i++) 
            { 
                     write-host "La création du disque $i"
                     $ParentPath = Read-Host "Renseigner le ParentPath"
                     $Path= Read-Host "Renseigner le Path"

                     New-VHD -ParentPath $ParentPath -Path $Path -Differencing
                     new-VHD -ParentPath $ParentPath -Path $Path -Differencing


            } 

write-host ""
write-host "============================================================================="
write-host "=====================  Création des Machines Virtuelles ====================="
write-host "============================================================================="

$NbMV = Read-Host "Combien des Machines Virtuelles souhaitez-vous créer, renseigner un nombre"
write-host "Votre choix est : $NbMV"
For($i=1; $i -le $NbMV; $i++) 
   { 
        write-host "La création de la Machine Virtuelle $i"
        $VMName = Read-Host "Renseigner le nom de la Machine Virtuelle"
        $MemoryStartupByte s= Read-Host "Renseigner la RAM, un nombre suivi par GB"
        $VHDPath = Read-Host "Renseigner le chemin du disque dur"
        $Generation = Read-Host "Renseigner la Generation"
        $SwitchName = Read-Host "Renseigner le SwitchName"

        New-VM -name $VMName -MemoryStartupBytes $MemoryStartupBytes -VHDPath $VHDPath -Generation $Generation -SwitchName $SwitchName

        write-host "=============================================================================="
        write-host "===========  Activer les tools (services d’invités) sur la VM créée =========="
        write-host "=============================================================================="

        Enable-VMIntegrationService -VMName $VMName -Name Interface*

        write-host ""
        write-host ""

        write-host "=============================================================================="
        write-host "===========  Modifier les CPU de la VM créée =========="
        write-host "=============================================================================="
        $ProcessorCount = Read-Host "Renseigner le nombre de processorCount"
        set-vm -name $VMName -processorCount $ProcessorCount

        write-host ""
        write-host ""

        write-host "=============================================================================="
        write-host "===========  Désactiver le checkpoint Type   =========="
        write-host "=============================================================================="
        set-vm -name $VMName -checkpointType Disabled

    } 


  write-host ""
  write-host ""

  write-host "============================================================"
  write-host "===========  Fin de script TP1-Hyper-V1-interactif =========="
  write-host "============================================================"




