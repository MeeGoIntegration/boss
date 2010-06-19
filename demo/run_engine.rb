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

AMQP.settings[:host] = 'amqpvm'
AMQP.settings[:user] = 'ruote'
AMQP.settings[:pass] = 'ruote'
AMQP.settings[:vhost] = 'ruote-test'
#AMQP.logging = true

class DeveloperParticipant
  include Ruote::LocalParticipant
  def initialize (opts)
    @opts = opts
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

engine = Ruote::Engine.new(
  Ruote::Worker.new(
    Ruote::FsStorage.new('/tmp/work')
  )
)
RuoteAMQP::Receiver.new( engine ) # This spawns a thread which listens for amqp responses

engine.register_participant( 'print_results' ) do |workitem|
  puts "============="
  puts "Package #{workitem.fields['pkg']}"
  puts "Imaged in #{workitem.fields['image-time']}s"
  if workitem.fields['test_result'] then puts "Tested: #{workitem.fields['test_result']}" end
  puts "============="
end

engine.register_participant 'developer', DeveloperParticipant

puts "Engine running"

sleep 50000
#3.times { puts "" }
#puts "Launching ErrorProcess"
#fei = engine.launch( error_process )

#engine.wait_for( fei )

#3.times { puts "" }
#puts "Errors in engine"
#puts engine.errors.inspect
