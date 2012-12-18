package rsu_cfjav;

	sub check_for_jagexappletviewer
	{
		# Get the rsu_data container
		my $rsu_data = shift;
		
		# Pass the data to some variables that can be used in commands
		my $cwd = $rsu_data->cwd;
		my $clientdir = $rsu_data->clientdir;
		
		my $jarfileexistcheck = "";

		# If we are on windows
		if ($rsu_data->OS =~ /MSWin32/)
		{
			# Make $cwd use \ instead of /
			$cwd =~ s/\\/\//g;
			# Set a temp %PATH% variable so we can use grep and then execute dir against the bin folder and pipe the result to grep to
			# check if jagexappletviewer.jar exists
			$jarfileexistcheck = `set PATH=%CD%\\win32\\jawt\\;%CD%\\win32\\gnu\\;%PATH% && dir \"$cwd\\bin\\\" | grep \"jagexappletviewer.jar\" `
		}
		# Else we are on unix
		else
		{
			# execute ls and pipe the result to grep to check if jagexappletviewer.jar exists
			$jarfileexistcheck = `ls \"$clientdir/bin/\" | grep \"jagexappletviewer.jar\"`;
		}

		# Transfer the result to a new variable
		my $jarcheckresult = $jarfileexistcheck;

		# If jagexappletviewer.jar do not exist then
		if ($jarcheckresult !~ /jagexappletviewer.jar/)
		{
			require "$cwd/update-runescape-client";
			# Make a variable containing the path to the update script
			#my $updatescript = "\"$cwd/update-runescape-client\"";
			
			# If we are on windows
			#if ($rsu_data->OS =~ /MSWin32/)
			#{
				# Use a different execution line
			#	$updatescript = "start cmd /c \"$cwd/update-client-on-windows.bat\"";
			#}
			
			# Execute the updater
			#system "$updatescript";
		}
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#
1;
