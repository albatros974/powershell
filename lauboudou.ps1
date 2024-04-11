
//Premier fichier ps1 sur dossier gérer par git
// lauboudou.ps1


//création d'un switch externe

New-VMSwitch -name Externe -NetAdapterName WI-FI
New-VMSwitch -name MPIO1 -SwitchType Private
New-VMSwitch -name MPIO2 -SwitchType Private
New-VMSwitch -name Pulsation -SwitchType Private  
New-VMSwitch -name Interne -SwitchType Internal
