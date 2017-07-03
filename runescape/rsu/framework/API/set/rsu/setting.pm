package set::rsu::setting;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

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
	if (defined $ARGV[3])
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
			if (defined $ARGV[4])
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
	
	# Write the new setting
	rsu::files::IO::writeconf("_", "$ARGV[1]", "$ARGV[2]", "$file", "$location");
	
}

1; 
