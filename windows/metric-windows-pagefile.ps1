#
# metric-windows-pagefile
#
# DESCRIPTION:
#   Retrieve pagefile usage stats
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
$objItem = get-wmiobject -class "Win32_PageFileUsage" -namespace "root\CIMV2"

$pagefileSize = $objItem.AllocatedBaseSize
$pagefileUsed = $objItem.CurrentUsage
$pagefilePercentFree = ($pagefileSize - $pagefileUsed) / $pagefileSize * 100
$pagefilePercentUsed = 100 - $pagefilePercentFree
$pagefilePercentUsed = [math]::Round($pagefilePercentUsed,2)

$compName = [System.Net.Dns]::GetHostName()
$compDomain = (Get-WmiObject Win32_ComputerSystem).Domain
$hostnameFqdn = $compName.toLower() + "." + $compDomain.toLower()

Write-Host "win_memory_percent,host=$hostnameFqdn pagefile_used=$pagefilePercentUsed"
#Write-Host "win_pagefile,host=$hostnameFqdn,OS=$Os pagefile_used=$pagefilePercentUsed $time"
exit 0