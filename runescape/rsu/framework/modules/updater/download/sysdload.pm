package updater::download::sysdload;

# This function provides a way to download files if the binary version of rsu-query is not installed
# (meaning the system perl might not be compatible with the other commands)
sub sysdownload
{
	# Get the passed data
	my ($url, $downloadto) = @_;
	
	# Make a variable which will contain the download command we will use
	my $fetchcommand = "wget -O";
	
	# If /usr/bin contains wget
	if(`ls /usr/bin | grep wget` =~  /wget/)
	{
		# Use wget command to fetch files
		$fetchcommand = "wget -O";
	}
	# Else if /usr/bin contains curl
	elsif(`ls /usr/bin | grep curl` =~  /curl/)
	{
		# Curl command equalent to the wget command to fetch files
		$fetchcommand = "curl -L -# -o";
	}
	
	# Split the url by /
	my @filename = split /\//, $url;
	
	# Download the file
	system "$fetchcommand \"$downloadto\" $url";
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
