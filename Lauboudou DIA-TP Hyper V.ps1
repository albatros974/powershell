//10/04/2024

//TP Projet Hyper V

//G2R –Formation DevOps
//La création des Switchs Virtuels
New-VMSwitch -name MPOI1 -SwitchType Private
New-VMSwitch -name MPOI2 -SwitchType Private
New-VMSwitch -name PULSATION -SwitchType Private
New-VMSwitch -name INTERNE -SwitchType Internal
New-VMSwitch -name EXTERNE -NetAdapterName wi-Fi

//Créer la VM Master 
New-VM -name Master -MemoryStartupBytes 4GB -NewVHDSizeBytes 200GB -NewVHDPath C:\Hyper-V\Master\Master.vhdx -Generation 2 -Switch INTERNE

set-vm -name Master -processorCount 2
set-vm -name Master -checkpointType Disabled
Enable-VMIntegrationService -VMName "Master" -Name Interface*

Add-VMDvdDrive -VMName Master -Path C:\Users\admin\Downloads\Windows-Server-2022-EVAL_x64FRE_fr-fr.iso
$vmdvd = Get-VMDvdDrive -VMName Master
Set-VMFirmware -VMName Master -FirstBootDevice $vmdvd
 

//Désinstaller le SID de la MV Master
cd C:\windows\system32\sysprep\
.\sysprep.exe /generalize /oobe /shutdown
 

//Créer 4 disques en différenciation à partir d’un parent master 

New-VHD -ParentPath C:\Hyper-V\Master\Master.vhdx -Path C:\Hyper-V\DC-01\DC-01.vhdx -Differencing
New-VHD -ParentPath C:\Hyper-V\Master\Master.vhdx -Path C:\Hyper-V\Hote-01\Hote-01.vhdx -Differencing
New-VHD -ParentPath C:\Hyper-V\Master\Master.vhdx -Path C:\Hyper-V\Hote-02\Hote-02.vhdx -Differencing
New-VHD -ParentPath C:\Hyper-V\Master\Master.vhdx -Path C:\Hyper-V\Hote-03\Hote-03.vhdx -Differencing

//Créer  4 VMs qui les utilisent les disques durs créés précédemment

New-VM -name DC-01 -MemoryStartupBytes 4GB -VHDPath C:\Hyper-V\DC-01\DC-01.vhdx -Generation 2 -SwitchName INTERNE
New-VM -name Hote-01 -MemoryStartupBytes 4GB -VHDPath C:\Hyper-V\Hote-01\Hote-01.vhdx -Generation 2 -SwitchName INTERNE
New-VM -name Hote-02 -MemoryStartupBytes 4GB -VHDPath C:\Hyper-V\Hote-02\Hote-02.vhdx -Generation 2 -SwitchName INTERNE
New-VM -name Hote-03 -MemoryStartupBytes 4GB -VHDPath C:\Hyper-V\Hote-03\Hote-03.vhdx -Generation 2 -SwitchName INTERNE

 
//Fixer ses parameters pour les VMs DC-01, Hote-01, Hote-02 et Hote-03

Enable-VMIntegrationService -VMName DC-01, Hote-01, hote-02, hote-03 -Name Interface*
Set-VM -Name DC-01, Hote-01, hote-02, hote-03 -ProcessorCount 2
Set-VM -Name DC-01, Hote-01, hote-02, hote-03 -CheckpointType Disabled

//Se connecter sur la machine DC-01
Rename-Computer DC-01

//Renommer la carte Ethernet en Interne
Rename-NetAdapter -name ethernet -NewName Interne

//Renommer l'utilisateur Administrateur en Admin
Restart-Computer

//Fixer les paramètres IPs sur la VM DC-01
New-NetIPAddress -InterfaceAlias interne -IPAddress 10.144.0.1 -PrefixLength 24 -DefaultGateway 10.144.0.254
Set-DnsClientServerAddress -InterfaceAlias interne -ServerAddresses 10.144.0.1

//Installer le ADDS (Active Directory Domain Services)
Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

//Promouvoir et configurer le serveur DC-01 en controlleur de domain
// domain = form-it.lab
Install-ADDSForest -DomainName form-it.lab -InstallDns:$true
Set-DnsClientServerAddress -InterfaceAlias interne -ServerAddresses 10.144.0.1
 
//Configurer  le PrimaryZone avec une plage d’@IP et créer la zone de recherche inversée et le pointeur
Add-DnsServerPrimaryZone -ComputerName DC-01 -NetworkId 10.144.0.0/16 -DynamicUpdate Secure -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -Name "0.1" -PtrDomainName "DC-01.form-it.lab" -ZoneName "144.10.in-addr.arpa" -ComputerName DC-01
 

//Installer et configurer le DHCP (Dynamic Host Configuration Protocol)
install-WindowsFeature dhcp -IncludeAllSubFeature -IncludeManagementTools
 
//La configuration des utilisateurs sur DC-01
//Créer les OU, Groupes, Utilisateurs
 
//Création des OU
New-ADOrganizationalUnit -Name IT -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name Vente -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name Direction -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name RH -Path "dc=form-it,dc=lab"

//Création des Groupes

