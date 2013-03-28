package get::client::language;

# Use the module for fetching the language setting for runescape
require client::settings::language;

# If help is passed as a parameter
if ("@ARGV" =~ /\s+help(|\s+)/)
{
	print "API call to fetch the runescape client language preference
Syntaxes:
	$ARGV[0] help
	$ARGV[0]

Examples:
	$ARGV[0]
	result: a string with the number corresponding to the current language
		selected for the client.
	failure: returns \"0\" which is English
	
Remarks:
	Returns an integer however it is read as a string so keep that in mind!
	0 = English (GB)
	1 = German (DE)
	2 = French (FR)
	3 = Portuguese (BR)

Purpose:
	Simplify looking up values of config files
"
}
# Else
else
{
	# Get the language setting
	my $lang = client::settings::language::getlanguage();

	# Write the value to STDOUT
	print "$lang\n";
}

1; 
