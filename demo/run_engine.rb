#!/usr/bin/env ruby
# http://gist.github.com/144861
#
# Requirements:
# * ruote-2.1.10 or later
# * ruote-amqp-2.1.10 or later
# * daemon-kit-0.1.8rc3 or later
#
require 'rubygems'
require 'bundler'
Bundler.setup
require 'ruote'
require 'ruote/storage/fs_storage'
require 'ruote-amqp'

# Particularly useful for JSON.pretty_generate workitem.to_h
require 'yajl/json_gem'

AMQP.settings[:host] = 'amqpvm'
AMQP.settings[:user] = 'ruote'
AMQP.settings[:pass] = 'ruote'
AMQP.settings[:vhost] = 'ruote-test'
#AMQP.logging = true

engine = Ruote::Engine.new(
  Ruote::Worker.new(
    Ruote::FsStorage.new('/tmp/work')
  )
)

# This spawns a thread which listens for amqp responses
RuoteAMQP::Receiver.new( engine )

# This registers a general purpose 'remote' participant
engine.register_participant( 'remote', RuoteAMQP::Participant )

# A logging error handler
class ErrorHandler
  include Ruote::LocalParticipant
  def consume (workitem)
    puts "Error in workitem:"
    puts JSON.pretty_generate workitem.to_h
  end
end
engine.register_participant( 'shout', ErrorHandler )

# A local participant  
class DeveloperParticipant
  include Ruote::LocalParticipant
  def initialize (opts)
    @opts = opts
    puts "opts %s" % opts
  end
  def consume (workitem)
    workitem.fields['pkg'] = "shopper #{rand 5}.#{rand 10}.#{rand 10}"
    puts "I've developed a package: #{workitem.fields['pkg']}"
    reply_to_engine(workitem)
  end
  def cancel (fei, flavour)
    # no need for an implementation, since consume replies immediately,
    # never 'holding' a workitem
  end
end
engine.register_participant 'developer', DeveloperParticipant


engine.register_participant( 'builder', RuoteAMQP::Participant,
                             :command => '/obs/build', :queue => 'obs')

engine.register_participant( 'imager', RuoteAMQP::Participant,
                             :command => '/img/image', :queue => 'img', :forget => true)

engine.register_participant( 'tester', RuoteAMQP::Participant,
                             :command => '/cita/test', :queue => 'cita')

# A block participant
engine.register_participant( 'print_results' ) do |workitem|
  puts "============="
  puts "Package #{workitem.fields['pkg']}"
  puts "Imaged in #{workitem.fields['image-time']}s"
  if workitem.fields['test_result'] then puts "Tested: #{workitem.fields['test_result']}" end
  puts "============="
end

puts "Engine running"

sleep 50000
