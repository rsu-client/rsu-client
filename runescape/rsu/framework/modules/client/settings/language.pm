package client::settings::language;

	sub getlanguage
	{
		# This function depends on functions from rsu_IO.pm
		require rsu::files::IO;
		
		# Require the settings::cache module
		require client::settings::cache;
		
		# Get the cachedir setting then convert it to the path to the cache directory
		my $cachedir = rsu::files::IO::readconf("cachedir", "undef", "settings.conf");
		$cachedir = client::settings::cache::getcachedir($cachedir);
		
		# If we were not called from the API
		if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
		{
			# Print debug info
			print "Checking your client language setting(if any)\nTrying to read file\n".$cachedir."/jagexappletviewer.preferences\n\n";
		}
		
		# Make a variable to contain the contents of $HOME/jagexappletviewer.preferences
		my $lang = rsu::files::IO::ReadFile($cachedir."/jagexappletviewer.preferences");
		
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
				print "File read and this is the contentsIsfound!\n######## File Start ########\n\n$lang\n######## File End ########\n\n";
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
        
        # Use the File::Path module
        use File::Path qw(make_path);
		
		# Require the settings::cache module
		require client::settings::cache;
		
		# Get the cachedir setting then convert it to the path to the cache directory
		my $cachedir = rsu::files::IO::readconf("cachedir", "undef", "settings.conf");
		$cachedir = client::settings::cache::getcachedir($cachedir);
		
		# Read the content of the config file
		my $content = rsu::files::IO::getcontent($cachedir, "jagexappletviewer.preferences");
		
		# If nothing returned or the key is not found
		if ($content =~ /^\n$/ || $content !~ /Language=(.+)\n/)
		{
            # If we were not called from the API
            if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
            {
                # Print debug info
                print "\nWriting the language value $lang to\n".$cachedir."/jagexappletviewer.preferences\n\n";
            }
            
            # Make the directory incase it does not exist
            make_path($cachedir);
            
			# Write a new file
			rsu::files::IO::WriteFile("Language=$lang", ">>", "$cachedir/jagexappletviewer.preferences");
		}
		# Else
		else
		{
			# Replace the old value with the new one
			$content =~ s/Language=(.+)\n/Language=$lang\n/;
			
			# Remove the newline at the end
			$content =~ s/\n$//;
			
			# Write the contents back to the file
			rsu::files::IO::WriteFile($content, ">", "$cachedir/jagexappletviewer.preferences");
		}
	}
	
	#
	#---------------------------------------- *** ----------------------------------------
	#
	
1;
