#!/usr/bin/perl

package ParseNASA; {
	BEGIN { unshift @INC, './modules'; }
	use Config::Simple;
	use JSON;
	use POSIX qw(strftime);
	use APIRequest;	
	sub new {
		my($class) = @_;
	
		my $self = {
			name => 'ParseNASA',
			version => '1.0',
		};
		
		$self->{CONFIG} = new Config::Simple('./config/NASAAPI_config.cfg');
		$self->{CONFIG} = $self->{CONFIG}->vars();
		$self->{APIKEY} = $self->{CONFIG}{'default.NASAAPI_Key'};
		$self->{TODAY} = strftime "%Y-%m-%d", localtime;
		
		bless $self, $class;
		return $self;
	}
	
	sub getURL {
		my $self = shift;
		my $today = $self->{TODAY} ;
		my $APIKey = $self->{APIKEY};
		my $returned = sprintf("%s?start_date=%s&end_date=%s&api_key=%s","https://api.nasa.gov/neo/rest/v1/feed",$today,$today,$APIKey);
		return $returned;
	}
	
	sub getResponse() {
		my $self = shift;
		my $APIUrl = $self->getURL();
		my $APIRequestInstance = APIRequest->new();
		my $response = $APIRequestInstance->getrestapirequest($APIUrl);
		my $content = $response->content;
		my $responseJSON = decode_json($content);
		my $currentDate = $self->{TODAY};
		my @result = ();
		my @responseJSONCurrent = @{$responseJSON->{"near_earth_objects"}->{$currentDate}};
		for $nasaItem (@responseJSONCurrent) {
			my %returnedItem;
			$returnedItem{"name"} = $nasaItem->{"name"};
			$returnedItem{"fromDate"} = $currentDate;
			$returnedItem{"diameterEstMin"} = $nasaItem->{"estimated_diameter"}->{"kilometers"}->{"estimated_diameter_min"} ? $nasaItem->{"estimated_diameter"}->{"kilometers"}->{"estimated_diameter_min"} : 0;
			$returnedItem{"diameterEstMax"} = $nasaItem->{"estimated_diameter"}->{"kilometers"}->{"estimated_diameter_max"} ? $nasaItem->{"estimated_diameter"}->{"kilometers"}->{"estimated_diameter_max"} : 0;
			$returnedItem{"hazardous"} = $nasaItem->{"is_potentially_hazardous_asteroid"} ? "Yes" : "No";
			$returnedItem{"cameCloser"} = $nasaItem->{"close_approach_data"}->[0]->{"close_approach_date"};
			$returnedItem{"details"} = $nasaItem->{"nasa_jpl_url"};
			push(@result,\%returnedItem);
		}
		
		return @result;
	}
	
	sub getOneAsteroid() {
		my $self = shift;
		my @APIResponse = $self->getResponse();		
		my %returned;
		# If NASA returned more than one object - then get random one
		if (scalar(@APIResponse) > 1) {
			my $maxNum = @APIResponse - 1;
			my $APICount = rand($maxNum);
			%returned = %{$APIResponse[$APICount]};
		} else { #Otherwise use the single one returned - potentially impossible			
			%returned = %{$APIResponse[0]};
		}
		
		return %returned;
	}
	
	sub getDescription() {
		my $self = shift;
		my $returnedText = "";
		my %APIResponse = $self->getOneAsteroid();
		if (%APIResponse) {
			$returnedText .= sprintf("Asteroid Name: %s \n", $APIResponse{"name"});
			$returnedText .= sprintf("Report Date: %s \n", $APIResponse{"fromDate"});
			$returnedText .= sprintf("Diameter Min (Km): %s \n", $APIResponse{"diameterEstMin"});
			$returnedText .= sprintf("Diameter Max (Km): %s \n", $APIResponse{"diameterEstMax"});
			$returnedText .= sprintf("Hazardous?: %s \n", $APIResponse{"hazardous"});
			$returnedText .= sprintf("Close Encounter Date: %s \n", $APIResponse{"cameCloser"});
			$returnedText .= sprintf("Details: %s \n", $APIResponse{"details"});
		} else {
			$returnedText = "Nothing returned from NASA API \n";
		}
	return $returnedText;
	}
}

1;
