#!/usr/bin/env ruby

require 'rubygems'
require 'amqp'
require 'yajl'
require 'ruote'
require 'ruote/storage/fs_storage'
require 'ruote-amqp'
require 'ruote-kit'

require 'pp'

# TODO: move the classes to a different file/module?
module Ruote
  class BOSSStorage < Ruote::FsStorage

    attr_reader :number

    def initialize(dir, options={})

      @number = options.fetch("number", 0)
      $stderr.puts "Storage #{@number}"
      super(dir, options)
    end

    def get_msgs(limit)
      # This skiping of n*limit messages tries to avoid workers trying to fetch
      # the same messages. The process numbered 2 and up are worker processes.
      skip_n = @number >= 2 ? @number - 2 : 0
      msgs = get_many(
          'msgs', nil,
          {:limit => limit, :noblock => true, :skip => limit * skip_n}
      )
      msgs.sort_by { |d| d['put_at'] }
    end

  end

  class BOSSWorker < Ruote::Worker

    attr_reader :number

    def initialize(storage=nil, options={})
      @number = options.fetch("number", 0)
      @roles = options.fetch("roles", [])
      $stderr.puts "Initialise worker number #{@number} roles #{@roles}"
      super(storage)

    end

    def handle_step_error(e, msg)
      puts 'ruote step error: ' + e.inspect
      pp msg

    end

    def process_msgs

      @msgs = @storage.get_msgs(10) if @msgs.empty?

      while @msg = @msgs.pop

          r = process(@msg)

          if r != false
            @processed_msgs += 1
          end

          # This is disabled because last_time is only set in process_schedules
          # and we run that in separate process. If it was in same process,
          # this would try to guarantee that schedules get processed at least
          # once per second.
          #
          # break if Time.now.utc - @last_time >= 0.8
      end
    end

    def take_a_rest
      if @processed_msgs < 1
        @sleep_time += 1 if @sleep_time < 5.0
        sleep(@sleep_time)
      else
        @sleep_time = 0.00
      end
    end

    def step

      begin_step

      @msg = nil
      @processed_msgs = 0

      determine_state

      if @state == 'stopped'
        return
      elsif @state == 'running'
        process_schedules if @roles.include? 'scheduler'
        process_msgs if @roles.include? 'worker'
      end

      take_a_rest # 'running' or 'paused'

    rescue => err

      handle_step_error(err, @msg) # msg may be nil
    end

  end
end
