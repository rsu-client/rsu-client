package rsu::download::file;

# Use the module for Cwd
require rsu::files::clientdir;
my $clientdir = rsu::files::clientdir::getclientdir();

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call to download a file from an URL
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0] URL [\"directory\"
	
DEFAULTS:
	directory = \$clientdir/.tmp
	
NOTES:
	The directory parameter is the location
	you want the file to be downloaded to.

Examples:
	$ARGV[0] http://www.runescape.com/downloads/runescape.msi
	result: downloads the runescape.msi to $clientdir/.tmp
	
	$ARGV[0] http://www.runescape.com/downloads/runescape.msi \"/tmp\"
	result: downloads the runescape.msi to /tmp
	
Remarks:
	Returns nothing when done

Purpose:
	Simplify the task of downloading a file from an url
"

}
# Else
else
{
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Require the download API
	require updater::download::file;
	
	# Split the url by /
	my @filename = split /\//, $ARGV[1];
	
	# Make a variable that contains the download location
	my $location = rsu::files::clientdir::getclientdir()."/.download/$filename[-1]";
	
	# If a location is defined
	if ($ARGV[2] ne '')
	{
		# Pass the location to the downloadto variable
		$location = $ARGV[2];
	}
	
	# Download the file
	updater::download::file::from($ARGV[1], $location);
}

1; 
