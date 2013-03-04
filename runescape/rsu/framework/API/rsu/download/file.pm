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
	
	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	updater::download::file::wxdownload("http://www.runescape.com/downloads/runescape.msi", "$clientdir/runescape.msi");
}

1; 
