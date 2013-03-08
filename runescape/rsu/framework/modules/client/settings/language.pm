package client::settings::language;

	sub getlanguage
	{
		# This function depends on functions from rsu_IO.pm
		require rsu::files::IO;
		
		# Use the env module which contains enviroment variables that the client uses
		require client::env;
		
		# Get the location of the home directory
		my $HOME = client::env::home();
		
		# If we were not called from the API
		if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
		{
			# Print debug info
			print "Checking your client language setting(if any)\nTrying to read file\n".$HOME."/jagexappletviewer.preferences\n\n";
		}
		
		# Make a variable to contain the contents of $HOME/jagexappletviewer.preferences
		my $lang = rsu::files::IO::ReadFile($HOME."/jagexappletviewer.preferences");
		
		# If there is an error with the file
		if ($lang =~ /error reading file/)
		{
			# Print debug info
			print STDERR "Unable to read jagexappletviewer.preferences file, defaulting to Language=0 (English).\n";
			
			# Default to english
			$lang = "Language=0";
		}
		# Else we will convert the pointer to a string
		else
		{
			# Make the pointer into a string so we can work with it
			$lang = "@$lang";
			
			# If we were not called from the API
			if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
			{
				# Print debug info
				print "File read and this is the content i found!\n######## File Start ########\n\n$lang\n######## File End ########\n\n";
			}
		}
		
		# If we were not called from the API
		if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
		{
			# Print debug info
			print "I will now parse the contents from the\njagexappletviewer.preferences file so it can be used.\n";
		}
		
		# Replace newlines and get only the Language number out of the string
		$lang =~ s/(Language\=|\n|\r|\r\n|Member\=|yes|no|\s+)//g;
		
		# Return the prefered language
		return $lang;
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#
	
	sub setlanguage
	{
		# Get the value passed
		my ($lang) = @_;
		
		# Use the env module which contains the environment variables that the client use
		require client::env;
		
		# Get the location of the home directory
		my $HOME = client::env::home();
		
		# Read the content of the config file
		my $content = rsu::files::IO::getcontent($HOME, "jagexappletviewer.preferences");
		
		# If nothing returned or the key is not found
		if ($content =~ /^\n$/ || $content !~ /Language=(.+)\n/)
		{
			# Write a new file
			rsu::files::IO::WriteFile("Language=$lang", ">>", "$HOME/jagexappletviewer.preferences");
		}
		# Else
		else
		{
			# Replace the old value with the new one
			$content =~ s/Language=(.+)\n/Language=$lang\n/;
			
			# Remove the newline at the end
			$content =~ s/\n$//;
			
			# Write the contents back to the file
			rsu::files::IO::WriteFile($content, ">", "$HOME/jagexappletviewer.preferences");
		}
	}
	
	#
	#---------------------------------------- *** ----------------------------------------
	#
	
1;
