#
# metric-windows-disk-usage
#
# DESCRIPTION:
#   Retrieve disk usage stats
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2017 Netsmart Technologies
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#
$compName = [System.Net.Dns]::GetHostName()
$compDomain = (Get-WmiObject Win32_ComputerSystem).Domain
$hostnameFqdn = $compName.toLower() + "." + $compDomain.toLower()

$allDisks = Get-WMIObject Win32_LogicalDisk -Filter "DriveType = 3" | ? { $_.DeviceID -notmatch "[ab]:"}

foreach ($objDisk in $allDisks){
    $deviceId = $objDisk.deviceID -replace ":",""

    $usedSpace = [System.Math]::Round((($objDisk.Size-$objDisk.Freespace)/1MB),2)
    $availableSpace = [System.Math]::Round(($objDisk.Freespace/1MB),2)
    $usedPercentage = [System.Math]::Round(((($objDisk.Size-$objDisk.Freespace)/$objDisk.Size)*100),2)

    Write-Host "win_disk_usage,host=$hostnameFqdn,deviceid=$deviceId UsedMB=$usedSpace,FreeMB=$availableSpace,UsedPercentage=$usedPercentage"
}
exit 0