package updater::download::sysdload;

sub sysdownload
{
	# Autoflush outputs from terminal/cmd
	$|=1;
	
	# Get the passed data
	my ($url, $downloadto) = @_;
	
	# Use LWP::UserAgent which we use to download files
	use LWP::UserAgent;
	
	# Split the url by /
	my @filename = split /\//, $url;
	
	# Make an LWP agent for use to download the file
	my $lwp_handle = LWP::UserAgent->new();
	
	# Get the remote headers
	my $result = $lwp_handle->head($url);
	
	# Pass the resulting headers to a new mutator 
	my $headers = $result->headers; 
	
	# Place the remote filesize inside $update_size
	my $file_size = $headers->content_length;
	
	# Make a variable to contain the downloaded data
	my $downloaded_data = '';  
	
	# Download the file from $url and save it to $downloadto and callback to wxupdate_progressbar
	my $file_data = $lwp_handle->get($url, ':content_file' => $downloadto, ':content_cb' => \&print_progress ); 
	
	# Add the downloaded data to $file_data
	$file_data = $file_data->content();
	
	# Return information for wxupdate_progressbar
	return (length $file_data > length $downloaded_data) ? $file_data : $downloaded_data; 
	
	# Make an internal function to print the progress to the terminal
	sub print_progress
	{
		# Get the passed data
		my ($data, $response) = @_;
		
		# Get the data that is downloaded
		$downloaded_data .= $data; 
		
		# Get how many bytes is downloaded
		$downloaded_bytes = length $downloaded_data;
		
		# Get the rough percentage of the download
		my $percentage = ($downloaded_bytes/$file_size)*100;
		
		# Convert bytes to kb
		my $downloaded_kb = $downloaded_bytes/1000;
		my $total_kb = $file_size/1000;
		
		# Remove the decimals
		$percentage =~ s/(\..+)//g;
		$downloaded_kb =~ s/(\..+)//g;
		$total_kb =~ s/(\..+)//g;
		
		# Print the download process to STDOUT
		print "Downloading: $filename[-1] [$percentage%] - ".$downloaded_kb."kb of ".$total_kb."kb\n";
	} 
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
