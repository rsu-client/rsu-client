package get::optimus::bin;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call to find out if primusrun is installed
Syntaxes:
	$ARGV[0] help
	$ARGV[0]

Examples:
	$ARGV[0]
	result: If primus is installed it will return with the string
	\"primusrun\" otherwise it will just return an empty string.
	
Remarks:
	Returns a string which is either empty or primusrun
	A newline might be at the end of the string.

Purpose:
	Simplify the task of checking if primusrun is available on
	the system.
"

}
# Else
else
{
	# Get the current OS
	my $OS = "$^O";
	
	# If we are not on linux then
	if ($OS !~ /linux/)
	{
		# Write an empty string to STDOUT
		print "\n";
	}
	else
	{
		# Require the optimus module
		require rsu::nvidia::optimus;
	
		# Check if primusrun is installed
		my $primus_installed = rsu::nvidia::optimus::checkforprimus;
		
		# If primusrun is found
		if ($primus_installed =~ /true/)
		{
			# Write primusrun to the STDOUT
			print "primusrun\n"
		}
		# Else
		else
		{
			# Write an empty string to the STDOUT
			print "\n";
		}
	}
}

1; 
 
