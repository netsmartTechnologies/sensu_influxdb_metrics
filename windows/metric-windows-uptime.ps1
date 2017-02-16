#
# metric-windows-uptime
#
# DESCRIPTION:
#   Retrieve system uptime
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
$Counter = ((Get-Counter "\System\System Up Time").CounterSamples)

$compName = [System.Net.Dns]::GetHostName()
$compDomain = (Get-WmiObject Win32_ComputerSystem).Domain
$hostnameFqdn = $compName.toLower() + "." + $compDomain.toLower()

$value = [System.Math]::Truncate($Counter.CookedValue)

Write-Host "win_uptime,host=$hostnameFqdn uptime=$value"
exit 0