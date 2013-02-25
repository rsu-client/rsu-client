package client::settings::prm;

	sub parseprmfile
	{
		# This module depends on rsu_IO.pm
		require rsu::file::IO;
		
		# Get the data container
		my $rsu_data = shift;
		
		# Print debug info
		print "Reading .prm file ".$rsu_data->clientdir."/share/".$rsu_data->prmfile."\n";
		
		# Read the runescape parameters file and send pointer to $prms
		my $prms = rsu::file::IO::ReadFile($rsu_data->clientdir."/share/".$rsu_data->prmfile."");
		
		# If there is an error reading the file
		if ($prms =~ /error reading file/)
		{
			# Print debug info
			print "Error opening ".$rsu_data->clientdir."/share/".$rsu_data->prmfile."\nI will instead use these fallback parameters:\n".$rsu_data->fallbackprms."\n";
			
			# Use the fallback prms defined at the top of the script
			$prms = $rsu_data->fallbackprms;
		}
		# Else we will convert the pointer to a string
		else
		{		
			# Make the pointer into a string we can work with
			$prms = "@$prms";
			
			# Print debug info
			print "This is the info i gathered from the ".$rsu_data->prmfile." file\n######## File Start ########\n$prms\n######## File End ########\n\n";
		}
		
		# Print debug info
		print "I will now parse the parameters!\n";
		
		# Make the string into 1 line
		$prms =~ s/(-Djava.class.path=|\n|\r|\r\n)//g;
		
		# Get the client language settings
		my $lang = client::settings::language::getlanguage($rsu_data);
		
		# Print debug info
		print "Stitching the language setting to the final parameters.\n\n";
		
		# Apply the language setting to the prms
		$prms =~ s/\$\(Language:0\)/$lang/g;
		
		# Print debug info
		print "Final parameter string is:\n$prms\n\n";
		
		# Return to call with the whole prm string
		return $prms;
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#

1;
