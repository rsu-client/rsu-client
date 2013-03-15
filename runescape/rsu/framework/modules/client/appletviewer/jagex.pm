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
				# Start the update-runescape-client.exe inside a new cmd window
				#system "start cmd /c \"$cwd/update-runescape-client.exe\"";
				system "\"$cwd/rsu/rsu-query.exe\" client.launch.updater";
			}
			# Else we are on unix
			else
			{
				# Run the update-runescape-client inside this script process
				system "\"$cwd/rsu/rsu-query\" client.launch.updater";
			}
		}
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#
1;
 
