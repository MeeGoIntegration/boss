require 'boss/storage'
require 'inifile'
require 'optparse'

module BOSS
  def self.read_config

    # BOSS.read_config provides a BOSS.storage based on the config
    # file used by BOSS.  This keeps the config and storage out of the
    # main boss executable and simplifies writing process handling
    # tools such as boss_clean_errors

    STDOUT.sync = true
    STDERR.sync = true

    $stderr.puts "Read configuration\n"

    boss_config_file = nil
    OptionParser.new do |o|
      o.on('-c CONFIGFILE', "Config file (merged with /etc/skynet/skynet.conf") {
        |filename| boss_config_file = filename }
      o.on('-h') { puts o; exit }
      o.parse!
    end

    @conf = IniFile.load("/etc/skynet/skynet.conf") || IniFile.new
    if boss_config_file
      @conf = @conf.merge(IniFile.load(boss_config_file))
    end

    debug = (@conf["boss"]["debug"] == true)

    $stderr.puts "Read configuration as:\n#{conf}\n" if debug

    if @conf["boss"]["db_sequel"] and @conf["boss"]["db_path"]
      $stderr.puts "Only specify one of db_sequel or db_path in the configuration\n"
      exit 1
    end

    if @conf["boss"]["db_sequel"]
      require 'ruote-sequel'
      sequel = Sequel.connect(@conf["boss"]["db_sequel"])
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
end
