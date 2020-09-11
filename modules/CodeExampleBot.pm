#!/usr/bin/perl

package CodeExampleBot; {
	BEGIN { unshift @INC, './modules'; }
	use Config::Simple;
	use JSON;
	use POSIX qw(strftime);
	use APIRequest;
	use URI::Encode;
	use Data::Dumper;
	sub new {
		my($class) = @_;
	
		my $self = {
			name => 'CodeExampleBot',
			version => '1.0',
		};
		
		$self->{CONFIG} = new Config::Simple('./config/codeExampleBot_config.cfg');
		$self->{CONFIG} = $self->{CONFIG}->vars();
		$self->{TOKEN} = $self->{CONFIG}{'default.codeExampleBot_token'};
		$self->{CHATID} = $self->{CONFIG}{'default.chat_id'};
		$self->{URI} = URI::Encode->new( { encode_reserved => 0 } );
		$self->{MESSAGE} = "";
		
		bless $self, $class;
		return $self;
	}
	
	sub setMessage() {
		my $self = shift;
		my $msg = shift;
		
		$self->{MESSAGE} = $msg;
	}
	
	sub getURL {
		my $self = shift;
		my $returned = "";
		if ($self->{MESSAGE} ne "") {
			my $chatid = $self->{CHATID};
			my $token = $self->{TOKEN};
			my $outMessage = $self->{MESSAGE};
			$returned = sprintf("%s%s/sendMessage?chat_id=%s&parse_mode=html&text=%s","https://api.telegram.org/bot",$token,$chatid,$self->{URI}->encode($outMessage));
		} else { 
			die "Telegram Bot: Message must be set.\n";
		}
		return $returned;
	}
	
	sub sendMessage() {
		my $self = shift;
		$APIUrl = $self->getURL();		
		if ($APIUrl eq "") {
			return 0;
		}
		my $APIRequestInstance = APIRequest->new();
		my $response = $APIRequestInstance->getrestapirequest($APIUrl);
		if ($response->is_success) {
			print "Message has been sent\n";
		} else {
			die 'Error sending message to Telegram\n';
		}
		return 1;
	}
}

1;
