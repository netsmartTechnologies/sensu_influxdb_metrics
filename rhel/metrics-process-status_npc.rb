#! /usr/bin/env ruby
#
# metrics-process-status_npc
#
# DESCRIPTION:
#   Retrieve stats about a process
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
# String
# monkeypatch for helping validate PID strings
#
class String
  # if its and integer, set it to a string
  def integer?
    to_i.to_s == self
  end
end

#
# Proc Status
#
# /proc/[PID]/status memory metrics plugin
#
class ProcStatus < Sensu::Plugin::Metric::CLI::Graphite
  option :user,
         description: 'Query processes owned by a user',
         short: '-u USER',
         long: '--user USER'

  option :processname,
         description: 'Process name substring to match against, not a regex.',
         short: '-p PROCESSNAME',
         long: '--process-name PROCESSNAME'

  option :scheme,
         description: 'Metric naming scheme',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.proc"

  option :metrics,
         description: 'Memory metrics to collect from /proc/[PID]/status, comma-separated',
         short: '-m METRICS',
         long: '--metrics METRICS',
         default: 'VmSize,VmRSS,VmSwap'

  # Build search command
  #
  def pgrep_command
    pgrep_command = 'pgrep '
    pgrep_command << "-u #{config[:user]} " if config[:user]
    pgrep_command << "-f #{config[:processname]} " if config[:processname]
    pgrep_command << '2<&1'
  end

  # Acquire process_pids
  #
  # @param pgrep_output [String]
  #
  def acquire_valid_pids(pgrep_output)
    res = pgrep_output.split("\n").map(&:strip)
    pids = res.reject { |x| !x.integer? }
    pids
  end

  # Acquire the sate for the supplied PID
  #
  # @param pid [String]
  #
  def acquire_stats_for_pid(pid)
    return nil unless ::File.exist?(::File.join('/proc', pid, 'cmdline'))

    cmdline_raw = `cat /proc/#{pid}/cmdline`
    cmdline = cmdline_raw.strip.gsub(/[^[:alnum:]]/, '_')

    metric_names = config[:metrics].split(',')
    proc_status_lines = `cat /proc/#{pid}/status`.split("\n")

    out = { cmdline.to_s => {} }

    metric_names.each do |m|
      line = proc_status_lines.find { |x| /^#{m}/.match(x) }
      val = line ? line.split("\t")[1].to_i : nil
      out[cmdline.to_s][m] = val
    end
    out
  end

  # Main functino
  #
  def run
    raise 'You must supply -u USER or -p PROCESSNAME' unless config[:user] || config[:processname]
    metrics = {}
    pgrep_output = `#{pgrep_command}`
    pids = acquire_valid_pids(pgrep_output)

    pids.each do |p|
      data = acquire_stats_for_pid(p)
      metrics.merge!(data) unless data.nil?
    end

    timestamp = DateTime.now.strftime('%s%9N')

    metrics.each do |proc_name, stats|
      stats.each do |stat_name, value|
        # output [config[:scheme], proc_name, stat_name].join('.'), value, timestamp
        output "rhel_process,host=#{Socket.gethostname} procname=#{proc_name},stat_name=#{stat_name} #{timestamp}"
      end
    end
    ok
  end
end
