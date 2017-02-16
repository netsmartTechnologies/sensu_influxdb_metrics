#! /usr/bin/env ruby
#
# metrics-netif_npc
#
# DESCRIPTION:
#   Retrieve network interface throughput stats
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

require 'sensu-plugin/metric/cli'
require 'socket'
require 'date'

#
# Netif Metrics
#
class NetIFMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: Socket.gethostname.to_s

  def run
    `sar -n DEV 1 1 | grep Average | grep -v IFACE`.each_line do |line|
      stats = line.split(/\s+/)
      unless stats.empty?
        stats.shift
        nic = stats.shift
        timestamp = DateTime.now.strftime('%s%9N')
        #output "#{config[:scheme]}.#{nic}.rx_kB_per_sec", stats[2].to_f if stats[3]
        output "rhel_netif,host=#{Socket.gethostname},instance=#{nic} rx_kB_per_sec=#{stats[2].to_f} #{timestamp}" if stats[3]
        #output "#{config[:scheme]}.#{nic}.tx_kB_per_sec", stats[3].to_f if stats[3]
        output "rhel_netif,host=#{Socket.gethostname},instance=#{nic} tx_kB_per_sec=#{stats[3].to_f} #{timestamp}" if stats[3]
      end
    end

    ok
  end
end
