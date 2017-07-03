package rsu::files::clientdir;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

sub getclientdir
{
	# Use the Cwd module to get the current working directory
	use Cwd;
	
	# Get the current working directory
	my $cwd = getcwd;
	
	# Use the FileBin module to get the running scripts directory
	use FindBin;
	
	# Get the script directory
	my $scriptdir = $FindBin::RealBin;
	
	# Require the module that lets us get the users home folder
	require client::env;
	
	# Get the users home directory
	my $HOME = client::env::home();
	
	# Make a variable to contain the clientdir
	my $clientdir = $cwd;
	
	# If this script have been installed systemwide
	if ($scriptdir =~ /^(\/usr\/s?bin|\/opt\/|\/usr\/local\/s?bin)/)
	{
		# Change $clientdir to ~/.config/runescape
		$clientdir = "$HOME/.config/runescape";
	}
    # Else
    else
    {
        # Make sure that addons dont get their own directory
        $clientdir =~ s/\/share\/addons\/(universal|darwin|MSWin32|linux)\/.+$//;
    }
	
	# Return the result
	return $clientdir;
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
