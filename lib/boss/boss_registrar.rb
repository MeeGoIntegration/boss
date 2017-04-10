# A simple LocalParticipant to handle registering a new AMQP Participant
#
# fields["name"] : the participant name to be registered
# fields["queue"] : the corresponding amqp queue
#
# boss_register [:action => 'unregister']
#
class BOSSRegistrar
  include Ruote::LocalParticipant
  def consume(workitem)
    if workitem.params["action"] == "unregister"
      $stderr.puts "UnRegister participant :", workitem.fields["name"]
      $dashboard.unregister_participant(workitem.fields["name"])
    else
      $stderr.puts "Register participant :", workitem.fields["name"]
      $stderr.puts "using queue ", workitem.fields["queue"]
      $dashboard.register_participant(workitem.fields["name"],
                                      Ruote::Amqp::Participant,
                                      :routing_key => workitem.fields["queue"],
                                      :position => -2 )
    end
    reply_to_engine(workitem)
  end
end
