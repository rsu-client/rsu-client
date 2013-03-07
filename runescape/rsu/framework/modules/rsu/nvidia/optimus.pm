package rsu::nvidia::optimus;

# Thanks to Tzbob for mentioning that primusrun works with runescape (on arch linux)
# Thanks to 1g for testing this module on ubuntu to see if
# primusrun works with runescape on other distributions!

sub checkforprimus
{
	# Get the pointers
	my ($rsu_data) = @_;
	
	# Tell the user what we are doing
	print "Checking /usr/bin for primusrun\n";
	
	# Check if primusrun exists, otherwise we will be in troubble!
	my $primusrun_check = `ls /usr/bin | grep "primusrun"`;
	
	# Make a variable for the return value
	$return_value = "false";
	
	# If primusrun exists
	if ($primusrun_check =~ /primusrun/)
	{
		# Tell user what we are doing
		print "primusrun found!\nI will tell the script to use it to run java on the Nvidia GPU\n";
		
		# Set return_value to true
		$return_value = "true";
	}
	else
	{
		# Tell the user what we are doing
		print "I did not find primusrun in /usr/bin\nI tell the script to launch java normally\n";
		
		# Set return_value to false
		$return_value = "false";
	}
	
	# Return false if the if condition above did not trigger
	return "$return_value";
}

#
#---------------------------------------- *** ----------------------------------------
#

sub enableprimus
{
	# Get the pointers
	my ($rsu_data) = @_;
	
	# Tell users what we are doing
	print "Executing function to check if primus is installed\n";
	
	# Check if primusrun exists
	my $primusrun_exists = "";
	$primusrun_exists = rsu::nvidia::optimus::checkforprimus($rsu_data);
	
	# Make a variable for the returnvalue
	my $return_value;
	
	# If primusrun exists
	if ($primusrun_exists =~ /true/)
	{
		# Tell users what we are doing
		print "\nprimusrun will be used to launch java!\n\n";
		
		# Return "primusrun"
		$return_value = "primusrun";
	}
	# Else
	else
	{
		# Tell users what we are doing
		print "\nuseprimusrun is enabled, however i did not find primusrun!\nJava will be launched normally!\n\n";
		
		# Set the return_value to blank
		$return_value = "";
	}
	
	# Return the return_value
	return "$return_value";
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
