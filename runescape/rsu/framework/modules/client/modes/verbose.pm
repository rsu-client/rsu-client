# This module provides the verbose functionality in the rsu client
package client::modes::verbose;

	sub verbosecheck
	{
		# Get the data container
		my $rsu_data = shift;
		
		# Tell user what we are going to do
		print "Checking if any --verbose parameters were passed to the script\n";
		
		# If --verbose was passed to the script
		if ($rsu_data->args =~ /--verbose($|\ )/g)
		{
			# Tell user the result of the check
			print "--verbose was passed to the script, java will run in verbose mode when executed!\n";
		
			# Return the verbose parameters for java (no need to check anymore since this contains all the verbose modes)
			return "-verbose:class -verbose:jni -verbose:gc";
		}
		# Else if no --verbose parameters are passed
		elsif ($rsu_data->args !~ /--verbose(|:jni|:class|:gc)($|\ )/g)
		{
			# Tell user the result of the check
			print "The --verbose parameter was not passed to the script.\nJava will be executed without extra output.\n";
			
			# Return empty string since no verbose mode was specified
			return "";
		}
		
		# Make an array to hold the specific parameters if they are passed
		my @verboseprms;
		
		# If --verbose:jni was passed
		if($rsu_data->args =~ /--verbose:jni($|\ )/g)
		{
			# Tell user the result of the check
			print "--verbose:jni was passed to the script, java will run in verbose:jni mode when executed!\n";
		
			# Add the verbose parameters for java to the array
			push(@verboseprms, "-verbose:jni");
		}
		# If --verbose:class
		if($rsu_data->args =~ /--verbose:class($|\ )/g)
		{
			# Tell user the result of the check
			print "--verbose:class was passed to the script, java will run in verbose:class mode when executed!\n";
		
			# Add the verbose parameters for java to the array
			push(@verboseprms, "-verbose:class");
		}
		# If --verbose:gc
		if($rsu_data->args =~ /--verbose:gc($|\ )/g)
		{
			# Tell user the result of the check
			print "--verbose:gc was passed to the script, java will run in verbose:gc mode when executed!\n";
		
			# Add the verbose parameters for java to the array
			push(@verboseprms, "-verbose:gc");
		}
		
		# Return the parameters
		return "@verboseprms";
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#

1;
 
