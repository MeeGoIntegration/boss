#!/usr/bin/ruby

require 'rubygems'

# The json backend must be specified before anything loads rufus/json
# This odd yajl require is for the semi-broken packaging by David
require 'yajl/json_gem'

require 'ruote'
require 'ruote/storage/fs_storage'
require 'ruote-amqp'


require 'mq'

STDOUT.sync = true

# FIXME: use: http://rubygems.org/gems/ini
#          or http://rubygems.org/gems/inifile
# and boss.config

#AMQP.logging = true
AMQP.settings[:host] = 'localhost'
AMQP.settings[:user] = 'boss'
AMQP.settings[:pass] = 'boss'
AMQP.settings[:vhost] = 'boss'

$engine = Ruote::Engine.new(
  Ruote::Worker.new(
    # Use boss.config
    Ruote::FsStorage.new(ENV['SERVER_DATABASE'])
  )
)

# if options.debug
# $engine.noisy = true

# We run under daemontools and it communicates via signals
Signal.trap('SIGTERM') do 
  puts 'Shutdown gracefully'
  $engine.shutdown
  puts 'Asked engine to stop'
end

# This spawns a thread which listens for amqp responses
RuoteAMQP::Receiver.new( $engine, :launchitems => true )

# A simple LocalParticipant to handle registering a new AMQP Participant
#
# fields["name"] : the participant name to be registered
# fields["queue"] : the corresponding amqp queue
#
# boss_register [:action => 'unregister']
#
class BOSSRegistrar
  include Ruote::LocalParticipant
  def consume(workitem)
    if workitem.params["action"] == "unregister"
      puts "UnRegister participant :", workitem.fields["name"]
      $engine.unregister_participant(workitem.fields["name"])
    else
      puts "Register participant :", workitem.fields["name"]
      puts "using queue ", workitem.fields["queue"]
      $engine.register_participant(workitem.fields["name"],
                                   RuoteAMQP::ParticipantProxy,
                                   :queue => workitem.fields["queue"],
                                   :position => -2 )
    end
    reply_to_engine(workitem)
  end
end


$engine.register_participant 'boss_register', BOSSRegistrar, :position => 'first'


# All setup... wait for a shutdown
puts "Engine running"

$engine.join()
puts "Engine stopped"

# FIXME: RuoteAMQP is not shutting down nicely
# RuoteAMQP.stop!
# puts "AMQP stopped"
