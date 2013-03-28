package updater::download::wxsysdload;

sub wxsysdownload
{
	# Get the passed data
	my ($url, $downloadto) = @_; 
	
	# Use WxWidgets
	use Wx ':everything';
	
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
	
	# Make a download dialog
	my $download_dialog = Wx::ProgressDialog->new("Downloading", "Downloading file: $filename[-1]", 100, undef, wxPD_ELAPSED_TIME | wxPD_AUTO_HIDE | wxPD_CAN_ABORT); 
	
	# Show the download dialog
	$download_dialog->Show(1);
	
	# If we are using wget to download
	if ($fetchcommand =~ /^wget/)
	{
		# Start the download
		open(DLOAD, "$fetchcommand $downloadto $url 2>&1 |");
		
		# While process is active
		while (<DLOAD>)
		{
			# Pass the data, dialog and fetchcommand to the function which updates the download dialog
			wxsysupdate_progressbar($_, $download_dialog, $fetchcommand) if $fetchcommand =~ /^wget/;
		}
		
		# Close the handle
		close DLOAD;
	}
	# Else
	else
	{
		# Start a child process
		my $curl= fork();
		
		# If child process is started
		if ($curl == 0)
		{
			# Start the download
			exec "$fetchcommand $downloadto $url 2>&1";
			
			exit(1);
		}
		
		# Use the POSIX module, but only import the functions for system wait
		eval 'use POSIX ":sys_wait_h"';
		
		# Get the status of the child process (curl) without hanging the GUI
		my $childstatus = waitpid $curl, &WNOHANG;
		
		# While the child process (curl) is still running
		while ($childstatus == 0)
		{
			# Refresh the status of the child process
			$childstatus = waitpid $curl, &WNOHANG;

			# Set the progressbar to pulsating
			my $status = $download_dialog->Pulse("Downloading file: $filename[-1]") if $fetchcommand =~ /^curl/;
			
			# If the user aborted the download (then there will not be anything in continue
			if (!$status)
			{
				# Kill the child process
				kill("KILL",$curl);
				
				# Close the dialog
				$download_dialog->Destroy();
				
				# Exit the script
				exit;
			}
		}
	}
	
	# Destroy the progressdialog
	$download_dialog->Destroy(); 
}

#
#---------------------------------------- *** ----------------------------------------
#

# Make an internal function to update the progressbar (and for easy access to all the variables)
sub wxsysupdate_progressbar
{
	# Get the passed data
	my ($data, $dialog, $fetchcommand) = @_;
	
	# Get how many % is downloaded
	$data =~ s/^ *[0-9]*K[ .]*([0-9]*)%.*\n/$1/;
	
	# Update the title
	$dialog->SetTitle("Downloading [$data%]") if $data =~ /^[0-9]/;
	
	# Make a variable that contains status of the download
	my $status;
	
	# Update the progressbar and get the status if the $data is a numeric value
	$status = $dialog->Update($data) if $data =~ /^[0-9]/;
	
	# If the user aborted the download (then there will not be anything in continue
	if (!$status)
	{
		# Set aborted to 1
		$abort = 1;
		
		# Close the dialog
		$dialog->Destroy();
		
		# Exit the script
		exit;
	} 
}

1;
