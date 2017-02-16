#! /usr/bin/env ruby
#
# metrics-ntpstats_npc
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
require 'sensu-plugin/metric/cli'
require 'socket'
require 'date'

class NtpStatsMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :host,
         description: 'Target host',
         short: '-h HOST',
         long: '--host HOST',
         default: 'localhost'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: Socket.gethostname

  def run
    # #YELLOW
    unless config[:host] == 'localhost'
      config[:scheme] = config[:host]
    end

    ntpstats = get_ntpstats(config[:host])
    critical "Failed to get ntpstats from #{config[:host]}" if ntpstats.empty?
    metrics = {
      ntpstats: ntpstats
    }
    timestamp = DateTime.now.strftime('%s%9N')
    metrics.each do |name, stats|
      stats.each do |key, value|
        # output([config[:scheme], name, key].join('.'), value)
        output "rhel_ntp,host=#{Socket.gethostname},name=#{name} #{key}=#{value} #{timestamp}"
      end
    end
    ok
  end

  def get_ntpstats(host)
    key_pattern = Regexp.compile(%w(
      clk_jitter
      clk_wander
      frequency
      mintc
      offset
      stratum
      sys_jitter
      tc
    ).join('|'))
    num_val_pattern = /-?[\d]+(\.[\d]+)?/
    pattern = /(#{key_pattern})=(#{num_val_pattern}),?\s?/

    # #YELLOW
    `ntpq -c rv #{host}`.scan(pattern).reduce({}) do |hash, parsed| # rubocop:disable Style/EachWithObject
      key, val, fraction = parsed
      hash[key] = fraction ? val.to_f : val.to_i
      hash
    end
  end
end
