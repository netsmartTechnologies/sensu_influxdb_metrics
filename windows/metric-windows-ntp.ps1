#
# metrics-windows-ntp
#
# DESCRIPTION:
#   Retrieve ntp stats
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
# Usage
# Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\check-windows-ntp.ps1 DOMAIN_CONTROLLER (10.192.1.30)
#$timeoffset = w32tm /stripchart /dataonly /computer:10.192.1.30 /samples:1; [float]$timeoffset[3].split(' ')[1].TrimEnd('s').TrimStart('+') * 1000"
param([parameter(mandatory=$true)]$ntpServer)
$offset = 0
$samples = 1

$response = w32tm /stripchart /computer:$ntpServer /dataonly /samples:$samples /ipprotocol:4
$offset = $response -match ", ([-+]\d+\.\d+)s"
$offset = $offset.split('+-')[1]
$offset = [float]$offset.split('s')[0]

$Counter = ((Get-Counter "\System\System Up Time").CounterSamples)

$compName = [System.Net.Dns]::GetHostName()
$compDomain = (Get-WmiObject Win32_ComputerSystem).Domain
$hostnameFqdn = $compName.toLower() + "." + $compDomain.toLower()

Write-Host "win_ntp,host=$hostnameFqdn ntp=$offset"
exit 0