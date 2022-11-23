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
  boss_config_file = nil
  OptionParser.new do |o|
    o.on('-c CONFIGFILE', "Config file (merged with /etc/skynet/skynet.conf") { |filename| boss_config_file = filename }
    o.on('-h') { puts o; exit }
    o.parse!
  end

  @conf = IniFile.load("/etc/skynet/skynet.conf") || IniFile.new
  if boss_config_file
    @conf = @conf.merge(IniFile.load(boss_config_file))
  end
  debug = (@conf["boss"]["debug"] == true)

  $stderr.puts "Read configuration as:\n#{conf}\n" if debug

  if @conf["boss"]["db"]
    require 'ruote-sequel'
    sequel = Sequel.connect(@conf["boss"]["db"])
    opts = { 'remote_definition_allowed' => true }
    @storage = Ruote::Sequel::Storage.new(sequel, opts)
    $stderr.puts "Setup Sequel Storage using : #{sequel}\n" if debug
  else
    db_path = @conf["boss"]["db_path"] || "/var/spool/boss/boss_ruote_db"
    @storage = BOSS::Storage.new(db_path, { :number => $pnum })
    $stderr.puts "Setup Path Storage using : #{db_path}\n" if debug
  end

  def storage
    @storage
  end
  module_function :storage
end
