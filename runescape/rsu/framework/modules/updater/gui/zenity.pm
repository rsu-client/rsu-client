package updater::gui::zenity;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape
##############################################################
# This module was written based of Fallen Unia's fork of the #
#        update-runescape-client script to use zenity        #
##############################################################

sub checkfor_zenity
{
	# If we are not on windows
	if ("$^O" !~ /MSWin32/)
	{
		# Make a variable for the results
		my $usezenity;
		
		# Check if zenity is installed
		my $zenity = `ls /usr/bin | grep zenity`;
		
		# If zenity is installed
		if ($zenity =~ /zenity/)
		{
			# Enable zenity
			$usezenity = 1;
		}
		# Else zenity is not installed
		else
		{
			# Disable zenity
			$usezenity  = 0;
		}
		
		# Return status for zenity
		return $usezenity;
	}
	
	# Else return 0
	return 0;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub zenity_dl
{
	# Get the parameters
	# $cmd download command you want to make into a dialog
	# $title is the window title you want
	# $text is the window text
	# $extracmd is any commands you want to run after the download (must start with &&)
	my ($cmd, $title, $text, $extracmd) = @_;
	
	# If $cmd contains wget which lets us use the progressbar in zenity using tee
	if ($cmd =~ /(^|\s+)wget\s+/)
	{
		# Show a zenity window with a progressbar that shows the progress of the download
		system "$cmd 2>&1 | tee /dev/stderr | sed -u \"s/^ *[0-9]*K[ .]*\\([0-9]*%\\).*/\\1/\" | zenity --title=\"$title\"  --text=\"$text\" --progress --no-cancel --auto-close 2>/dev/null $extracmd";
	}
	# Else it is curl or unknown (running zenity download dialog with pulsating progressbar)
	else
	{
		# Show a zenity window with a pulsing progressbar (since curl is not nice when it comes to zenity progressbars) while the scripts are updating
		system "$cmd 2>&1 | tee /dev/stderr | zenity --title=\"$title\" --progress --text=\"$text\n\nUsing curl \(or similar\) to do the download.\nThe window will close when the process is done.\nPlease wait...\" --pulsate --no-cancel --auto-close 2>/dev/null $extracmd";
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub zenity_question
{
	# Get the parameters
	# $title = Window title
	# $text = Window text
	my ($title, $text) = @_;
	
	# Run zenity and display the window
	system "zenity --title=\"$title\" --question --window-icon=\"question\" --text=\"$text\"";
	
	# Make a variable to contain the answer from the user
	my $answer;
	
	# If user answered yes (return value 0)
	if ($? =~ /0/)
	{
		# Set the users answer to y
		$answer = "y";
	}
	# Else user answered no
	else
	{
		# Set the users answer to n
		$answer = "n";
	}
	
	# Return the answer
	return $answer;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub zenity_info
{
	# Get the parameters
	# $title = Window title
	# $text = Window text
	my ($title, $text) = @_;
	
	# Run zenity and display the window
	system "zenity --title=\"$title\" --info --window-icon=\"question\" --text=\"$text\"";
}

#
#---------------------------------------- *** ----------------------------------------
#

sub zenity_error
{
	# Get the parameters
	# $title = Window title
	# $text = Window text
	my ($title, $text) = @_;
	
	# Run zenity and display the window
	system "zenity --title=\"$title\" --error --window-icon=\"error\" --text=\"$text\"";
}

#
#---------------------------------------- *** ----------------------------------------
#

sub zenity_radiolist
{
	# Get the parameters
	my ($title, $text, $options) = @_;
	
	# Display the zenity window and get the users reply
	my $answer = `zenity --title="$title" --list --width=500 --height=300 --radiolist --hide-header --text="$text" --column="" --column="" $options`;
	
	# Return the answer
	return $answer;
}

#
#---------------------------------------- *** ----------------------------------------
#



1;
