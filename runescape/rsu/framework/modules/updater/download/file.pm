package updater::download::file; 

sub from
{
	# Get the passed data
	my ($url, $location, $nogui) = @_;
	
	# Try and load Wx
	eval "use Wx";
	
	# Remove warnings as the dependent modules of LWP outputs quite a few which can be ignored
	no strict;
	no warnings;
	
	# If Wx is not loaded or $nogui is 1 then
	if (($@) || (defined $nogui && $nogui eq '1'))
	{
		# Use the fallback download using LWP and output only to STDOUT
		require updater::download::sysdload;

		# Run the commands download the file
		updater::download::sysdload::sysdownload($url,$location);
	}
	# Else if Wx is loaded successfully (no errors reported)
	else
	{
		# Load the native gui to download
		require updater::download::wxdload;
		
		# Download with LWP and show output in a Wx window
		updater::download::wxdload::wxdownload($url,$location);
	}
	
	# Enable warnings again
	use strict;
	use warnings;
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
