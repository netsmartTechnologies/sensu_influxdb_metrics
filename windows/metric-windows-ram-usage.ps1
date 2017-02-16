#
# metrics-windows-ram-usage
#
# DESCRIPTION:
#   Retrieve memory usage
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
$freeMemory = (Get-WmiObject -Query "SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem").FreePhysicalMemory
$totalMemory = (Get-WmiObject -Query "SELECT TotalVisibleMemorySize, FreePhysicalMemory FROM Win32_OperatingSystem").TotalVisibleMemorySize

$usagePercent = [System.Math]::Round(((($totalMemory-$freeMemory)/$totalMemory)*100),2)

$compName = [System.Net.Dns]::GetHostName()
$compDomain = (Get-WmiObject Win32_ComputerSystem).Domain
$hostnameFqdn = $compName.toLower() + "." + $compDomain.toLower()

Write-host "win_memory_percent,host=$hostnameFqdn usage_percent=$usagePercent"
exit 0