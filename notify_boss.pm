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

# obsEvent FORMAT indicates the event structure to participants
our $FORMAT = "2";
#
# introduce 'obsEvent:format'. If not present, format=1
# add non-concatenated type into obsEvent:label/obsEvent:source values
# mark 'obsEvent:type' as deprecated.

# This is the BOSS plugin so we use BOSS defaults.
our $Default_Exchange = '';
our $Default_Key = 'ruote_workitems';

sub new {
  my $self = {};
  bless $self, shift;

# As load grows maybe put a persistent AMQP connection in here and
# handle disconnects. For now a reconnect on each message is reliable.
  return $self;
}

event2json() {
  my ($evRef) = @_;
  return encode_json($evRef);
}

event2ruote() {
  my ($evRef) = @_;
  my $definition = <<EOS;
Ruote.process_definition :name => 'OBS Raw Event' do
  obs_event
end
EOS
  my $fields = {obsEvent => $evRef};
  return encode_json({"definition" => $definition,
		      "fields" => $fields});
}

sub notify() {
  my ($self, $type, $evRef ) = @_;

  if (! defined @BSConfig::BOSS) {
    # convert a 'legacy' config to the new format
    @BOSS =({host => $BSConfig::BOSS_host,
	     user => $BSConfig::BOSS_user,
	     passwd => $BSConfig::BOSS_passwd,
	     exchange => $Default_Exchange,
	     key => $Default_Key,
	     msgmaker => \&event2ruote,
	    });
  } else {
      @BOSS = @BSConfig::BOSS;
  }

  $type = "UNKNOWN" unless $type;
  my $namespace = $BSConfig::notification_namespace || "OBS";
  my $extended_type =  "${namespace}_$type";

  # The $evRef uses structures defined in BSXML.pm
  # Some values are added here.
  if ($evRef) {
    $evRef->{'format'} = $FORMAT;
    $evRef->{'label'} = $type;
    $evRef->{'namespace'} = $namespace;
    $evRef->{'time'} = time();
# deprecated :
    $evRef->{'type'} = $extended_type;

    for my $boss (@BOSS) {
      my $mq = Net::RabbitMQ->new();
      eval {
        $mq->connect($boss->{'host'}, { user => $boss->{'user'},
					password => $boss->{'passwd'},
					vhost => "boss" });
      };
      if ($@) {
	warn("BOSS notify() plugin: $@");
	return;
      }

      $mq->channel_open(1);

      eval {
	my $msg = $boss->{'msgmaker'}->($evRef);
      }
	if ($@) {
	  warn "BOSS notify() plugin encountered an error:\n$@\nWhilst encoding event\n".Dumper($msg);
	} else {
	  $mq->publish(1, $boss->{'key'}, $msg, { exchange => $boss->{'exchange'} });
	}
      $mq->disconnect();
    }
  }
}

1;
