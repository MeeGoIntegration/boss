#!/usr/bin/python
import sys
import os
import random

# Just until Ruote-AMQP is in a proper place
sys.path.append(os.path.dirname(__file__)+"/../../integration")

from  RuoteAMQP.workitem import Workitem
from  RuoteAMQP.participant import Participant

import simplejson as json

class MyPart(Participant):
    def consume(self):
        wi = self.workitem
        print "Got a workitem:"
        print json.dumps(wi.to_h(), indent=4)
        size=random.randint(500,1000)
        print "\nSize is %s" % size
        wi.set_field("image.size", size)
        wi.set_result(True)

print "Started a python participant"
p = MyPart(ruote_queue="sizer", amqp_host="amqpvm", amqp_vhost="ruote-test")
p.run()
