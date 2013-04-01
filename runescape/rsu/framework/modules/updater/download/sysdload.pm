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

sub readurl
{
	# Get the passed data
	my ($url) = @_;
	
	# Get the current OS
	my $OS = "$^O";
	
	# Make a variable to contain the output
	my $output;
	
	# If we are on Windows
	if ($OS =~ /MSWin32/)
	{
		# Use LWP::Simple
		eval "use LWP::Simple";
		
		# Get the content of $url
		$output = get("$url");
	}
	# Else
	else
	{
		# Make a variable which will contain the download command we will use
		my $fetchcommand = "wget -q -O-";
		
		# If /usr/bin contains wget
		if(`ls /usr/bin | grep wget` =~  /wget/)
		{
			# Use wget command to fetch files
			$fetchcommand = "wget -q -O-";
		}
		# Else if /usr/bin contains curl
		elsif(`ls /usr/bin | grep curl` =~  /curl/)
		{
			# Curl command equalent to the wget command to fetch files
			$fetchcommand = "curl -L -#";
		}
		
		# Read the contents of url
		$output = `$fetchcommand $url`;
		
		# Remove any newlines
		$output =~ s/(\n|\r|\r\n)//g;
	}
	
	# Return the content of $url
	return $output;
}

#
#---------------------------------------- *** ----------------------------------------
#



1; 
