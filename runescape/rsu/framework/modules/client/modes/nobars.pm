package client::modes::nobars;

sub remove_bars
{
	# Get the passed data
	my ($offset_top, $offset_bottom) = @_;
	
	# Get the current OS we are on
	my $OS = "$^O";
	
	# If we are on Windows or Mac
	if ($OS =~ /(MSWin32|darwin)/)
	{
		# Tell that the option is not supported
		print STDERR "\nThe nobars mode is not supported on $OS.\nIgnoring the option\n\n";
	}
	# Else
	else
	{
		# Require the files grep module
		require rsu::files::grep;
		
		# Check if wmctrl is installed
		my @wmctrlcheck = rsu::files::grep::dirgrep("/usr/bin", "^wmctrl\$");
		
		# If we did not find wmctrl
		if ("@wmctrlcheck" !~ /wmctrl/)
		{
			# Print a message
			print STDERR "wmctrl not found in /usr/bin\nI will not attempt to resize the window to hide the bars\n\n";
			
			# Return to call
			return;
		}
		# Else
		else
		{
			# Run wmctrl -d to find the dimensions we need
			my $dimensions = `wmctrl -d`;
			
			# Locate the current screen
			my @wmctrl_res = rsu::files::grep::strgrep($dimensions, "\\*");
			
			# Split by spaces
			@wmctrl_res = split / /, "@wmctrl_res";
			
			# $wmctrl_res[4] = screen resolution
			# $wmctrl_res[11] = desktop resolution
			
			# Move the screen resolution to a new variable
			my $screen_h = $wmctrl_res[4];
			
			# Get the height of both screen and desktop
			$screen_h =~  s/^.+x(.*)$/$1/;
			my @desk_wh = split /x/, $wmctrl_res[11];
			
			# Get the height of the panel
			my $panel_h = $screen_h-$desk_wh[1];
			
			# Calculate the extra height
			my $extraheight = $panel_h+$offset_bottom;
			
			# Add $extraheight and the max window height together
			$desk_wh[1] += $extraheight;
			
			# Execute wmctrl to resize the runescape client window
			system "wmctrl -F -r RuneScape -e 0,0,$offset_top,$desk_wh[0],$desk_wh[1]";
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
