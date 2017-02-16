#
# metric-windows-disk
#
# DESCRIPTION:
#   Retrieve disk performance stats
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

function ProcessCounters {
    param( [string]$counter, [string]$diskInt)
    $output = (Get-Counter -Counter $counter).CounterSamples.CookedValue
    foreach ($value in $output) {
        $counterName = $counter.Replace("\PhysicalDisk($diskInt)\","").Replace(" ", "_").Replace("%","Percent")
        $value = [System.Math]::Round($value,2)
        $diskName = $diskName.Replace(":","")
        Write-Host "win_disk,host=$hostnameFqdn,deviceid=$diskName $counterName=$value"
    }
}

$allDisks = Get-WMIObject Win32_LogicalDisk -Filter "DriveType = 3" | ? { $_.DeviceID -notmatch "[ab]:"}

foreach ($disk in $allDisks) {
    $diskName = $disk.DeviceID
    $diskNum = "$([array]::IndexOf($allDisks, $disk)) $diskName"

$countersArray = @(
   "\PhysicalDisk($diskNum)\Current Disk Queue Length",
    "\PhysicalDisk($diskNum)\% Disk Time",
    "\PhysicalDisk($diskNum)\% Disk Read Time",
    "\PhysicalDisk($diskNum)\% Disk Write Time",
    "\PhysicalDisk($diskNum)\Disk Reads/sec",
    "\PhysicalDisk($diskNum)\Disk Writes/sec",
    "\PhysicalDisk($diskNum)\Disk Read Bytes/sec",
    "\PhysicalDisk($diskNum)\Disk Write Bytes/sec",
    "\PhysicalDisk($diskNum)\% Idle Time"   
    )

    foreach ($counter in $countersArray) {
        ProcessCounters $counter $diskNum
    }
}