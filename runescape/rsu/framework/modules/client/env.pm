package client::env;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

sub home
{
	# Make a variable to contain the users HOME directory
	my $HOME;
	
	# Get the OS
	my $OS = "$^O";

	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Get the userprofile directory
		$HOME = $ENV{"USERPROFILE"};
	}
	# Else
	else
	{
		# Get the users HOME directory
		$HOME = $ENV{"HOME"};
	}
	
	# Return the HOME directory
	return $HOME;
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
