#
# metric-windows-cpu-load
#
# DESCRIPTION:
#   Retrieve cpu load stats
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

$value = (Get-WmiObject CIM_Processor).LoadPercentage
$count = $value.count
$countArray = $value.count - 1
$total = 0

for($i = 0; $i -le $countArray; $i++) {
    $total = $value[$i] + $total
}

$total = $total / $count

Write-Host "win_cpu,host=$hostnameFqdn processor_total=$total"
exit 0