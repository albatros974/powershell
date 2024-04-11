#activer hyper-v
enabled-WindowsOptionalFeature -Online -FeatureName Microsoft-hyper-v-all
#verifier les cartes réseaux 
Get-NetAdapter
#création d'un switch externe
New-VMSwitch -name Externe -NetAdapterName WI-FI
#création de switch privé
New-VMSwitch -name MPIO1 -SwitchType Private
New-VMSwitch -name MPIO2 -SwitchType Private
New-VMSwitch -name Pulsation -SwitchType Private  
#création de switch interne 
New-VMSwitch -name Interne -SwitchType Internal



#Création d'une VM ( Master)

New-VM -Name Master -MemoryStartupBytes 6GB -Path c:\hyper-v\Master -NewVHDPath C:\Hyper-V\Master\Master.vhdx -Generation 2 -SwitchName interne -NewVHDSizeBytes 200GB
#Activer les services d'invité (tools)
Enable-VMIntegrationService -VMName Master -Name Interface*
#modifier le nombre de CPU
Set-VM -Name Master -ProcessorCount 2
#desactiver le point de control ( désactiver le snapshot)
Set-VM -Name Master -CheckpointType Disabled



#Procedure pour le sysprep (enlever les parametres specifique à une machine en vue de le deployer ou de le cloner )
cd C:\windows\system32\sysprep
#taper 
#.\sysprep.exe /generalize /oobe /shutdown
#ou 
C:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown


#mettre disque de Master en lecture seul (Read Only)
  #creation de disque de différenciation à partir d'un Parent

New-VHD -Path C:\Hyper-V\Hote-01\Hote-01.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing
New-VHD -Path C:\Hyper-V\Hote-02\Hote-02.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing
New-VHD -Path C:\Hyper-V\Hote-03\Hote-03.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing
New-VHD -Path C:\Hyper-V\DC-01\DC-01.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing

#creation de VMs à partir de disque de differenciation 
New-VM -Name Hote-03 -MemoryStartupBytes 6GB -Path c:\hyper-v\Hote-03 -VHDPath C:\Hyper-V\Hote-03\Hote-03.vhdx -Generation 2 -SwitchName interne
New-VM -Name Hote-02 -MemoryStartupBytes 6GB -Path c:\hyper-v\Hote-02 -VHDPath C:\Hyper-V\Hote-02\Hote-02.vhdx -Generation 2 -SwitchName interne
New-VM -Name Hote-01 -MemoryStartupBytes 6GB -Path c:\hyper-v\Hote-01 -VHDPath C:\Hyper-V\Hote-01\Hote-01.vhdx -Generation 2 -SwitchName interne
New-VM -Name DC-01 -MemoryStartupBytes 6GB -Path c:\hyper-v\DC-01 -VHDPath C:\Hyper-V\DC-01\DC-01.vhdx -Generation 2 -SwitchName interne
Enable-VMIntegrationService -VMName DC-01, Hote-01, hote-02, hote-03 -Name Interface*
Set-VM -Name DC-01, Hote-01, hote-02, hote-03 -ProcessorCount 2
Set-VM -Name DC-01, Hote-01, hote-02, hote-03 -CheckpointType Disabled

#Renommer la vm en DC-01,renommer l'utilisateur en admin,renommer la carte réseau en Interne.
#Fixer les paramètres IPs suivant pour DC
#10.144.0.1/24
#10.144.0.254
#10.144.0.1

#Installer ADDS
#promouvoir ke serveur en controlleur de domaine
#le domaine form-it.lab
#CONFIGURER LE DNS
#creer la zone de recherche inversé et le pointeur
#installer et configurer le DHCP
#plage 10.144.0.1 à 10.144.0.254
#exlusion 10.144.0.1 à 10.144.0.100 puis de 10.144.0.250 à 10.144.0.254
#passerelle 10.144.0.254
#dns 10.144.0.1
#domaine form-it-lab
#Renommer les vms ainsi que leurs cartes réseaux en HOTE-01, HOTE-02 et HOTE-03 en interne
#HOTE-01 10.144.0.10.10
#HOTE-02 10.144.0.20
#HOTE-03 10.144.30



Rename-computer DC-01
Rename-Item -Path "C:\Users\ancien_nom" -NewName "admin"
Rename-NetAdapter -Name "NomActuel" -NewName "NouveauNom"
New-NetIPAddress -InterfaceAlias "Interne" -IPAddress "10.144.0.1" -PrefixLength 24 -DefaultGateway 10.144.0.254

Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
Install-ADDSForest -DomainName form-it.lab -InstallDns:$true

Install-ADDSForest -DomainName "mondomaine.local" -DomainNetbiosName "MONDOMAINE" -DomainMode "WinThreshold" -ForestMode "WinThreshold" -InstallDns -Force
#Vérifier l'état du service AD DS :
#powershell
#Copy code
Get-Service -Name "NTDS" | Select-Object -Property DisplayName, Status
#Assurez-vous que le service est en état "Running" (en cours d'exécution).

#Vérifier l'état du service DNS :
#powershell
#Copy code
Get-Service -Name "DNS" | Select-Object -Property DisplayName, Status
#Assurez-vous que le service DNS est également en état "Running" (en cours d'exécution).

#Vérifier si le serveur est un contrôleur de domaine :
#powershell
#Copy code
Get-WindowsFeature | Where-Object {$_.Name -eq "AD-Domain-Services"} | Select-Object -Property Installed
#Assurez-vous que la valeur de la propriété "Installed" est "True" (vrai), ce qui indique que le rôle AD DS est installé.

