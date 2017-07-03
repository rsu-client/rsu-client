package get::client::language;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

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
	6 = Spanish (ES)

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
