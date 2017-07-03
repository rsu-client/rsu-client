package client::appletviewer::jagex;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

sub runcheck
{
	# Get the rsu_data container
	my $rsu_data = shift;
	
	# Pass the data to some variables that can be used in commands
	my $cwd = $rsu_data->cwd;
	my $clientdir = $rsu_data->clientdir;

	# If jagexappletviewer.jar do not exist then
	if (!-e "$clientdir/bin/jagexappletviewer.jar")
	{
		# If we are on windows
		if ($rsu_data->OS =~ /MSWin32/)
		{
			# Download and extract the client
			system "\"$cwd/rsu/rsu-query.exe\" rsu.download.client";
		}
		# Else if we are on mac osx
		elsif ($rsu_data->OS =~ /darwin/)
		{
			# Download and extract the client
			system "\"$cwd/rsu/bin/rsu-query-darwin\" rsu.download.client";
		}
		# Else we are on unix
		else
		{
			# Download and extract the client that is best suited for this platform
			system "\"$cwd/rsu/rsu-query\" rsu.download.client";
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#
1;
 
