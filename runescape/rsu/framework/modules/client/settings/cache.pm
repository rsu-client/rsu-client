package client::settings::cache;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

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
