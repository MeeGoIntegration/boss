class CITA < DaemonKit::RuotePseudoParticipant

  on_exception :dammit

  on_complete do |workitem|
    workitem['success'] = true
  end

  def test
    2.times { puts "" }
    puts "Testing an image with  #{workitem['pkg']} in it"
    if rand(10) > 5 then
      workitem.fields["test_result"]="OK"
    else
      workitem.fields["test_result"]="BAD"
    end
    puts "It was #{workitem.fields['test_result']}"
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
