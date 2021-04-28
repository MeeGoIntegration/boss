#!/usr/bin/env ruby

require 'ruote'
require 'pp'
require 'inifile'

STDOUT.sync = true
STDERR.sync = true

require 'optparse'

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

  amqp_host, amqp_port = ( conf["boss"]["amqp_host"] || "127.0.0.1:5672" ).split(":")
  user = conf["boss"]["amqp_user"] || "boss"
  pass = conf["boss"]["amqp_pwd"]  || "boss"
  vhost = conf["boss"]["amqp_vhost"] || "boss"
  db_path = conf["boss"]["db_path"] || "/var/spool/boss/boss_ruote_db"
  port = Integer(conf["boss"]["viewer_port"]) || 9292
  bind = conf["boss"]["viewer_address"] || "127.0.0.1"
  hprio = /!high/

  # Supervisor runs a number of processes each with an identifier
  # We use that to decide what role we have
  # Currently
  # 0 => viewer
  # 1 => scheduler
  # 2 => worker
  pname = ENV["SUPERVISOR_PROCESS_NAME"] || "boss_0"
  # Yes, this is just dropped into a global variable...
  $pnum = pname.split("_")[1].to_i

  def set_and_check_amqp
    AMQP.settings[:host] = amqp_host
    AMQP.settings[:port] = Integer(amqp_port)
    AMQP.settings[:user] = user
    AMQP.settings[:pass] = pass
    AMQP.settings[:vhost] = vhost
    AMQP.logging = debug

    #test connection
    begin
      AMQP.start() do |connection|
        AMQP::Channel.new(connection) do |channel|
          $stderr.puts "Connection opened ok"
          AMQP.stop { EventMachine.stop }
        end
      end
    rescue AMQP::Error => e
      $stderr.puts "Failed to connect to AMQP server, error was :"
      $stderr.puts e.message
      $stderr.puts "Please check that the settings in /etc/skynet/skynet.conf are correct."
      $stderr.puts "Run the following commands as root on the AMQP server :"
      $stderr.puts "/usr/sbin/rabbitmqctl add_vhost #{vhost}"
      $stderr.puts "/usr/sbin/rabbitmqctl add_user #{user} #{pass}"
      $stderr.puts "/usr/sbin/rabbitmqctl set_permissions -p #{vhost} #{user} '.*' '.*' '.*'"
      exit 1
    end
  end

  $pp_verbose = true;

  # storage = Ruote::BOSSStorage.new(db_path, { :number => $pnum })
  @storage = BOSS::Storage.new(db_path)
  def storage
    @storage
  end
  module_function :storage
end
