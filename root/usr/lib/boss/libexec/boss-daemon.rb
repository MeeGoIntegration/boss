require 'ruote'
require 'ruote/storage/fs_storage'
require 'ruote-amqp'

# Particularly useful for JSON.pretty_generate workitem.to_h
require 'yajl/json_gem'

require 'mq'

#AMQP.logging = true
AMQP.settings[:host] = 'localhost'
AMQP.settings[:user] = 'boss'
AMQP.settings[:pass] = 'boss'
AMQP.settings[:vhost] = 'boss'

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  config.trap( 'TERM', Proc.new { 
                 puts 'Going down'
                 AMQP.stop!
               } )
end

$engine = Ruote::Engine.new(
  Ruote::Worker.new(
    Ruote::FsStorage.new('/var/spool/boss/boss_ruote_db')
  )
)

# This spawns a thread which listens for amqp responses
RuoteAMQP::Receiver.new( $engine, :launchitems => true )

# A logging error handler
class ErrorHandler
  include Ruote::LocalParticipant
  def consume (workitem)
    puts "Error in workitem:"
    puts JSON.pretty_generate workitem.to_h
  end
end

$engine.register_participant( 'error', ErrorHandler )

puts "Engine running"

$engine.join()
