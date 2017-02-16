#
# metric-windows-network
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
$compName = [System.Net.Dns]::GetHostName()
$compDomain = (Get-WmiObject Win32_ComputerSystem).Domain
$hostnameFqdn = $compName.toLower() + "." + $compDomain.toLower()

$colInterfaces = Get-WmiObject -class Win32_PerfFormattedData_Tcpip_NetworkInterface | select BytesTotalPersec, CurrentBandwidth, PacketsPersec, Name
foreach ($interface in $colInterfaces | where-object -FilterScript {$_.Name -notLike "*isatap*"}){

    $bitsPerSec = $interface.BytesTotalPersec * 8
    $totalBits = $interface.CurrentBandwidth

    # Exclude Nulls (any WMI failures)
    if ($totalBits -gt 0) {
        $result = (( $bitsPerSec / $totalBits) * 100)
    }
    else{
        $result = 0
    }
    $intName = $interface.Name -replace ' ','' -replace '[][]','' -replace '\.\.',''

    Write-Host "win_netif,host=$hostnameFqdn,instance=$intName used_percentage=$result,interface_speed=$totalBits,bits_per_sec=$bitsPerSec,packets_per_sec=$($interface.PacketsPersec)"
}
exit 0