#Vérifier si le serveur est un contrôleur de domaine :
#powershell
#Copy code
Get-ADDomainController
#Cette commande listera tous les contrôleurs de domaine disponibles dans votre domaine. Si votre serveur apparaît dans la liste, cela signifie qu'il est promu en tant que contrôleur de domaine avec succès

#CONFIGURER LE DNS
#creer la zone de recherche inversé et le pointeur
Set-DnsClientServerAddress -InterfaceAlias interne -ServerAddresses 10.144.0.1
Add-DnsServerPrimaryZone -ComputerName DC-01 -NetworkId 10.144.0.0/16 -DynamicUpdate Secure -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -Name "0.1" -PtrDomainName "DC-01.form-it.lab" -ZoneName "144.10.in-addr.arpa" -ComputerName DC-01

#Installer le rôle DHCP :
#powershell
#Copy code
Install-WindowsFeature -Name DHCP -IncludeManagementTools
#Cette commande installe le rôle DHCP ainsi que les outils de gestion associés.
install-WindowsFeature dhcp -IncludeAllSubFeature -IncludeManagementTools


#Configurer le service DHCP :
#powershell
#Copy code
Add-DhcpServerv4Scope -Name "NomScope" -StartRange 192.168.1.100 -EndRange 192.168.1.200 -SubnetMask 255.255.255.0 -LeaseDuration 8.00:00:00
#Cette commande crée une nouvelle plage d'adresses IP à distribuer par le serveur DHCP. Assurez-vous de remplacer "NomScope" par un nom de votre choix, et spécifiez les paramètres appropriés pour votre réseau, tels que les plages de démarrage et de fin d'adresses IP, le masque de sous-réseau et la durée de bail.

#configuration de hote-02
 
Rename-NetAdapter -name ethernet -NewName Interne
 
New-NetIPAddress -InterfaceAlias Interne -IPAddress 10.144.0.20 -PrefixLength 24 -DefaultGateway 10.144.0.254
 
Set-DnsClientServerAddress -InterfaceAlias Interne -ServerAddresses 10.144.0.1
Rename-Computer Hote-02
 
Add-Computer -DomainName form-it.lab -Credential admin@form-it.lab -Restart

#Voici comment spécifier la création d'une nouvelle OU à la racine du domaine :

#powershell
#Copy code
# Importer le module Active Directory
Import-Module ActiveDirectory

# Spécifier le nom de l'unité d'organisation (OU) à créer
$OUName = "MonNouvelOU"

# Spécifier le chemin complet de l'OU parente (racine du domaine)
$ParentOUPath = "DC=mondomaine,DC=local"

# Créer l'unité d'organisation
New-ADOrganizationalUnit -Name $OUName -Path $ParentOUPath
Dans cet exemple, $ParentOUPath est défini sur "DC=mondomaine,DC=local", ce qui indique que la nouvelle OU sera créée à la racine du domaine mondomaine.local.//exemple: $ParentOUPath = "DC=form-it,DC=loc".
New-AdGroup -name Vendeurs -Path "OU=Ventes,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global Universal

# Spécifier le nom de l'unité d'organisation (OU) à créer
$OUName = "MonNouvelOU"

# Spécifier le chemin complet de l'OU parente (racine du domaine)
$ParentOUPath = "DC=mondomaine,DC=local"

# Créer l'unité d'organisation
New-ADOrganizationalUnit -Name $OUName -Path $ParentOUPath
Dans cet exemple, $ParentOUPath est défini sur "DC=mondomaine,DC=local", ce qui indique que la nouvelle OU sera créée à la racine du domaine mondomaine.local.//exemple: $ParentOUPath = "DC=form-it,DC=loc".
New-AdGroup -name Vendeurs -Path "OU=Ventes,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global Universal

# Créer des groupes d'utilisateurs
New-ADGroup -name Directeurs -Path "OU=Direction,DC=form-it,DC=loc" -GroupCategory Security -GroupScope Global
New-ADGroup -name Techniciens -Path "OU=IT,DC=form-it,DC=loc" -GroupCategory Security -GroupScope Global
New-ADGroup -name Ingenieurs -Path "OU=IT,DC=form-it,DC=loc" -GroupCategory Security -GroupScope Global
New-ADGroup -name Recrureurs -Path "OU=RH,DC=form-it,DC=loc" -GroupCategory Security -GroupScope Global
New-ADGroup -name Vendeurs -Path "OU=Vente,DC=form-it,DC=loc" -GroupCategory Security -GroupScope Global

function Ajouter-UtilisateurAuGroupe {
    param(
        [string]$NomGroupe
    )

    # Demander à l'utilisateur d'entrer les informations de l'utilisateur
    $NomUtilisateur = Read-Host "Entrez le nom de l'utilisateur"
    $Prénom = Read-Host "Entrez le prénom de l'utilisateur"
    $Nom = Read-Host "Entrez le nom de famille de l'utilisateur"
    $NomDeCompte = Read-Host "Entrez le nom de compte de l'utilisateur"
    $Description = Read-Host "Entrez la description de l'utilisateur"

    # Demander à l'utilisateur de saisir le mot de passe de manière sécurisée
    $MotDePasse = Read-Host "Saisissez le mot de passe pour $NomUtilisateur" -AsSecureString

    # Créer l'utilisateur dans Active Directory
    New-ADUser -Name $NomUtilisateur -GivenName $Prénom -Surname $Nom -SamAccountName $NomDeCompte -UserPrincipalName "$NomDeCompte@domaine.local" -Description $Description -AccountPassword $MotDePasse -Enabled $true

    # Ajouter l'utilisateur au groupe dans Active Directory
    Add-ADGroupMember -Identity $NomGroupe -Members $NomDeCompte

    Write-Host "L'utilisateur $NomUtilisateur a été créé et ajouté au groupe $NomGroupe avec succès."
}

