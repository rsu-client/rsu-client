package get::rsu::setting;

# Use the file IO
require rsu::files::IO;

# Use the module for Cwd
require rsu::files::clientdir;
my $clientdir = rsu::files::clientdir::getclientdir();

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call to fetch values from RSU .config files.
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0] listkeys [filename.conf [\"directory\"
	$ARGV[0] content [filename.conf [\"directory\"
	$ARGV[0] key [filename.conf [\"directory\"
	
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
	$ARGV[0] preferredjava options.conf
	result: the value of preferredjava from options.conf
	failure: returns \"undef\"
	
	$ARGV[0] listkeys \"/tmp\"
	result: list all setting keys in settings.conf located in /tmp
	failure: empty string
	
	$ARGV[0] content file.conf \"C:\\\"
	result: list uncommented content of file.conf located in C:\\
	failure: empty string
	
Remarks:
	Certain programming languages may get a newline behind results/failures.

Purpose:
	Simplify looking up values of config files
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
	if ($ARGV[2] ne '')
	{
		# If the parameter starts with a full path or variable
		if ($ARGV[2] =~ /^(\$|\%|[a-z]:|\/|http:\/\/|https:\/\/)/i)
		{
			# Use parameter as location
			$location = $ARGV[2];
		}
		# Else if the parameter ends with .conf
		elsif($ARGV[2] =~ /\.(conf|md|ini|txt|dat|config|readme|update|info|inf|nfo|data|html|php|ws|aspx|pl|py)$/i)
		{
			# Use the parameter as file
			$file = $ARGV[2];
			
			# If the 3rd parameter is passed
			if ($ARGV[3] ne '')
			{
				# If the parameter starts with a full path or variable
				if ($ARGV[3] =~ /^(\$|\%|[a-z]:|\/|http:\/\/|https:\/\/)/i)
				{
					# Use parameter as location
					$location = $ARGV[3];
				}
				# Else
				else
				{
					# Use the parameter as foldername
					$location = "$clientdir/$ARGV[3]";
				}
			}
		}
		# Else
		else
		{
			# Use the parameter as foldername
			$location = "$clientdir/$ARGV[2]";
		}
	}
	
	# If listkeys is passed as second parameter
	if("$ARGV[1]" =~ /^listkeys$/)
	{
		# Get the list of the config content
		my $list = rsu::files::IO::getcontent("$location", $file);
		
		# Remove everything between = and newlines
		$list =~ s/=(.+)\n/\n/g;
		
		# Print all keys in the file
		print "$list";
	}
	# Else if content is passed as second parameter
	elsif("$ARGV[1]" =~ /^content$/)
	{
		# Get the list of the config content
		my $list = rsu::files::IO::getcontent("$location", $file);
		
		# Print the contents of the file
		print "$list";
	}
	# Else
	else
	{
		# Read the config file
		my $value = rsu::files::IO::readconf($ARGV[1], "undef", $file, "$location");
		
		# Print the value of the key
		print "$value\n";
	}
}

1; 
