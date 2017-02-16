#! /usr/bin/env ruby
#
# metrics-disk_npc
#
# DESCRIPTION:
#   Retrieve disk performance stats
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

#
# Disk Graphite
#
class DiskGraphite < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.disk"

  # this option uses lsblk to convert the dm-<whatever> name to the LVM name.
  # sample metric scheme without this:
  # <hostname>.disk.dm-0
  # sample metric scheme with this:
  # <hostname>.disk.vg-root
  option :convert,
         description: 'Convert devicemapper to logical volume name',
         short: '-c',
         long: '--convert',
         default: false

  option :ignore_device,
         description: 'Ignore devices matching pattern(s)',
         short: '-i DEV[,DEV]',
         long: '--ignore-device',
         proc: proc { |a| a.split(',') }

  option :include_device,
         description: 'Include only devices matching pattern(s)',
         short: '-I DEV[,DEV]',
         long: '--include-device',
         proc: proc { |a| a.split(',') }

  # Main function
  def run
    # http://www.kernel.org/doc/Documentation/iostats.txt
    metrics = %w(reads readsMerged sectorsRead readTime writes writesMerged sectorsWritten writeTime ioInProgress ioTime ioTimeWeighted)

    File.open('/proc/diskstats', 'r').each_line do |line|
      stats = line.strip.split(/\s+/)
      _major, _minor, dev = stats.shift(3)
      timestamp = DateTime.now.strftime('%s%9N')
      if config[:convert]
        dev = File.read('/sys/block/' + dev + '/dm/name').chomp! if dev =~ /^dm-.*$/
      end
      next if stats == ['0'].cycle.take(stats.size)

      next if config[:ignore_device] && config[:ignore_device].find { |x| dev.match(x) }
      next if config[:include_device] && !config[:include_device].find { |x| dev.match(x) }

      metrics.size.times { |i| output "rhel_disk,host=#{Socket.gethostname},device=#{dev} #{metrics[i]}=#{stats[i]} #{timestamp}"}
    end

    ok
  end
end
