package get::client::prms;

if ("@ARGV" =~ /\s+help(|\s+)/)
{
	print "API call to fetch the java parameters from a .prm file
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0]
	$ARGV[0] prmfile [directory
	
DEFAULTS:
	directory = \$clientdir/share/prms

Examples:
	$ARGV[0]
	result: a 1 line string with the parameters from runescape.prm located
		inside \$clientdir/share/prms
	
	$ARGV[0] oldschool.prm
	result: a 1 line string with the parameters from oldschool.prm located
		inside \$clientdir/share/prms
		
	$ARGV[0] custom.prm \"D:\\\"
	or
	$ARGV[0] custom.prm \"/media/usb\"
	result: a 1 line string with the parameters from custom.prm located
		inside D:\\ or /media/usb
	
	failure: returns fallback parameters (any syntax)
	
Remarks:
	Returns a 1 line string, however you might get a newline at the end
	from the STDOUT, also this API call will use the clients language setting
	unless it is manually specified inside the -Dcom.jagex.config line in the
	.prm file

Purpose:
	Simplify the task of reading the .prm file
"
}
# Else
else
{
	# Require the files IO module
	require rsu::files::IO;

	# Require the clientdir module
	require rsu::files::clientdir;

	# Require the prm module
	require client::settings::prms;

	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();

	# Make a variable containing the location of the prm file
	my $location = "$clientdir/share/prms";

	# If a location is is passed
	if ($ARGV[2] ne '')
	{
		# If the parameter starts with a full path or variable
		if ($ARGV[2] =~ /^(\$|\%|[a-z]:|\/)/i)
		{
			# Use parameter as location
			$location = $ARGV[2];
		}
		# Else
		else
		{
			# Use the parameter as foldername
			$location = "$clientdir/$ARGV[2]";
		}
	}

	# Make a variable to contain the prmfile name
	my $prmfile = rsu::files::IO::readconf("prmfile", "undef", "settings.conf", "$location");

	# If a filename is passed
	if ($ARGV[1] ne '')
	{
		# Use parameter as prmfile
		$prmfile = $ARGV[1];
	}

	# Get the contents of the prmfile
	my $prms = client::settings::prms::parseprmfile($prmfile, $location);

	# Print the java parameters
	print "$prms\n";

}

1; 
