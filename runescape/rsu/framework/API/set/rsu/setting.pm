package set::rsu::setting;

# Use the module for Cwd
use rsu::files::clientdir;
my $clientdir = rsu::files::clientdir::getclientdir();

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call to set values for keys in RSU .config files.
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0] key value [filename.conf [directory
	
DEFAULTS:
	filename = settings.conf
	directory = \$clientdir/share/configs
	
NOTES:
	Filename must end with .conf
	
	Directory can just be a foldername, in which case it will
	try find the file inside \$clientdir/foldername
	
	In the case of passing both file and directory
	you MUST pass file BEFORE directory!

Examples:
	$ARGV[0] preferredjava default-java
	result: returns nothing & sets the value of preferredjava to default-java in settings.conf
		located inside \$clientdir/share/configs
	
	$ARGV[0] forcealsa true /tmp
	result: returns nothing & sets the value of forcealsa to true in settings.conf
		located inside /tmp
	
	$ARGV[0] preferredjava default-java options.conf
	result: returns nothing & sets the value of preferredjava to default-java in options.conf
		located inside \$clientdir/share/configs
	
	$ARGV[0] forcepulseaudio true options.conf /tmp
	result: returns nothing & sets the value of preferredjava to default-java in options.conf
		located inside /tmp
	failure: creates file and adds the info (all syntaxes)
	
Remarks:
	Certain programming languages may get a newline behind results/failures.

Purpose:
	Simplify setting values to keys in config files
"

}
# Else
else
{
	# Make a variable to contain the location
	my $location = "$clientdir/share/configs";
	
	# Make a variable to contain the filename
	my $file = "settings.conf";
	
	# If a 2nd parameter is passed
	if ($ARGV[3] ne '')
	{
		# If the parameter starts with a full path or variable
		if ($ARGV[3] =~ /^(\$|\%|[a-z]:|\/)/i)
		{
			# Use parameter as location
			$location = $ARGV[3];
		}
		# Else if the parameter ends with .conf
		elsif($ARGV[3] =~ /\.conf$/)
		{
			# Use the parameter as file
			$file = $ARGV[3];
			
			# If the 3rd parameter is passed
			if ($ARGV[4] ne '')
			{
				# If the parameter starts with a full path or variable
				if ($ARGV[4] =~ /^(\$|\%|[a-z]:|\/)/i)
				{
					# Use parameter as location
					$location = $ARGV[4];
				}
				# Else
				else
				{
					# Use the parameter as foldername
					$location = "$clientdir/$ARGV[4]";
				}
			}
		}
		# Else
		else
		{
			# Use the parameter as foldername
			$location = "$clientdir/$ARGV[3]";
		}
	}
	
	# Use the file IO
	require rsu::files::IO;
	
	# Read the content of the config file
	my $content = rsu::files::IO::getcontent("$location", "$file");
	
	# If nothing returned or the key is not found
	if ($content =~ /^\n$/ || $content !~ /$ARGV[1]=(.+)\n/)
	{
		# Write a new file
		rsu::files::IO::WriteFile("$ARGV[1]=$ARGV[2]", ">>", "$location/$file");
	}
	# Else
	else
	{
		# Replace the old value with the new one
		$content =~ s/$ARGV[1]=.+\n/$ARGV[1]=$ARGV[2]\n/;
		
		# Remove the newline at the end
		$content =~ s/\n$//;
		
		# Write the contents back to the file
		rsu::files::IO::WriteFile($content, ">", "$location/$file");
	}
}

1; 
