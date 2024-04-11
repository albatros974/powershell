Creation d'une VM (Master)

/*activation du Hyper-V sur le machine en cas de deja installe*/
enabled-WindowsOptionalFeature -Online -FeatureName Microsoft-hyper-v-all
New-VMSwitch -name Externe -NetAdapterName WI-FI
---
/*Creation de une nouvelle machine virtuelle*/
New-VM -Name Master -SwitchName Interne -Path c:\hyperv\ -NewVHDPath c:\hyper-v\Master\Master.vhdx -NewVHDSizeBytes 200GB -MemoryStartupBytes 4GB -Generation 2
---
/*activer ou desactiver les ponits de controle - snapshot*/
Set-VM -Name Master -CheckpointType Disabled
---
/*add ou remove Processeur sur les machines*/
Set-VM -Name Master -ProcessorCount 2
---
/*mount drive dvd disque sur le machine*/
Add-VMDvdDrive -VMName Master -Path C:\ISO\fr-fr_windows_server_2022_x64_dvd_9f7d1adb.iso
---
$vmdvd = Get-VMDvdDrive -VMName Master
---
/*changer la ordre de boot - en cas par disque dvd*/
Set-VMFirmware -VMName Master -FirstBootDevice $vmdvd
---
/*activer service d'invite*/
Enable-VMIntegrationService -VMName "Master" -Name Interface*
---
/*Verifier les switches existantes*/
Get-NetAdapter
---
/*creation des switchs*/
New-VMSwitch -name MPIO1 -SwitchType Private
New-VMSwitch -name MPIO2 -SwitchType Private
New-VMSwitch -name Pulsation -SwitchType Private   
New-VMSwitch -name Interne -SwitchType Internal
New-VMSwitch -name Externe -NetAdapterName WI-FI
---
/*Format la machine*/
C:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown

/*ATT: 
ne pas aplliquer sysprep sur le machine physique - tres grave perdu de machine 
cocher lectture seule en disque*/
----
/*Creer OUs*/
New-ADOrganizationalUnit -Name Direction -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name RH -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name IT -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name Vente -Path "dc=form-it,dc=lab"


/*Creer Group*/
New-ADGroup -Name Vendeurs -Path "OU=Vente,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Directeurs -Path "OU=Direction,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Recruteurs -Path "OU=RH,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Techniciens -Path "OU=IT,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Ingenieurs -Path "OU=IT,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global

/*Creer Utilisateurs*/
/*Creer Group*/
New-ADGroup -Name Vendeurs -Path "OU=Vente,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Directeurs -Path "OU=Direction,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Recruteurs -Path "OU=RH,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Techniciens -Path "OU=IT,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -Name Ingenieurs -Path "OU=IT,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global

/*Creer Utilisateurs*/
New-ADUser -Name  "Eric Forest" -SamAccountName "forest" -Path "OU=Direction,DC=form-it,DC=lab"
New-ADUser -Name  "Richard Vachon" -SamAccountName "rvachon" -Path "OU=Direction,DC=form-it,DC=lab"
New-ADUser -Name  "Pierre Artaud" -SamAccountName "partaud" -Path "OU=IT,DC=form-it,DC=lab"
New-ADUser -Name  "Julien Garnier" -SamAccountName "jgarnier" -Path "OU=IT,DC=form-it,DC=lab"
New-ADUser -Name  "Gustave Lanois" -SamAccountName "glanois" -Path "OU=Ingenieurs,DC=form-it,DC=lab"
New-ADUser -Name  "Chris Marquis" -SamAccountName "cmarquis" -Path "OU=Ingenieurs,DC=form-it,DC=lab"
New-ADUser -Name  "Mathilde Carnot" -SamAccountName "mcarnot" -Path "OU=RH,DC=form-it,DC=lab"
New-ADUser -Name  "Kevin Marot" -SamAccountName "kmarot" -Path "OU=RH,DC=form-it,DC=lab"
New-ADUser -Name  "Clément Meunier" -SamAccountName "cmeunier" -Path "OU=Vente,DC=form-it,DC=lab"
New-ADUser -Name  "Anne Billot" -SamAccountName "abillot" -Path "OU=Vente,DC=form-it,DC=lab"

Set-ADAccountPassword -Identity forest
Set-ADAccountPassword -Identity rvachon
Set-ADAccountPassword -Identity partaud
Set-ADAccountPassword -Identity jgarnier
Set-ADAccountPassword -Identity glanois
Set-ADAccountPassword -Identity cmarquis
Set-ADAccountPassword -Identity mcarnot
Set-ADAccountPassword -Identity kmarot
Set-ADAccountPassword -Identity cmeunier
Set-ADAccountPassword -Identity abillot

Add-ADGroupMember -Identity Directeurs -Members "forest", "rvachon"
Add-ADGroupMember -Identity Techniciens -Members "partaud", "jgarnier"
Add-ADGroupMember -Identity Ingenieurs -Members "glanois", "cmarquis"
Add-ADGroupMember -Identity Recruteurs -Members "mcarnot", "kmarot"
Add-ADGroupMember -Identity Vendeurs -Members "cmeunier", "abillot"


