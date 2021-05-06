#!/usr/bin/env ruby

require 'ruote'
require 'pp'

# TODO: move the classes to a different file/module?
module BOSS
  class Worker < Ruote::Worker

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
