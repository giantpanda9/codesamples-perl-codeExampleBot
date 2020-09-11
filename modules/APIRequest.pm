#!/usr/bin/perl

package APIRequest; {
	use LWP::UserAgent;
	sub new {
		my($class) = @_;	
	
		my $self = {
			name => 'APIRequest',
			version => '1.0',
		};
		
		$self->{LWP} = LWP::UserAgent->new();
		$self->{LWP}->agent("Mozilla/4.0 (compatible; MSIE 7.0)");

		bless $self, $class;
		return $self;
	}
	
	sub getrestapirequest {
		my $self = shift;
		my $url = shift;
		
		my $response = $self->{LWP}->get($url);
		
		if (!($response->is_success)) {
			die 'Error getting $url \n';
		}
		if ($response->content_type != "application/json") {
			return []
		}
		return $response;
	}
}

1;
