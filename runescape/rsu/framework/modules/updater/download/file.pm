package updater::download::file; 

sub from
{
	# Get the passed data
	my ($url, $location) = @_;
	
	# Try and load Wx
	eval "use Wx";
	
	# If Wx is loaded successfully (no errors reported)
	if (!$@)
	{
		# Load the native gui to download
		require updater::download::wxdload;
		
		# Download with LWP and show output in a Wx window
		updater::download::wxdload::wxdownload($url,$location);
	}
	else
	{
		# Use the fallback download (using wget or curl and possibly show output in zenity)
		require updater::download::sysdload;
		
		# Run the commands download the file
		updater::download::sysdload($url,$location);
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
