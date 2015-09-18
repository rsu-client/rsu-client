package client::appletviewer::icon;

# This is a module to fetch which icon to use for
# the client window, in the near future the user
# will be able to assign their own icon for
# OldSchool and RuneScape

sub getIcon
{
	# Get the passed data
	my ($paramcheck, $prmfile, $clientdir) = @_;
	
	# Make a variable to contain the iconfolder name (by default RuneScape3)
	my $iconfolder = "RuneScape3";
	
	# If $prmfile is runescape.prm then
	if ($prmfile =~ /^runescape\.prm/)
	{
		# Set iconfolder to RuneScape3
		$iconfolder = "RuneScape3";
	}
	# Else if $prmfile is oldschool.prm then
	elsif ($prmfile =~ /^oldschool\.prm/)
	{
		# Set iconfolder to OldSchool
		$iconfolder = "OldSchool";
	}
	# Else if $prmfile starts with funorb_ hten
	elsif ($prmfile =~ /^funorb_.+/)
	{
		# Set iconfolder to FunOrb
		$iconfolder = "FunOrb";
	}
	# Else if $prmfile is darkscape.prm or rsdarkscape.prm or runescape_darkscape.prm then
	elsif ($prmfile =~ /^(darkscape\.prm|rsdarkscape\.prm|runescape_darkscape\.prm)/)
	{
		# Set iconfolder to DarkScape
		$iconfolder = "DarkScape";
	}
	# Else
	else
	{
		# Remove .prm from the $prmfile
		$prmfile =~ s/\.prm$//;
		
		# If a custom icon folder for the prm file exists then
		if (-d "$clientdir/share/img/$prmfile")
		{
			# Set the iconfolder to the custom folder
			$iconfolder = "$prmfile";
		}
		# Else use the default that is defined in $iconfolder
	}
	
	# Return the iconfolder name
	return $iconfolder;
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
