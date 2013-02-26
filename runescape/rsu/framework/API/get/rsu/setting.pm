package get::rsu::setting;

# Use the file IO
use rsu::file::IO;

# Use the module for Cwd
use Cwd;
my $cwd = getcwd;

# If parameters are missing or help is passed
if ("$ARGV[1]" =~ /(^$|help)/i || "$ARGV[2]" =~ /(^$|help)/i)
{
	# Tell user how to use this call
	print "API call to fetch values from RSU .config files.
Syntaxes:
	$ARGV[0] help
	$ARGV[0] file.conf listkeys
	$ARGV[0] file.conf content
	$ARGV[0] file.conf key

Examples:
	$ARGV[0] settings.conf preferredjava
	result: the value of preferredjava in settings.conf
	failure: returns \"undef\"
	
	$ARGV[0] settings.conf listkeys
	result: list all setting keys in settings.conf
	failure: empty string
	
	$ARGV[0] settings.conf content
	result: list uncommented content of settings.conf
	failure: empty string
	
Remarks:
	Certain programming languages may get a newline behind results/failures.

Purpose:
	Simplify looking up values of config files
"

}
# Else if listkeys is passed as second parameter
elsif("$ARGV[2]" =~ /^listkeys$/)
{
	# Get the list of the config content
	my $list = rsu::file::IO::getcontent($cwd, $ARGV[1]);
	
	# Remove everything between = and newlines
	$list =~ s/=(.+)\n/\n/g;
	
	# Print all keys in the file
	print "$list";
}
# Else if content is passed as second parameter
elsif("$ARGV[2]" =~ /^content$/)
{
	# Get the list of the config content
	my $list = rsu::file::IO::getcontent($cwd, $ARGV[1]);
	
	# Print the contents of the file
	print "$list";
}
# Else
else
{	
	# Read the config file
	my $value = rsu::file::IO::readconf($ARGV[2], "undef", $ARGV[1], $cwd);
	
	# Print the value of the key
	print "$value\n";
}

1; 
