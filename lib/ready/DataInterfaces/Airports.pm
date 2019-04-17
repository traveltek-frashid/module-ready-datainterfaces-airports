
package ready::DataInterfaces::Airports;

use Data::Dumper;
use ready::Cache();
use ready::Fusion::General();
use ready::Sql();

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = bless {}, $class;

	$self->{CACHE} = ready::Cache->instance();
	$self->{GENERAL} = ready::Fusion::General->new();
	$self->{SQL} = ready::Sql->new();

	$self->{AIRPORTS} = _getairports($self);
	$self->{CITIES} = _getcities($self);

	return $self;

}

sub _getairports {
	my $self = shift;
	my $language = shift || "";
	my $iatatoairport;

	if (!$language) {
		$language = $self->{GENERAL}->getuserlanguage() // "";
	}

	if ($language ne "" && $language ne "en") {
		$iatatoairport = $self->{CACHE}->get("iatatoairport$language.dat");
	} else {
		$iatatoairport = $self->{CACHE}->get("iatatoairport.dat");
	}

	if (!$iatatoairport) {
		if ($language ne "" && $language ne "en") {
			my @cursor = $self->{SQL}->query("select a.iata, t.name from airports a left join airports_translate t on a.id = t.itemid where t.language = ?", $language);
			while (my $rec = $cursor[0]->fetch) {
				$iatatoairport->{$rec->[0]} = $rec->[1];
			}
			
			if ($iatatoairport) {
				$self->{CACHE}->set("iatatoairport$language.dat", $iatatoairport);
			}
			
		} else {
			my @cursor = $self->{SQL}->query("select iata, name from airports");
			while (my $rec = $cursor[0]->fetch) {
				$iatatoairport->{$rec->[0]} = $rec->[1];
			}
			
			if ($iatatoairport) {
				$self->{CACHE}->set("iatatoairport.dat", $iatatoairport);
			}
		}
	}
	
	return $iatatoairport;
}

sub _getcities {
	my $self = shift;
	my $iatatocities;
	
	$iatatocities = $self->{CACHE}->get("iatatocities.dat");

	if (!$iatatocities) {
		my @cursor = $self->{SQL}->query("select iata, iatadescription from airports");
		while (my $rec = $cursor[0]->fetch) {
			$iatatocities->{$rec->[0]} = $rec->[1];
		}
			
		if ($iatatocities) {
			$self->{CACHE}->set("iatatocities.dat", $iatatocities);
		}
	}

	return $iatatocities;	
	
}

1;