#!/usr/bin/env ruby
require 'ruote'
require 'pp'
require 'inifile'

STDOUT.sync = true
STDERR.sync = true

require 'optparse'

# config.rb provides a BOSS.storage based on the config file used by
# boss.  This simplifies writing process handling tools such as
# boss_clean_errors etc

$stderr.puts "Read configuration\n"
module BOSS
  OptionParser.new do |o|
    o.on('-cMANDATORY CONFIGFILE', "Config file") { |filename| @boss_config_file = filename }
    o.on('-h') { puts o; exit }
    o.parse!
  end
  if not @boss_config_file
    $stderr.puts "No -c config file"
    raise OptionParser::MissingArgument
  end

  conf = IniFile.load("/etc/skynet/skynet.conf") || IniFile.new
  conf = conf.merge(IniFile.load(@boss_config_file))
  debug = (conf["boss"]["debug"] == true)

  $stderr.puts "Read configuration as:\n#{conf}\n" if debug

  db_path = conf["boss"]["db_path"] || "/var/spool/boss/boss_ruote_db"

  $pp_verbose = true;

  @storage = BOSS::Storage.new(db_path)
  def storage
    @storage
  end
  module_function :storage
end
