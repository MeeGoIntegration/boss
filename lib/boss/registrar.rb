# A simple LocalParticipant to handle registering a new AMQP Participant
#
# Since participants are instantiated by the engine the class needs to
# hold an engine/dashboard instance to register new participants to.
# This means the Class method set_dashboard() must be called to before
# any instances are asked to consume() a workitem.
#
# fields["name"] : the participant name to be registered
# fields["queue"] : the corresponding amqp queue
#
# boss_register [:action => 'unregister']
#
module BOSS
  class Registrar
    include Ruote::LocalParticipant

    # Store the dashboard used by any instances
    @@dashboard = nil
    def self.set_dashboard(dash)
      @@dashboard = dash
    end

    def consume(workitem)
      raise "Provide a dashboard via BOSS::Registrar.sst_dashboard()" unless @@dashboard
      if workitem.params["action"] == "unregister"
        $stderr.puts "UnRegister participant :", workitem.fields["name"]
        @@dashboard.unregister_participant(workitem.fields["name"])
      else
        $stderr.puts "Register participant :", workitem.fields["name"]
        $stderr.puts "using queue ", workitem.fields["queue"]
        @@dashboard.register_participant(workitem.fields["name"],
                                         BOSS::Participant,
                                         :routing_key => workitem.fields["queue"],
                                         :position => -2 )
      end
      reply_to_engine(workitem)
    end
  end
end
