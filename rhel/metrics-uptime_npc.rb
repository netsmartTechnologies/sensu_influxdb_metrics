#! /usr/bin/env ruby
#
# metrics-uptime_npc
#
# DESCRIPTION:
#   Retrieve uptime of a system
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
# Metric Uptime
#
class Uptime < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.uptime"

  # Main function
  def run
    lines = File.readlines('/proc/uptime', 'r')
    metrics = %w(uptime)
    stats = lines[0].strip.split(/\s+/)
    timestamp = DateTime.now.strftime('%s%9N')

    metrics.size.times { |i| output "rhel_uptime,host=#{Socket.gethostname} system_uptime=#{stats[i]} #{timestamp}"}
    ok
  end
end