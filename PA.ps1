# Creation de VMs en définissant leur nom à l'avance

$n = "Hote-0"

#script permettant de créer plusieurs VMs en même temps et dont le nom va s'incrémenter avec $i

For($i=1;$i -lt 4;$i++)
{
New-VM -Name $n$i -MemoryStartupBytes 4gb -Generation 2 -Path "S:\Hyper-V\$n$i" -SwitchName "Interne"
Set-VM -Name $n$i -ProcessorCount 2
Set-VM -Name $n$i -CheckPointType Disabled
Get-VMIntegrationService -VMName $n$i
Enable-VMIntegrationService -VMName $n$i -Name Interface*
Add-VMHardDiskDrive -VMName $n$i -Path "S:\Hyper-V\$n$i\$n$i.vhdx"
}
