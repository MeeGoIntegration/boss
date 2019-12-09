#!/usr/bin/env ruby

require 'rubygems'
require 'ruote'
require 'ruote/storage/fs_storage'

module Ruote
  class BOSSStorage < Ruote::FsStorage

    attr_reader :number

    def initialize(dir, options={})
      if File.stat(dir).uid != Process.euid
          raise "Current user is not the owner of the storage #{dir}"
      end

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
end
