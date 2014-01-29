package client::settings::prms;

sub parseprmfile
{
	# Get the data container
	my ($prmfile, $dir) = @_;
	
	# This module depends on files IO
	require rsu::files::IO;
	
	# Depend on the clientdir module
	require rsu::files::clientdir;
	
	# Depends on the language module
	require client::settings::language;
	
	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Make a variable to store the location of the file
	my $location = "$clientdir/share/prms";
	
	# If a location is passed
	if (defined $dir && $dir ne '')
	{
		# Use $dir as location
		$location = "$dir";
	}
	
	# Fallback parameters
	my $fallbackprms = "jagexappletviewer.jar -Dsun.java2d.noddraw=true -Dcom.jagex.config=http://www.runescape.com/k=3/l=\$(Language:0)/jav_config.ws -Xss2m -Xmx512m jagexappletviewer ";
	# garbage collection prms (useful for "ancient" systems)
	# -XX:CompileThreshold=1500 -Xincgc -XX:+UseConcMarkSweepGC -XX:+UseParNewGC
	
	# If we are not called through an API query
	if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
	{
		# Print debug info
		print "Reading .prm file ".$location."/".$prmfile."\n";
	}
	
	# Read the runescape parameters file and send pointer to $prms
	my $prms = rsu::files::IO::ReadFile($location."/".$prmfile."");
	
	# If there is an error reading the file
	if ($prms =~ /error reading file/)
	{
		# Print debug info
		print STDERR "Error opening ".$location."/".$prmfile."\nI will instead use these fallback parameters:\n".$fallbackprms."\n";
		
		# Use the fallback prms defined at the top of the script
		$prms = $fallbackprms;
	}
	# Else we will convert the pointer to a string
	else
	{		
		# Make the pointer into a string we can work with
		$prms = "@$prms";
		
		# If we are not called through an API query
		if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
		{
			# Print debug info
			print "This is the info I gathered from the ".$prmfile." file\n######## File Start ########\n$prms\n######## File End ########\n\n";
		}
	}
	
	# If we are not called through an API query
	if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
	{
		# Print debug info
		print "I will now parse the parameters!\n";
	}
	
	# Make the string into 1 line
	$prms =~ s/(-Djava.class.path=|\n|\r|\r\n)//g;
	
	# Get the client language settings
	my $lang = client::settings::language::getlanguage();
	
	# If we are not called through an API query
	if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
	{
		# Print debug info
		print "Stitching the language setting to the final parameters.\n\n";
	}
	
	# Apply the language setting to the prms
	$prms =~ s/\$\(Language:0\)/$lang/g;
	
	# If we are not called through an API query
	if ("$ARGV[0]" !~ /get\.(client|rsu)\./)
	{
		# Print debug info
		print "Final parameter string is:\n$prms\n\n";
	}
	
	# Return to call with the whole prm string
	return $prms;
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
