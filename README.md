# BOSS - Build Orchestration Supervision System

BOSS sits at the core of the build ecosystem and handles workflow automation.

Based on Ruote workflow engine, and using AMQP to communicate with remote
workflow participants.


## Installation

### AMQP and RabbitMQ

First you need a AMQP broker, [RabbitMQ][1] is the preferred one. Other brokers
supporting the AMQP 0-9-1 might work, but have not been tested.

On the broker set up a vhost and a user that has access to that vhost. BOSS
defaults to using vhost, user, and password "boss", but these can be changed in
the configuration.

### BOSS

Normally you would install BOSS from the rpm package, but manually installation
is also possilbe from the git checkout

Make sure you have the git submodules fetched:
    
    git submodule init
    git submodule update

Running `make install` will build required gems and bundle them as a
stand-alone installation in `./boss-bundle`. Other location can be chosen with
the target parameter:

    make target=/opt/boss install

would install the bundle in /opt/boss

### Configuration (TBD)


## Usage

### Running (TBD)

### CLI tools (TBD)

### Web interface (TBD)


## Development

### Updating bundled gems

Dependencies are shippped in `vendor/cache` and they can be all updated at
once by running

    make update_gems



[1]: https://www.rabbitmq.com/
