package updater::download::file;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

sub from
{
	# Get the passed data
	my ($url, $location, $nogui) = @_;
	
	# Make a variable to tell if there is no LWP module available
	my $nolwp = 0;
	
	# Test to see if LWP::UserAgent is available on the system and set $nolwp to 1 if LWP is not available
	eval "use LWP::UserAgent"; $nolwp = 1 if $@;
	
	# If we are not running on a PAR Packaged version then disable lwp
	$nolwp = 1 if "@INC" !~ /par-/;
	
	# Try and load Wx and set $nogui to 1 if Wx cannot be loaded
	eval "use Wx"; $nogui = 1 if $@;
	# Try to use functions from perl 5.012
	eval "use 5.012";
	
	# Remove warnings as the dependent modules of LWP outputs quite a few which can be ignored
	no strict;
	no warnings;
	
	# If Wx is not loaded or $nogui is 1 or $nolwp is 1 then
	if (($@) || (defined $nogui && $nogui eq '1') || $nolwp eq '1')
	{
		# If no use of gui is demanded then
		if (defined $nogui && $nogui eq '1')
		{
			# Use the fallback download using LWP and output only to STDOUT
			require updater::download::sysdload;

			# Run the commands download the file
			updater::download::sysdload::sysdownload($url,$location);
		}
		# Else
		else
		{
			# Use the fallback Wx Download dialog which uses wget or curl
			require updater::download::wxsysdload;

			# Run the commands download the file
			updater::download::wxsysdload::wxsysdownload($url,$location);
		}
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
