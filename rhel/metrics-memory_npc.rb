#! /usr/bin/env ruby
#
# metrics-memory_npc
#
# DESCRIPTION:
#   Retrieve system memory stats
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

class MemoryGraphite < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.memory"

  def run
    # Metrics borrowed from hoardd: https://github.com/coredump/hoardd

    mem = metrics_hash
    timestamp = DateTime.now.strftime('%s%9N')
    mem.each do |k, v|
      # output "#{config[:scheme]}.#{k}", v
      output "rhel_memory_percent,host=#{Socket.gethostname} #{k}=#{v} #{timestamp}"
    end

    ok
  end

  def metrics_hash
    mem = {}
    meminfo_output.each_line do |line|
      mem['total']     = line.split(/\s+/)[1].to_i * 1024 if line =~ /^MemTotal/
      mem['free']      = line.split(/\s+/)[1].to_i * 1024 if line =~ /^MemFree/
      mem['buffers']   = line.split(/\s+/)[1].to_i * 1024 if line =~ /^Buffers/
      mem['cached']    = line.split(/\s+/)[1].to_i * 1024 if line =~ /^Cached/
      mem['swapTotal'] = line.split(/\s+/)[1].to_i * 1024 if line =~ /^SwapTotal/
      mem['swapFree']  = line.split(/\s+/)[1].to_i * 1024 if line =~ /^SwapFree/
      mem['dirty']     = line.split(/\s+/)[1].to_i * 1024 if line =~ /^Dirty/
    end

    mem['swapUsed'] = mem['swapTotal'] - mem['swapFree']
    mem['used'] = mem['total'] - mem['free']
    mem['usedWOBuffersCaches'] = mem['used'] - (mem['buffers'] + mem['cached'])
    mem['freeWOBuffersCaches'] = mem['free'] + (mem['buffers'] + mem['cached'])
    mem['swapUsedPercentage'] = 100 * mem['swapUsed'] / mem['swapTotal'] if mem['swapTotal'] > 0

    mem
  end

  def meminfo_output
    File.open('/proc/meminfo', 'r')
  end
end
