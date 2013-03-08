package client::appletviewer::jagex;

	sub runcheck
	{
		# Get the rsu_data container
		my $rsu_data = shift;
		
		# Pass the data to some variables that can be used in commands
		my $cwd = $rsu_data->cwd;
		my $clientdir = $rsu_data->clientdir;
		
		# Require the grep module
		require rsu::files::grep;
		
		# Run a dirgrep query to see if jagexappletviewer.jar exists
		my @jarfileexistcheck = rsu::files::grep::dirgrep("$clientdir/bin", "^jagexappletviewer.jar\$");

		# Transfer the result to a new variable
		my $jarcheckresult = "@jarfileexistcheck";

		# If jagexappletviewer.jar do not exist then
		if ($jarcheckresult !~ /jagexappletviewer.jar/)
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
				require client::launch::updater; #"$cwd/update-runescape-client";
			}
		}
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#
1;
 
