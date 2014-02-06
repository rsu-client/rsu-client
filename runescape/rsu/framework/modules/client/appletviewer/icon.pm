package client::appletviewer::icon;

# This is a module to fetch which icon to use for
# the client window, in the near future the user
# will be able to assign their own icon for
# OldSchool and RuneScape

sub getIcon
{
	# Get the passed data
	my ($paramcheck) = @_;
	
	# Make a variable to contain the iconfolder name (by default RuneScape3)
	my $iconfolder = "RuneScape3";
	
	# If $paramcheck contains the oldschool config
	if ($paramcheck =~ /-Dcom.jagex.config=http:\/\/oldschool/)
	{
		$iconfolder = "OldSchool";
	}
	
	# Return the iconfolder name
	return $iconfolder;
}

#
#---------------------------------------- *** ----------------------------------------
#

1;