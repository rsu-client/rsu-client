package set::rsu::setting;

# Use the file IO
use rsu::files::IO;

# Use the module for Cwd
use Cwd;
my $cwd = getcwd;

# If parameters are missing or help is passed
if ("$ARGV[1]" =~ /(^$|^help$)/i || "$ARGV[2]" =~ /(^$|^help$)/i || "$ARGV[3]" =~ /(^$|^help$)/i)
{
	# Tell user how to use this call
	print "API call to set values for keys in RSU .config files.
Syntaxes:
	$ARGV[0] help
	$ARGV[0] file.conf key value

Examples:
	$ARGV[0] settings.conf preferredjava default-java
	result: returns nothing & sets the value of preferredjava to default-java in settings.conf
	failure: creates file and adds the info
	
Remarks:
	Certain programming languages may get a newline behind results/failures.

Purpose:
	Simplify setting values to keys in config files
"

}
# Else
else
{	
	# Read the content of the config file
	my $content = rsu::files::IO::getcontent("$cwd/share", "$ARGV[1]");
	
	# If nothing returned or the key is not found
	if ($content =~ /^\n$/ || $content !~ /$ARGV[2]=(.+)\n/)
	{
		# Write a new file
		rsu::files::IO::WriteFile("$ARGV[2]=$ARGV[3]", ">>", "$cwd/share/$ARGV[1]");
	}
	# Else
	else
	{
		# Replace the old value with the new one
		$content =~ s/$ARGV[2]=.+\n/$ARGV[2]=$ARGV[3]\n/;
		
		# Remove the newline at the end
		$content =~ s/\n$//;
		
		# Write the contents back to the file
		rsu::files::IO::WriteFile($content, ">", "$cwd/share/$ARGV[1]");
	}
}

1; 