New-ADGroup -Name Directeurs -Path "OU=Direction,dc=form-it,dc=lab" -GroupCategory Security -GroupScope Global  
New-ADGroup -Name Techniciens -Path "OU=IT,dc=form-it,dc=lab" -GroupCategory Security -GroupScope Global        
New-ADGroup -Name Ingénieurs -Path "OU=IT,dc=form-it,dc=lab" -GroupCategory Security -GroupScope Global        
New-ADGroup -Name Recruteurs -Path "OU=RH,dc=form-it,dc=lab" -GroupCategory Security -GroupScope Global         
New-ADGroup -Name Vendeurs -Path "OU=Vente,dc=form-it,dc=lab" -GroupCategory Security -GroupScope Global    

//Création des utilisateurs
//Exécuter les commandes New-ADUser puis 
//la commande Add-AdGroupMember pour insérer les membres dans un Groupe

//Ajouter les utilisateurs du groupe Directeurs

New-ADUser -Name "Forest Éric" -GivenName "Éric" -Surname "Forest" -SamAccountName "forest" -Path "OU=Direction,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

New-ADUser -Name "Vachon Richard" -GivenName "Richard" -Surname "Vachon" -SamAccountName "rvachon" -Path "OU=Direction,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true    
   
Add-AdGroupMember -Identity "Directeurs" -Members forest, rvachon


//Ajouter les utilisateurs du groupe Techniciens

New-ADUser -Name "Artaud Pierre" -GivenName "Pierre" -Surname "Artaud" -SamAccountName "partaud" -Path "OU=IT,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

New-ADUser -Name "Garnier Julien" -GivenName "Julien" -Surname "Garnier" -SamAccountName "jgarnier" -Path "OU=IT,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

Add-AdGroupMember -Identity "Techniciens" -Members partaud, jgarnier


//Ajouter les utilisateurs du groupe Ingénieurs

New-ADUser -Name "Lanois Gustave" -GivenName "Lanois" -Surname "Gustave" -SamAccountName "glanois" -Path "OU=IT,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

New-ADUser -Name "Marquis Chris" -GivenName "Chris" -Surname "Marquis" -SamAccountName "cmarquis" -Path "OU=IT,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

Add-AdGroupMember -Identity "Ingénieurs" -Members glanois, cmarquis


//Ajouter les utilisateurs du groupe Recruteurs

New-ADUser -Name "Carnot Mathilde" -GivenName "Mathilde" -Surname "Carnot" -SamAccountName "mcarnot" -Path "OU=RH,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

New-ADUser -Name "Marot Kevin" -GivenName "Kevin" -Surname "Marot" -SamAccountName "kmarot" -Path "OU=RH,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

Add-AdGroupMember -Identity "Recruteurs" -Members mcarnot, kmarot


//Ajouter les utilisateurs du groupe Vendeurs

New-ADUser -Name "Meunier Clément" -GivenName "Clément" -Surname "Meunier" -SamAccountName "cmeunier" -Path "OU=Vente,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

New-ADUser -Name "Billot Anne" -GivenName "Anne" -Surname "Billot" -SamAccountName "abillot" -Path "OU=Vente,DC=form-it,DC=lab" -AccountPassword(Read-Host -AsSecureString "Mot de passe ?") -ChangePasswordAtLogon $true -Enabled $true

Add-AdGroupMember -Identity "Vendeurs" -Members cmeunier, abillot



//Configuration de Hote-01
//Se connecter à Hote-01
Rename-NetAdapter -name ethernet -NewName Interne
New-NetIPAddress -InterfaceAlias Interne -IPAddress 10.144.0.10 -PrefixLength 24 -DefaultGateway 10.144.0.254
Set-DnsClientServerAddress -InterfaceAlias Interne -ServerAddresses 10.144.0.1
Rename-Computer Hote-01
Add-Computer -DomainName form-it.lab -Credential admin@form-it.lab -Restart

 
//Configuration de Hote-02
//Se connecter à Hote-02 : démarrage en ligne de commande Start-VM –name Hote-02
Rename-NetAdapter -name ethernet -NewName Interne
New-NetIPAddress -InterfaceAlias Interne -IPAddress 10.144.0.20 -PrefixLength 24 -DefaultGateway 10.144.0.254
Set-DnsClientServerAddress -InterfaceAlias Interne -ServerAddresses 10.144.0.1
Rename-Computer Hote-02
Add-Computer -DomainName form-it.lab -Credential admin@form-it.lab -Restart

 
//Configuration de Hote-03
Rename-NetAdapter -name ethernet -NewName Interne
New-NetIPAddress -InterfaceAlias Interne -IPAddress 10.144.0.30 -PrefixLength 24 -DefaultGateway 10.144.0.254
Set-DnsClientServerAddress -InterfaceAlias Interne -ServerAddresses 10.144.0.1
Rename-Computer Hote-03
Add-Computer -DomainName form-it.lab -Credential admin@form-it.lab -Restart

 
//Configuration des switchs

Set-VMSwitch -Name MPOI1 -AllowManagementOS $true
Set-VMSwitch -Name MPOI2 -AllowManagementOS $true
Set-VMSwitch -Name MPOI3 -AllowManagementOS $true

Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName MPOI1 -Access -VlanId 2

