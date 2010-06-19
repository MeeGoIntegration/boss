#!/usr/bin/env ruby
# http://gist.github.com/144861
#
# Requirements:
# * ruote-2.1.10 or later
# * ruote-amqp-2.1.10 or later
# * daemon-kit-0.1.8rc3 or later
#
$:.push "./ruote-amqp/lib"
$:.push "./ruote/lib"

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

engine = Ruote::Engine.new(
    Ruote::FsStorage.new('/tmp/work')
)

ci_process = Ruote.process_definition :name => 'Ci Process' do
  sequence do
    developer
    kit :command => '/obs/build', :queue => 'obs', :reply_queue => "ruote_workitems"
    kit :command => '/img/image', :queue => 'img', :reply_queue => "ruote_workitems"
    _if '${f:build_ok} == YES' do
      kit :command => '/cita/test', :queue => 'cita', :reply_queue => "ruote_workitems"
    end
    print_results
  end
end

real_ci_process = Ruote.process_definition :name => 'Ci Process' do
  sequence do
    developer
    builder
    imager
    _if '${f:build_ok} == YES' do
      sequence do
        tester
        announce announcement=>"OK"
      end
      announce announcement=>"NOT OK"
    end
    print_results
  end
end

engine.register_participant( 'kit', RuoteAMQP::Participant )

puts "Launching Process"
fei = engine.launch( ci_process )

puts "Set it off, exiting"

#3.times { puts "" }
#puts "Launching ErrorProcess"
#fei = engine.launch( error_process )

#engine.wait_for( fei )

#3.times { puts "" }
#puts "Errors in engine"
#puts engine.errors.inspect
