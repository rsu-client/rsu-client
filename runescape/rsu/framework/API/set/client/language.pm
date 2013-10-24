package set::client::language;

# Use the module for fetching the language setting for runescape
require client::settings::language;

# Use the file IO module
require rsu::files::IO;

# If the first parameter is help
if ("$ARGV[1]" =~ /^help$/)
{
	print "API call to set the runescape client language preference
Syntaxes:
	$ARGV[0] help
	$ARGV[0] int

Examples:
	$ARGV[0] 1
	result: sets the client language to 1 which is German
	failure: creates the file and sets the value
	
Remarks:
	Returns an integer however it is read as a string so keep that in mind!
	0 = English (GB)
	1 = German (DE)
	2 = French (FR)
	3 = Portuguese (BR)
	6 = Spanish (ES)

Purpose:
	Simplify setting the client language preference
"
}
# Else
else
{
	# Set the client language
	client::settings::language::setlanguage("$ARGV[1]");
}

1; 
