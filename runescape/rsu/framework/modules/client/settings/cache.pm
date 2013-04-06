package client::settings::cache;

sub getcachedir
{
	# Get the passed data
	my ($cachelocation) = @_;
	
	# Require the files IO module
	require rsu::files::IO;
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Require the client env module
	require client::env;
	
	# Get the users HOME directory
	my $HOME = client::env::home();
	
	# If the cachedir is portable
	if ($cachelocation =~ /^portable$/)
	{
		# Set $cachelocation to $clientdir/share/cache
		$cachelocation = "$clientdir/share/cache";
	}
	# Else if the cachedir is default
	elsif($cachelocation =~ /^(default|undef)$/)
	{
		# If $HOME/jagexcache exists then
		if (-d "$HOME/jagexcache")
		{
			# Set $cachelocation to $HOME
			$cachelocation = $HOME;
		}
		# Else we will use the portable location
		else
		{
			# Set $cachelocation to $clientdir/share/cache
			$cachelocation = "$clientdir/share/cache";
		}
	}
	
	# Return the cachelocation
	return $cachelocation
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
