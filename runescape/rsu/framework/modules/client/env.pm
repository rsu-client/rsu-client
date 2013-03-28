package client::env;

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
