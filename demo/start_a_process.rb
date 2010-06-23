#!/usr/bin/env ruby
# http://gist.github.com/144861
#
# Requirements:
# * ruote-2.1.10 or later
#
$:.push "./ruote/lib"

require 'rubygems'
require 'bundler'
Bundler.setup
require 'ruote'
require 'ruote/storage/fs_storage'

# Describe the engine/storage we're using
engine = Ruote::Engine.new(
    Ruote::FsStorage.new('/tmp/work')
)

# Note that all participants are pre-registered in the engine

ci_process = Ruote.process_definition :name => 'Ci Process' do
  sequence :on_error => 'handle_issue' do
    developer
    builder
    sizer
    imager
    _if '${f:build_ok} == YES' do
      tester
    end
    print_results
  end

  define 'handle_issue' do
    shout :msg => 'process ${wfid} has died'
  end

end

puts "Launching Process"
fei = engine.launch( ci_process )

puts "Set it off, exiting"

