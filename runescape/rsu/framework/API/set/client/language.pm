package set::client::language;

# Use the module for fetching the language setting for runescape
use client::settings::language;

# Use the file IO module
use rsu::files::IO;

# Get the OS we are running on
my $OS = "$^O";

# Make a variable to contain the users HOME directory
my $HOME;

# If we are on windows
if ($OS =~ /MSWin32/)
{
	# Get the userprofile directory
	$HOME = $ENV{"USERPROFILE"};
}
# Else
else
{
	# Get the users HOME directory
	$HOME = $ENV{"HOME"};
}

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

Purpose:
	Simplify setting the client language preference
"
}
# Else
else
{
	# Read the content of the config file
	my $content = rsu::files::IO::getcontent($HOME, "jagexappletviewer.preferences");
	
	# If nothing returned or the key is not found
	if ($content =~ /^\n$/ || $content !~ /Language=(.+)\n/)
	{
		# Write a new file
		rsu::files::IO::WriteFile("Language=$ARGV[1]", ">>", "$HOME/jagexappletviewer.preferences");
	}
	# Else
	else
	{
		# Replace the old value with the new one
		$content =~ s/Language=(.+)\n/Language=$ARGV[1]\n/;
		
		# Remove the newline at the end
		$content =~ s/\n$//;
		
		# Write the contents back to the file
		rsu::files::IO::WriteFile($content, ">", "$HOME/jagexappletviewer.preferences");
	}
}

1; 
