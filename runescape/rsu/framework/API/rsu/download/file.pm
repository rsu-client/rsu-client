package rsu::download::file;

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call to download a file from an URL
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0] URL [\"directory\"
	
DEFAULTS:
	directory = \$clientdir/.download
	
NOTES:
	The directory parameter is the location
	you want the file to be downloaded to.
	The directory can just be the foldername in which case
	it will result in \$clientdir/foldername

Examples:
	$ARGV[0] http://www.runescape.com/downloads/runescape.msi
	result: downloads the runescape.msi to \$clientdir/.download
	
	$ARGV[0] http://www.runescape.com/downloads/runescape.msi \"/tmp\"
	result: downloads the runescape.msi to /tmp
	
	$ARGV[0] http://www.runescape.com/downloads/runescape.msi \"tmp\"
	result: downloads the runescape.msi to \$clientdir/tmp
	
Remarks:
	Returns nothing unless Wx is not installed.
	If Wx is not installed the download progress will be
	written to STDOUT.

Purpose:
	Simplify the task of downloading a file from an url
"

}
# Else
else
{
	# Use the File::Path module so we get a crossplatform mkpath and rmdir implementation
	use File::Path qw(make_path);
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Require the download API
	require updater::download::file;
	
	# Split the url by /
	my @filename = split /\//, $ARGV[1];
	
	# Make a variable that contains the download location
	my $location = "$clientdir/.download";
	
	# If a 2nd parameter is passed
	if ($ARGV[2] ne '')
	{
		# If the parameter starts with a full path or variable
		if ($ARGV[2] =~ /^(\$|\%|[a-z]:|\/)/i)
		{
			# Use parameter as location
			$location = $ARGV[2];
		}
		# Else
		else
		{
			# Use the parameter as foldername
			$location = "$clientdir/$ARGV[2]";
		}
	}
	
	# Make the download location
	make_path($location);
	
	# Append the filename to the location
	$location = "$location/$filename[-1]";
	
	# Download the file
	updater::download::file::from($ARGV[1], $location);
}

1; 
