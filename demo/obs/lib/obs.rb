# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.

class OBS < DaemonKit::RuotePseudoParticipant

  on_exception :dammit

  on_complete do |workitem|
    workitem['success'] = true
  end

  def build
    2.times { puts "" }
    puts "I'll build #{workitem['pkg']}"
    2.times { puts "" }
  end

  def err
    print "Error"
    raise ArgumentError, "Does not compute"
  end

  def dammit( exception )
    workitem["error"] = exception.message
  end

end
