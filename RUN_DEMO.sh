#!/bin/bash
# Start MQ system
#ssh amqpvm
tail -f /var/log/rabbitmq/rabbit.log

# Start (a) workflow engine
xterm -T ENGINE -e demo/ENGINE.sh &
# Start a proxy for OBS
xterm -T BUILDER -e demo/OBS.sh &
# Start a proxy for CITA
xterm -T TESTER -e demo/CITA.sh &
# Start a proxy for IMG
xterm -T IMAGER -e demo/IMG.sh

# 
echo run : demo/START.sh
echo to start a process
