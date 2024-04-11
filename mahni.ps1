§§§§ Aller dans windows de la machine virtuelle en pas de l'ecran click droit§§§

renommer la machine
renommer l'administrateur en admin
installer les tools
fixer les parametres ip suivants:  
d
 !§§POUR ALLER SUR LA CARTE RESEAU TAPER cnpa ou sur le serveur local  on va aller à etHernet 0 double click puis parametre et choisir protocole internet version 4 TCP/IPV4 EN CLICKANT 2fois

192.168.8.240/24
192.168.8.240 
192.168.8.241

§§§ renommer la machine
rename-computer DC-01

rename-LocalUser administrateur -NewName Admin
restart-computer


INSTALLER LES TOOLS
§
Aller sur vm pour installer les tools: lancer l'executable "instaal vmware tools
d:.\setup.exe /s /v /qn

Aller dans le tableau de bord puis ajouter des roles et des fonctionalités svt puis svt en selectionne "servises AD DS"puis svt svt et installer

AD: action directory qui est l'admin qui gere toute les machines . il repose sur le DNS
serveur autonome : sever qui fait  parti d'1 groupe de travail
serveur membre :  il depend de controlleur de domaine
serveur controlleur de domaine: depuis lequel le domaine est controller

foret : un ensemble de domaine

après redemmarage de la machine , on reprend la carte reseau ethernet depuis seveur local et changer les adress de DNS CAR NE SONT PAS LES BONNE ADRESSE 

CONFIGURER SEVICE DHCP mais il faut l'installer pour cela:
tableau de bord_  ajouter des roles et fonctionalité_svt...svt puis selectionner service DHCP
APRES INSTALLATION  IL FAUT TRERMINER 




Zonne principale: où peut ecrire , suprimer, ce qu'on veut 
zonne secondaire 2 ou 3 serveur , on ne peut pas apporter de modification (contient que des copie de la zone principale)
zone stub : ne fait pas de modification , comme un intermidière avec le boss;recoit des infos à faire moter au responsble

Eentuedu de  la zone

ID reseau normalement 192.168.8 mais je ne renseigne pas le 8 pour la reseau des Vlan

mise à niveau dinamyque il faut 

Zone de recherche Direct :resoudre le nom à une adresse IP Zone indirect fait l'inverse




08/04/2024  Script windows
 Hyper-V

Commutateur privé : est ioslé, que les VM qui se connectent entre EUX
Commutateur interne: connetion machnie physique et VW (reseau privé)
Commutateur externe:reseau local (imprémante....)

Exercice:
installer les carte reseau:



MPI01           Privé
MPI02           Privé
PULSATION       Privé
EXTERNE         Externe
INTERNE         Interne

commande pour installer EXTERNE 
 Get-NetAdapter pour obtenir le nom de wifi mon cas "WI-FI 2
New-VMSwitch -Name Externe -NetAdapterName "WI-FI 2"

Commande pour privé et interne 
 New-VMSwitch -Name MPI01 -SwitchType Private
 ******************MP02**********************
*******************pULSATION*****************
 New-VMSwitch -Name Interne -SwitchType Internal

Choisir le nbr de processeur 
désactivze les point de control
Activer les tools dans activer les services d'integrations en cochant "sevice d'invité"



exo:
SUR powershell Installer une machie avec les paramètres suivant:

DC-01
200G
INTERNE SWITCH
GENERATION 2
ISO 2022
mp:P@ssw0rd

SOLUTION/
INSTALLATION DE LA MACHINE

 New-VM -Name "DC-01" -SwitchName Iterne -Path C:\Hyper-v\ -NewVHDPath C:\Hyper-v\DC-01\DC-01.vhdx -NewVHDSizeBytes 200GB -MemoryStartupBytes 4GB -Generation 2

Choisir le nbr de processeur 
set-VM -Name DC-01 -ProcessorCount 2


 sedésactivze les point de control
t-VM -Name DC-01 -CheckpointType Disabled

chemin de l'iso:
Add-VMDvdDrive -VMName DC-01 -Path 'C:\Users\g2r\Desktop\iso\windows 2022.iso'

varialbe pour dire où mettre l'iso
$vmdvd = Get-VMDvdDrive -VMName DC-01

booter sur dvdrive:
 Set-VMFirmware -VMName DC-01 -FirstBootDevice $vmdvd

Istaller une MV MASTER  les meme commande utilisés pour installer MV DC-01
commande pour activer SERVICE D'INVITE pour la vm Masr
 Enable-VMIntegrationService -VMName "Master" -Name Interface*
