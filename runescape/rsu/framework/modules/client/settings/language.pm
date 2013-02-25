package client::settings::language;

	sub getlanguage
	{
		# This function depends on functions from rsu_IO.pm
		require rsu::file::IO;
		
		# Get the data container
		my $rsu_data = shift;
		
		# Print debug info
		print "Checking your client language setting(if any)\nTrying to read file\n".$rsu_data->HOME."/jagexappletviewer.preferences\n\n";
		
		# Make a variable to contain the contents of $HOME/jagexappletviewer.preferences
		my $lang = rsu::file::IO::ReadFile($rsu_data->HOME."/jagexappletviewer.preferences");
		
		# If there is an error with the file
		if ($lang =~ /error reading file/)
		{
			# Print debug info
			print "Unable to read jagexappletviewer.preferences file, defaulting to Language=0 (English).\n";
			
			# Default to english
			$lang = "Language=0";
		}
		# Else we will convert the pointer to a string
		else
		{
			# Make the pointer into a string so we can work with it
			$lang = "@$lang";
			
			# Print debug info
			print "File read and this is the content i found!\n######## File Start ########\n\n$lang\n######## File End ########\n\n";
		}
		
		# Print debug info
		print "I will now parse the contents from the\njagexappletviewer.preferences file so it can be used.\n";
		
		# Replace newlines and get only the Language number out of the string
		$lang =~ s/(Language\=|\n|\r|\r\n|Member\=|yes|no|\s+)//g;
		
		# Return the prefered language
		return $lang;
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#

1;
