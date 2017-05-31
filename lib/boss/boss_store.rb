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
      super(dir, options)
    end

    def prepare_msg_doc(action, options)

      # merge! is way faster than merge (no object creation probably)

      @counter ||= 0
      begin
        priority = options["workitem"]["fields"]["priority"]
      rescue
        priority = "normal"

      end

      t = Time.now.utc
      ts = "#{t.strftime('%Y-%m-%d')}!#{t.to_i}.#{'%06d' % t.usec}"
      _id = "#{$$}!#{Thread.current.object_id}!#{priority}!#{ts}!#{'%03d' % @counter}"

      @counter = (@counter + 1) % 1000
        # some platforms (windows) have shallow usecs, so adding that counter...

      msg = options.merge!('type' => 'msgs', '_id' => _id, 'action' => action)

      msg.delete('_rev')
        # in case of message replay

      msg
    end

    def get_msgs (limit, priority)

      msgs = get_many('msgs', priority, {:limit => limit, :noblock => true, :skip => limit * @number})
      msgs = get_many('msgs', nil, {:limit => limit, :noblock => true, :skip => limit * @number}) if msgs.empty? 
      msgs.sort_by { |d| d['put_at'] }

    end

  end

  class BOSSWorker < Ruote::Worker

    attr_reader :priority
    attr_reader :number

    def initialize(storage=nil, options={})

      @priority = options.fetch("priority", "high")
      @number = options.fetch("number", 0)
      @roles = options.fetch("roles", [])

      super(storage)

    end

    def handle_step_error(e, msg)
      puts 'ruote step error: ' + e.inspect
      pp msg

    end

    def process_msgs

      @msgs = @storage.get_msgs(1, @priority) if @msgs.empty?

      while @msg = @msgs.pop

          r = process(@msg)

          if r != false
            @processed_msgs += 1
          end

          break if Time.now.utc - @last_time >= 0.8

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
