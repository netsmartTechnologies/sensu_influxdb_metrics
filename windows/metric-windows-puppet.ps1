#
# metric-windows-puppet
#
# DESCRIPTION:
#   Retrieve last puppet run metrics
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
$yamlFilePath = "C:\ProgramData\PuppetLabs\puppet\cache\state\last_run_summary.yaml"

Function Convert-ToUnixDate ($PSdate) {
   $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
   (New-TimeSpan -Start $epoch -End $PSdate).TotalSeconds
}

$currentEpoch = Convert-ToUnixDate(Get-Date)
$currentEpoch = [long]$currentEpoch
$lastRunEpoch = sls "last_run" $yamlFilePath -ca | select -exp line
$lastRunEpoch = [long]$lastRunEpoch.split(':')[1]
$timeSinceLastRun = $currentEpoch - $lastRunEpoch

$compName = [System.Net.Dns]::GetHostName()
$compDomain = (Get-WmiObject Win32_ComputerSystem).Domain
$hostnameFqdn = $compName.toLower() + "." + $compDomain.toLower()

Write-Host "win_puppet,host=$hostnameFqdn puppet=$timeSinceLastRun"
exit 0