#! /usr/bin/env ruby
#
# metrics-puppet-run_npc
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

require 'sensu-plugin/metric/cli'
require 'yaml'
require 'socket'

class PuppetRun < Sensu::Plugin::Metric::CLI::Graphite
  option :summary_file,
         short:       '-p PATH',
         long:        '--summary-file PATH',
         default:     '/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml',
         description: 'Location of last_run_summary.yaml file'

  option :scheme,
         description: 'Metric naming scheme',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.puppet"

  def run
    unless File.exist?(config[:summary_file])
      unknown "File #{config[:summary_file]} not found"
    end

    timestamp = DateTime.now.strftime('%s%9N')

    begin
      summary = YAML.load_file(config[:summary_file])
      # print common time
      %w(resources time changes events).each do |i|
        summary[i].each do |key, value|
          output "rhel_puppet,host=#{Socket.gethostname} #{i}_#{key}=#{value} #{timestamp}"
        end
      end
    rescue
      unknown "Could not process #{config[:summary_file]}"
    end

    ok
  end
end
