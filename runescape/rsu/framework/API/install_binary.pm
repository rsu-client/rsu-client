package install_binary;

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call which downloads and installs the binary version of rsu-query
Syntaxes:
	$ARGV[0] help
	$ARGV[0]

Examples:
	$ARGV[0]
	result: Downloads and extracts the latest rsu-query binary for the current OS
	
Remarks:
	Returns nothing, and only works on linux and darwin/MacOSX

Purpose:
	Make it possible to download and install the rsu-query binary
"
}
else
{
	# Get the current OS
	my $OS = "$^O";
	
	# If we are on darwin/MacOSX or linux
	if ($OS =~ /(darwin|linux)/)
	{
		# Require the query_bin module
		require updater::extract::query_bin;
		
		# Download and install the rsu-query binary
		updater::extract::query_bin::update(1);
	}
	else
	{
		# Tell user they are on an unsupported OS
		print STDERR "Youre running on $OS\neither your OS does not have an official rsu-query binary or your\narchitecture is not supported.\n";
	}
}

1; 