*************************************"DC-01"*****************

double click sur la DC-01 puis sur demmarer et appuis sur une touche plusieurs fois

EXO:
etteindre la VM DC-01
travailler sur la machine MASTER
sysprep: C:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown
ATTENTION: NE PAS APPLIQUER SUR LA MACHINE PHYSIQUE


EXO:
Creer 04 VMs à partir de master
DC-01
Hote-01
Hote-02
Hote-03

1/ INSTALLATION DE DISK
 New-VHD -Path C:\Hyper-V\DC-01\DC-01.vhdx -ParentPath c:\hyper-v\master\master.vhdx -Differencing
IL suffit de changer le nom de disk

2/INSTALLATION DES MACHINES
 New-VM -Name Hote-03 -MemoryStartupBytes 6GB -Path c:\hyper-v\Hote-03 -VHDPath C:\Hyper-V\Hote-03\Hote-03.vhdx -Generation 2 -SwitchName interne

Enable-VMIntegrationService -VMName DC-01, Hote-01, hote-02, hote-03 -Name Interface*
set-VM -Name DC-01, Hote-01,  Hote-02,  Hote-03 -ProcessorCount 2

09/04/2024

DC-01
renommer l'utilisateur en admin
renommer la carte reseau en interne et renommer la VM en DC-01
redemarrer la vm
fixer les paramètres IP suivant:
10.144.01/24
10.144.0.1
INSTALL ADDS


Rename-Computer DC-01

Get-NetAdapter POUR TOUVER LE NOM DE LA CARTE RESEAU EXISTANT

 RENOMER LA CARTE RESEAU
Rename-NetAdapter -name ethernet -NewName Interne

RENOMMER L'UTILISATEUR;
Rename-LocalUser administrateur -NewName Admin

fixer les adresse IP avec le masque et la passrelle par defaut:
New-NetIPAddress -InterfaceAlias interne -IPAddress 10.144.0.1 -PrefixLength 24 -DefaultGateway 10.144.0.254

adresse ip DNS
Set-DnsClientServerAddress -InterfaceAlias interne -ServerAddresses 10.144.0.1

install de ADDS:

Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools



//UR LES FONCTIONNALITES:
Get-WndowsFature

Install WindowsFeature //



Promouvoir le serveur en controlleur de domaine
le domaine form-it.lab  :  Install-ADDSForest -DomainName form-it.lab -InstallDns:$true

configurer le DNS  : Set-DnsClientServerAddress -InterfaceAlias interne -ServerAddresses 10.144.0.1  //127.0.0.1 ip localost  pointer sur lui meme //

creer la zone de recherche inversée : 
  Add-DnsServerPrimaryZone -ComputerName DC-01 -NetworkId 10.144.0.0/16 -DynamicUpdate Secure -ReplicationScope Domain

le pointeur:

Add-DnsServerResourceRecordPtr -Name "0.1" -PtrDomainName "DC-01.form-it.lab" -ZoneName "144.10.in-addr.arpa" -ComputerName DC-01


installer et configurer le DHCP:


plage 10.144.0.1 à 10.144.0.254
exclusion 10.144.0.1 à 10.144.0.100 puis de 10.144.0.250 à 10.144.0.254
passerelle 10.144.0.254
dns
10.144.0.1
domaine form-it-lab





exo:

Renommer les VM ainsi que leurs cartes réseaux Hote-01, Hote-02, Hote-03

Hote-01      10.144.0.10
Hote-02      10.144.0.20
Hote-03      10.144.0.30

Il faut tous les joindre dan le domaine

cration des OU :

New-ADOrganizationalUnit -Name IT -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name Vente -Path "dc=form-it,dc=lab"
 
New-ADOrganizationalUnit -Name Direction -Path "dc=form-it,dc=lab"
 
New-ADOrganizationalUnit -Name RH -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name IT -Path "dc=form-it,dc=lab"
New-ADOrganizationalUnit -Name Vente -Path "dc=form-it,dc=lab"
 
New-ADOrganizationalUnit -Name Direction -Path "dc=form-it,dc=lab"
 
New-ADOrganizationalUnit -Name RH -Path "dc=form-it,dc=lab"


New-ADGroup -name Directeurs -Path "OU=Direction,DC=form-it,DC=lab" -GroupCategory Security -GroupScope Global
New-ADGroup -name Techniciens -Path "OU=IT,DC=form-it,DC=lab" -



