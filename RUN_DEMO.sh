#!/bin/bash
# Start MQ system
# ssh amqpvm tail -f /var/log/rabbitmq/rabbit.log &

# Start (a) workflow engine
nohup xterm -T ENGINE -e demo/ENGINE.sh 2>/dev/null &
# Start a proxy for OBS
nohup xterm -T BUILDER -e demo/OBS.sh 2>/dev/null &
# Start a proxy for CITA
nohup xterm -T TESTER -e demo/CITA.sh 2>/dev/null &
# Start a proxy for IMG
nohup xterm -T IMAGER -e demo/IMG.sh 2>/dev/null &

# 
echo run : demo/START.sh
echo to start a process
