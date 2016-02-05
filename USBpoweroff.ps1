$hubs = Get-WmiObject Win32_USBHub
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | where {$_.InstanceName.Contains($hubs.PNPDeviceID)}

foreach ($p in $powerMgmt)
{
    $p
    #$p.Enable = $False
    #$p.psbase.Put()
}