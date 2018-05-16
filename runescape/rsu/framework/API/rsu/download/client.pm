package rsu::download::client;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call to download the RuneScape client and extract it
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0] [\"jardir\" [dmg|msi|jar
	
DEFAULTS:
	jardir = bin
	
	# Which client to download
	dmg|msi|jar = dmg is not on windows and msi is not on mac
	
	# Platform defaults
	Windows = jar (no support for dmg)
	MacOSX = jar (no support for msi)
	Linux = jar (unless dmg is requested)
	
NOTES:
	The msi|dmg parameter is Linux only.
	If downloading the msi file then the jawt dll files are extracted
	too in order to support the wine compability mode.

	jardir has to be a foldername or relative location
	witin \$clientdir.

Examples:
	$ARGV[0]
	result: downloads the runescape client installer and extracts the jar file
	
	$ARGV[0] \"JAR/applet\"
	result: downloads the runescape client installer and extracts the jar file
		to \$clientdir/JAR/applet
	
	# Linux Only
	$ARGV[0] dmg
	result: downloads the runescape.dmg and extracts the jar file
	
	$ARGV[0] \"JAR/applet\" msi
	result: downloads the oldschool.msi and extracts the jar file and jawt for wine
	
Remarks:
	Returns nothing.

Purpose:
	Simplify the task of downloading and extracting the jagexappletviewer.jar
"

}
# Else
else
{
	# Use the File::Path module so we get a crossplatform mkpath and rmdir implementation
	use File::Path qw(make_path remove_tree);
	
	# Get the current OS
	my $OS = "$^O";
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Require the extract client module
	require updater::extract::client;
	
	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Require the download API
	require updater::download::file;
	
	# Make a variable to contain the download url for the jar file directly
	my $url = "https://www.runescape.com/downloads/jagexappletviewer.jar";
	
	# If we are on Mac or we are on linux and dmg is passed
	if (($OS =~ /(linux|darwin)/ && defined $ARGV[1] && $ARGV[1] =~ /^dmg$/i) || ($OS =~ /(linux|darwin)/ && defined $ARGV[2] && $ARGV[2] =~ /^dmg$/i))
	{
		# Download the dmg file instead
		$url = "https://www.runescape.com/downloads/runescape.dmg";
	}
	# Else If we are on Windows or we are on linux and msi is passed
	elsif (($OS =~ /(linux|MSWin32)/ && defined $ARGV[1] && $ARGV[1] =~ /^msi$/i) || ($OS =~ /(linux|MSWin32)/ && defined $ARGV[2] && $ARGV[2] =~ /^msi$/i))
	{
		# Download the msi file instead
		$url = "https://www.runescape.com/downloads/oldschool.msi";
	}
        elsif (($OS =~ /linux/) && !defined $ARGV[1] && !defined $ARGV[2])
        {
                # Use the msi on linux by default
                $url = "https://www.runescape.com/downloads/oldschool.msi";
        }
	
	# Split the url by /
	my @filename = split /\//, $url;
	
	# Make a variable that contains the download location
	my $location = "$clientdir/.download";
	
	# Make the download location
	make_path($location);
	
	# Append the filename to the location
	$location = "$location/$filename[-1]";
	
	# Download the file
	updater::download::file::from($url, $location);
	
	# Make a variable to contain the path we shall place the jar file
	my $placejar = "bin";
	
	# If the first parameter is not a full path but does contain / or \ then
	if(defined $ARGV[1] && $ARGV[1] !~ /^(\$|\%|[a-z]:|\/)/i && $ARGV[1] =~ /(.\/.+|.\\.+)/i)
	{
		# Use $clientdir as the base location and add the parameter at the end
		$placejar = "$ARGV[1]";
	}
	# Else if the first parameter is not a full path, does not contain / or \ and is not dmg or msi then
	elsif(defined $ARGV[1] && $ARGV[1] !~ /^(\$|\%|[a-z]:|\/)/i && $ARGV[1] !~ /(.\/.+|.\\.+)/i && $ARGV[1] !~ /^(dmg|msi)$/i)
	{
		# Use the parameter as foldername
		$placejar = "$ARGV[1]";
	}
	
	# Extract the client
	rsu::download::client::extractclient($placejar, "$filename[-1]");
}

sub extractclient
{
	# Get the passed data
	my ($placejar, $filename) = @_;
	
	# Get the current OS
	my $OS = "$^O";
	
	# Get the client directory
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# If we are not on MacOSX and the filename is oldschool.msi
	if ($filename =~ /oldschool.msi/ && $OS !~ /darwin/)
	{
		# Run the msiextract function
		updater::extract::client::msiextract($placejar,"true");
	}
	# Else if filename is runescape.dmg and we are not on Windows
	elsif($filename =~ /runescape.dmg/ && $OS !~ /MSWin32/)
	{
		# Run the dmgextract function
		updater::extract::client::dmgextract($placejar);
	}
	# Else if filename is runescape.dmg and we are not on Windows
	elsif($filename =~ /jagexappletviewer.jar/)
	{
		# Run the dmgextract function
		updater::extract::client::jarextract($placejar);
	}
	
	# Remove the download directory
	remove_tree("$clientdir/.download");
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
