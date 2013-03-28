package client::appletviewer::jagex;

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
 
