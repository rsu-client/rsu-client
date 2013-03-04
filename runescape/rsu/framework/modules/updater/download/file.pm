package updater::download::file; 

sub from
{
	my ($url, $location) = @_;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub wxdownload
{ 
	# Get the passed data
	my ($url, $downloadto) = @_; 
	
	# Use WxWidgets
	use Wx ':everything'; 
	
	# Use LWP::UserAgent which we use to download files
	use LWP::UserAgent;
	
	# Make an LWP agent for use to download the file
	my $lwp_handle = LWP::UserAgent->new();
	
	# Get the remote headers
	my $result = $lwp_handle->head($url);
	
	# Pass the resulting headers to a new mutator 
	my $headers = $result->headers; 
	
	# Place the remote filesize inside $update_size
	my $file_size = $headers->content_length; 
	
	# Make a download dialog
	my $download_dialog = Wx::ProgressDialog->new("Downloading", "", $file_size, undef, wxPD_ELAPSED_TIME | wxPD_ESTIMATED_TIME | wxPD_REMAINING_TIME | wxPD_AUTO_HIDE | wxPD_CAN_ABORT); 
	
	# Show the download dialog
	$download_dialog->Show(1); 
	
	# Make a variable to contain the downloaded data
	my $downloaded_data = ''; 
	
	# Make a variable to contain the abort status
	my $abort = 0; 
	
	# Download the file from $url and save it to $downloadto and callback to wxupdate_progressbar
	my $file_data = $lwp_handle->get($url, ':content_file' => $downloadto, ':content_cb' => \&wxupdate_progressbar ); 
	
	# Add the downloaded data to $file_data
	$file_data = $file_data->content();
	
	# Destroy the progressdialog
	$download_dialog->Destroy(); 
	
	# Return information for wxupdate_progressbar
	return (length $file_data > length $downloaded_data) ? $file_data : $downloaded_data; 
	
	# Make an internal function to update the progressbar (and for easy access to all the variables)
	sub wxupdate_progressbar
	{
		# Get the passed data
		my ($data, $response) = @_;
		
		# Get how many % is downloaded
		$downloaded_data .= $data; 
		
		# Make a variable that contains the size of the download data
		my $status = $download_dialog->Update(length $downloaded_data); 
		
		# If the user aborted the download (then there will not be anything in continue
		if (!$status)
		{
			# Set aborted to 1
			$abort = 1; 
			
			# Abort the download
			$lwp_handle->abort;
			
			# Exit the script
			exit;
		} 
	} 
} 
1;
