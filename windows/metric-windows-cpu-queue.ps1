#
# metric-windows-cpu-queue
#
# DESCRIPTION:
#   Retrieve cpu queue length
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

$value = Get-WmiObject Win32_PerfFormattedData_PerfOS_System | select -Expand ProcessorQueueLength

Write-Host "win_cpu,host=$hostnameFqdn queue_length=$value"
exit 0