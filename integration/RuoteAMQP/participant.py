from amqplib import client_0_8 as amqp
from workitem import Workitem
import simplejson as json

class Participant:
     """
     A Participant will do work in a Ruote process. Participant is
     essentially abstract and must be subclassed to provide a useful
     consume() method.

     Workitems arrive via AMQP, are processed and returned to the Ruote engine.

     Cancel is not yet implemented.
     """

     def __init__(self, ruote_queue,
                  amqp_host = "localhost", amqp_user = "ruote",
                  amqp_pass = "ruote", amqp_vhost = "ruote"):

          self._conn = amqp.Connection(host=amqp_host, userid=amqp_user,
                                       password=amqp_pass, virtual_host=amqp_vhost,
                                       insist=False)

          self._chan = self._conn.channel()

          # Declare a shareable queue for the participant
          self._chan.queue_declare(queue=ruote_queue, durable=True,
                                   exclusive=False, auto_delete=False)

          # Currently ruote-amqp uses the anonymous direct exchange
          self._chan.exchange_declare(exchange="", type="direct", durable=True,
                                      auto_delete=False)

          # bind our queue using a routing key of our queue name
          self._chan.queue_bind(queue=ruote_queue, exchange="",
                                routing_key=ruote_queue)

          # and set a callback for workitems
          self._chan.basic_consume(queue=ruote_queue, no_ack=True,
                                   callback=self.workitem_callback)

     def workitem_callback(self, msg):
          "This is where a workitem message is handled"

          self.workitem = Workitem(msg.body)
          self.consume()
          if not self.workitem.forget():
               self.reply_to_engine()

     def consume():
          """
          Override the consume() method in a subclass to do useful work.
          The workitem attribute contains a Workitem.
          """
          pass

     def run(self):
          """
          Currently an infinite loop waitin for messages on the AMQP channel.
          """
          while True:
               self._chan.wait()

     def finish(self):
          "Closes channel and connection"
          self._chan.basic_cancel()
          self._chan.close()
          self._conn.close()

          
     def reply_to_engine(self):
          """
          When the job is complete the workitem is passed back to the
          ruote engine.  The consume() method should set the
          workitem.result() if required.
          """
          msg = amqp.Message(json.dumps(self.workitem.to_h()))
          # delivery_mode=2 is persistent
          msg.properties["delivery_mode"] = 2 
          
          # Publish the message.
          # Notice that this is sent to the anonymous/'' exchange (which is
          # different to 'amq.direct') with a routing_key for the queue
          self._chan.basic_publish(msg, exchange='', routing_key='ruote_workitems')


