package get::rsu::clientdir;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

# If help is passed as a parameter
if ("@ARGV" =~ /\s+help(|\s+)/)
{
	print "API call to fetch the runescape client language preference
Syntaxes:
	$ARGV[0] help
	$ARGV[0]

Examples:
	$ARGV[0]
	result: a string containing the path containing the writable client
		directory
	
Remarks:
	Keep in mind that results are provided in STDOUT which means you might
	have a newline at the end.

Purpose:
	Simplify the process of finding the writable client directory
"
}
# Else
else
{
	# Make a variable to contain the operating system
	my $OS = "$^O";

	# Load the API for getting the clientdir
	require rsu::files::clientdir;

	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();

	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Replace / with \
		$clientdir =~ s/\//\\/g;
	}

	# Print the clientdir to STDOUT
	print "$clientdir\n";
}

1;
