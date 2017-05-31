#!/usr/bin/env ruby

class BossViewer < RuoteKit::Application

  # disable sinatra traps of INT and TERM
  disable :traps

  # Override and extend the class method so we can shutdown the engine
  def BossViewer.quit!

    puts "\nstopping engine"
    RuoteKit.engine.shutdown
    RuoteKit.engine.join
    puts "engine stopped"

    super
  end
  get('/') do
    redirect to('/_ruote/')
  end
end

