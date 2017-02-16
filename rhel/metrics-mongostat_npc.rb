#! /usr/bin/env ruby
#
# metrics-mongostat_npc
#
# DESCRIPTION:
#   Retrieve mongodb performance stats
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
require 'json'
require 'date'
require 'socket'

class MongoStat < Sensu::Plugin::Metric::CLI::Graphite

  def run

    timestamp = DateTime.now.strftime('%s%9N')

    begin
      jsonRaw = `mongostat --json -n 1 2`
      json = JSON.parse(jsonRaw)

      json.each do |key, value|
        query = value["query"].delete('*')
        insert = value["insert"].delete('*')
        delete = value["delete"].delete('*')
        resmem = value["res"].delete('*').delete('M')
        conn = value["conn"].delete('*')
        update = value["update"].delete('*')
        getmore = value["getmore"].delete('*')
        flushes = value["flushes"].delete('*')
        host = value["host"]

        commandLocal = value["command"].split('|')[0]
        commandRep =  value["command"].split('|')[1]
        ar = value["ar|aw"].split('|')[0]
        aw = value["ar|aw"].split('|')[1]
        qr = value["qr|qw"].split('|')[0]
        qw = value["qr|qw"].split('|')[1]

        output "rhel_mongodb,host=#{host} query=#{query},insert=#{insert},delete=#{delete},resmem=#{resmem},conn=#{conn},update=#{update},getmore=#{getmore},flushes=#{flushes} #{timestamp}"
        output "rhel_mongodb,host=#{host} commandLocal=#{commandLocal},commandRep=#{commandRep},ar=#{ar},aw=#{aw},qr=#{qr},qw=#{qw} #{timestamp}"

      end

    rescue
      unknown "Could not run mongostat: #{$!}"
    end

    ok
  end
end