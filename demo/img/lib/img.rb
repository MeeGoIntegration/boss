class IMG < DaemonKit::RuotePseudoParticipant

  on_exception :dammit

  on_complete do |workitem|
    workitem['success'] = true
  end

  def build
    2.times { puts "" }
    image_time = rand 10
    puts "You need an image with  #{workitem['pkg']}.... just wait #{image_time} seconds"
    sleep image_time
    workitem.fields["image-time"] = image_time
    workitem.fields["build_ok"] = (rand(2)>0)?"YES":"NO"
    puts "Ready. Image built successfully: #{workitem.fields["build_ok"]}"
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
