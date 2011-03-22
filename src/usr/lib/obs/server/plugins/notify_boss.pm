#
# Copyright (c) 2010 Anas Nashif, Intel Inc.
# Copyright (c) 2010 David Greaves, Nokia.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file COPYING); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
################################################################
#
# Wrap events up into a BOSS workitem and launch a process to handle
# the event. Analysis and logic is handled in the participant.
#
# BSConfig should define:
#  BOSS_host   : hostname for server running BOSS AMQP
#  BOSS_user   : AMQP username
#  BOSS_passwd : AMQP password (cleartext)
#
package notify_boss;

use Net::RabbitMQ;
use BSConfig;
use JSON::XS;
use Data::Dumper;


use strict;

sub new {
  my $self = {};
  bless $self, shift;

# As load grows maybe put a persistent AMQP connection in here and
# handle disconnects. For now a reconnect on each message is reliable.
  return $self;
}

sub notify() {
  my ($self, $type, $paramRef ) = @_;

  $type = "UNKNOWN" unless $type;
  my $prefix = $BSConfig::notification_namespace || "OBS";
  $type =  "${prefix}_$type";

  if ($paramRef) {
    $paramRef->{'type'} = $type;
    $paramRef->{'time'} = time();
    my $mq = Net::RabbitMQ->new();
    $mq->connect($BSConfig::BOSS_host, { user => $BSConfig::BOSS_user,
					 password => $BSConfig::BOSS_passwd,
					 vhost => "boss" });
    if ($@) {
      warn("BOSS Plugin: $@");
      return;
    }

    $mq->channel_open(1);

    my $definition = <<EOS;
Ruote.process_definition :name => 'OBS Raw Event' do
  obs_event
end
EOS
    my $fields = {obsEvent => $paramRef};
    my $msg={"definition" => $definition,
	     "fields" => $fields};

    my $body;
    eval {
      $body = encode_json($msg);
    };
    if ($@) {
      print "\n#################################################################################\n";
      print "Dumper\n";
      print Dumper($msg);
      print "\n#################################################################################\n";
      print "JSON\n";
      print $body;
      warn "Error decoding event\n".Dumper($msg);
    } else {
      $mq->publish(1, "ruote_workitems", encode_json($msg), { exchange => '' });
    }
    $mq->disconnect();
  }
}

1;
