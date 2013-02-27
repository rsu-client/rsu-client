package client::launch::runescape;
#
#    The main script of the rsu-client, this takes care of overhead stuff
#    Copyright (C) 2011-2013  HikariKnight
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
####
# All files(except jagexappletviewer.jar) and modules used by this script
# uses the same license stated above unless something else is specified
# in their header. External commands use their own license
####
# This script is written by HikariKnight and is free to use and modify
# as it fit you within the rules of runescape, it is based on 
# Ethoxyethaan's forum post on runescape showing how to use the files 
# from the windows client to run it through the command line but with 
# limited functionality. I wrote this perl script in an attempt to port 
# the runescape client to linux and all other unix systems capable of 
# running java, the script also implement language settings support and 
# can be updated by replacing the bin/jagexappletviewer.jar and share/runescape.prm
# with the ones found in the windows client.

# This script is free to use and redistribute(as long credits are kept)
# If you like this script you may want to check out my other projects at
# http://hkprojects.weebly.com

my $scriptversion = "4.0.0";

# Before starting show runescape script version
print "RuneScape Unix Client script version $scriptversion\n\n";

# Use FindBin module to get script directory
use Cwd;
# Get script directory
my $cwd = getcwd;

# Include perl modules in ./modules/client_modules
#use lib $FindBin::RealBin."/modules/client_modules";
require client::init;

# Create a variable to store mutators inside for use as
# transport of information through module functions
my $rsu_data = {};
bless $rsu_data;

# Create mutators and add them to the variable
$rsu_data->create_mutator(qw(version OS cwd clientdir javabin javaversion HOME args verboseprms compabilitymode preferredjava forcepulseaudio forcealsa prmfile useprimusrun fallbackprms));

# Add clientdir data to the data container
$rsu_data->clientdir = $cwd;
# Add cwd data to the data container
$rsu_data->cwd = $cwd;
# Add scriptversion to the data container
$rsu_data->version = $scriptversion;
# Add all the arguments passed to the script to the data container
$rsu_data->args = "@ARGV";

# Detect the current OS and add it to the data container
$rsu_data->OS = "$^O";

checkforcleanup();

# If we are on windows
if ($rsu_data->OS =~ /MSWin32/)
{
	# Get the environment variable for USERPROFILE
	$rsu_data->HOME = $ENV{"USERPROFILE"};
	# Replace all backslashes with forward slashes
	$rsu_data->HOME =~ s/\\/\//g;
}
# Else we are on UNIX
else
{
	$rsu_data->HOME = $ENV{"HOME"};
}

# Make a variable to contain the location of the homefolder for use later in the script
my $HOME = $rsu_data->HOME;

# If --version was provided then print out the version info
if ($rsu_data->args =~ /--version/)
{
	# Version is now printed at the start of the script so just exit instead
	#print "RuneScape UNIX Client Script version: $scriptversion\n";
	exit;
}
elsif ($rsu_data->args =~ /--help/)
{
	# Display the help text
	print "Run the \"runescape\" without any parameters to launch the client normally.
There are however some parameters you can use to alter
the behaviour of the script.
   Launch client by using java from wine: 
     runescape --compabilitymode
	
VERBOSE MODES (warning!: outputs alot of text):
   Make java display full verbose output: 
     runescape --verbose
	
   Make java display selected verbose outputs (jni, gc and class verbose)
      runescape --verbose:jni
      runescape --verbose:gc
      runescape --verbose:class
   
   All 3 of the above verbose modes can be used together like this.
      runescape --verbose:gc --verbose:jni
		
   Save verbose output to a file:
   Simply add \"&> \$HOME/verbose.txt\" at the end of the command like this.
      runescape --verbose &> \$HOME/verbose.txt
      runescape --verbose:class --verbose:jni &> \$HOME/verbose.txt
      
   The file verbose.txt in your homefolder will then contain all the output.\n";
	exit;	
}

# If this script have been installed systemwide
if ($rsu_data->cwd =~ /^(\/usr\/s?bin|\/opt\/|\/usr\/local\/s?bin)/)
{
	# Print debug info
	print "The script is running from a system path!\n".$rsu_data->HOME."/.config/runescape will be used as client folder instead!\n\n";
		
	# Change clientdir to ~/.config/runescape
	$rsu_data->clientdir = $rsu_data->HOME."/.config/runescape/";
		
	# Make the client folders
	system "mkdir -p \"".$rsu_data->HOME."/.config/runescape/bin\" && mkdir -p \"".$rsu_data->HOME."/.config/runescape/share\"";
		
	# Symlink or Copy needed resources to the clientdir
	system "ln -s \"".$rsu_data->cwd."/share/jagexappletviewer.png\" \"".$rsu_data->clientdir."/share/jagexappletviewer.png\" && cp -v \"".$rsu_data->cwd."/share/settings.conf.example\" \"".$rsu_data->clientdir."/share/settings.conf.example\" && cp -v \"".$rsu_data->cwd."/share/runescape.prm.example\" \"".$rsu_data->clientdir."/share/runescape.prm.example\" && cp -v \"".$rsu_data->cwd."/share/runescape-beta.prm\" \"".$rsu_data->clientdir."/share/runescape-beta.prm\"";
	
	# Make a variable to contain the clientdir so we can use it in a command
	my $clientdir = $rsu_data->clientdir;
	
	# Check if runescape.prm exists
	my $prmfile_exists = `ls -la $clientdir/share|grep -P \"runescape.prm\$\"`;
		
	# If runescape.prm do not exist
	if ($prmfile_exists !~ /runescape.prm/)
	{
		# Copy the example file to clientdir as runescape.prm
		system "cp -v \"".$rsu_data->cwd."/share/runescape.prm.example\" \"".$rsu_data->clientdir."/share/runescape.prm\"";
	}
		
}
# Else if script is installed locally
elsif($rsu_data->cwd =~ /$HOME\/.local\/bin/)
{
	# Print debug info
	print "We are running from ".$rsu_data->cwd.", however the client\nshould be at \\\$HOME/.local/share/runescape\nchanging directory to \\\$HOME/.local/share/runescape\n\n";
		
	# change cwd to the local installation location
	$cwd = $rsu_data->HOME."/.local/opt/runescape";
}

# Due to legal reasons the file jagexappletviewer.jar is no longer included by default so we need to check if it exists
# If jagexappletviewer.jar do not exist inside the $rsu_data->cwd/bin folder then
client::appletviewer::jagex::runcheck($rsu_data);

	
# Print debug info
print "Trying to read ".$rsu_data->clientdir."/share/settings.conf\n";

########################################################################
#        BELOW THIS LINE ARE SOME SETTINGS YOU CAN CHANGE              #
#       PLEASE CHANGE THEM IN THE share/settings.conf FILE             #
########################################################################

# Read from the config file if the user want to run in compabilitymode/wine,
# if nothing is found then dont use it
$rsu_data->compabilitymode = parseargs("compabilitymode", "0");

# Read the preferred java in the config file, if nothing is found then use default-java
$rsu_data->preferredjava = parseargs("preferredjava", "default-java");

# Read from the config file or passed parameters if the user want to force the client to use pulseaudio
# if nothing then dont use it (incase a system does not have pulseaudio/padsp installed)
$rsu_data->forcepulseaudio = parseargs("forcepulseaudio", "0");

# Read from the config file or passed parameters if the user want to tell java to use alsa in the base for sounds
# If nothing is found then do not use alsa and instead use the java default
$rsu_data->forcealsa = parseargs("forcealsa", "0");

# Check if a prmfile setting is active
$rsu_data->prmfile = parseargs("prmfile", "runescape.prm");

# Check if useprimusrun is enabled
$rsu_data->useprimusrun = parseargs("useprimusrun", "false");

# Define fallbackprms incase we cannot read share/runescape.prm
$rsu_data->fallbackprms = "jagexappletviewer.jar -Dsun.java2d.noddraw=true -Dcom.jagex.config=http://www.runescape.com/k=3/l=\$(Language:0)/jav_config.ws -Xss2m -Xmx512m jagexappletviewer ";

# garbage collection prms (useful for "ancient" systems)
# -XX:CompileThreshold=1500 -Xincgc -XX:+UseConcMarkSweepGC -XX:+UseParNewGC

########################################################################
#DO NOT EDIT THE CODE BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!
########################################################################

# Make debug info look abit nicer
print "\n";

# Check if any --verbose parameters were passed to the script
$rsu_data->verboseprms = client::modes::verbose::verbosecheck($rsu_data);

# Make debug info look abit nicer
print "\n";

# Be strict to avoid messy code
use strict;

# If we are on a platform which can use addons
#if ($rsu_data->OS =~ /(MSWin32|linux|darwin)/)
#{
	## Check what folders exists in $clientdir/modules
	#my $clientdir = $rsu_data->clientdir;
	
	## Open the modules directory
	#opendir(my $checkforaddons, "$clientdir/modules");
	
	## While there is still content in the folder
	#while (readdir $checkforaddons)
	#{
		## If current content is the addons folder
		#if ($_ =~ /^addons$/ && -d "$clientdir/modules/$_")
		#{
			## Load addons
			#rsu_addonloader::loadaddons($rsu_data);
		#}
	#}
#}

# Start actual process of running the client

# Check if user wants to run in compability mode
client::mains::checkcompabilitymode($rsu_data);

# If compabilitymode is disabled then it will run the main function
# If we are on windows
if ($rsu_data->OS =~ /MSWin32/)
{
	# Run the main function for windows
	client::mains::windows_main($rsu_data);
}
# Else we are on unix
else
{
	# Run the main function for unix
	client::mains::unix_main($rsu_data);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub parseargs
{
	# Get the variables passed to the function
	my ($arg2find, $default) = @_;
	
	# If a prmfile is passed to the script from the terminal then
	if ("@ARGV" =~ /(-|--)$arg2find=/)
	{
		# For each parameter found in @ARGV
		foreach my $arg (@ARGV)
		{
			# If the parameter matches the one we are looking for
			if ($arg =~ /(-|--)$arg2find=/)
			{
				# Split the parameter by =
				my @prmname = split /=/, $arg;
				
				# Return the setting found in the parameter
				return "$prmname[1]";
			}
			
		}	
	}
	else
	{
		# If no parameter that matches is passed then read from settings.conf
		my $result = rsu::files::IO::readconf("$arg2find", "$default", "settings.conf", $rsu_data->clientdir);
		
		# Return setting
		return $result;
	}
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub checkforcleanup
{
	if ($rsu_data->OS =~ /MSWin32/)
	{
		# Replace / with \\
		$cwd =~ s/\//\\/g;
		
		# Path variable to set in windows
		#my $win32path = "set PATH=$cwd\\win32\\perl\\bin;$cwd\\win32\\gnu\\;$cwd\\win32\\7-zip\\;%PATH%";
		
		# Get directory listing
		my $checkforscript = `dir \"$cwd\"`;
		
		# If cleanupscript.pl is present
		if ($checkforscript =~ /cleanupscript.pl/)
		{
			# Run the Download-Windows-Files.exe to make sure the win32 folder is updated
			#system "$cwd\\Download-Windows-Files.exe";
			
			# Run the cleanupscript then delete it then show a notice to the user
			#system "$win32path && perl \"".$rsu_data->cwd."\\cleanupscript.pl\" && del \"".$rsu_data->cwd."\\cleanupscript.pl\" && perl -e \"use Wx qw[:everything]; Wx::MessageBox('The scripts were recently updated. Please press OK and run Download-Windows-Files.exe to make sure the modules are up to date.', 'Recently Updated!', wxOK,undef);";
			require "$cwd/cleanupscript.pl";
			
			exit;
		}
	}
	else
	{
		# Get directory listing
		my $checkforscript = `ls \"$cwd\"`;
		
		# If cleanupscript.pl is present
		if ($checkforscript =~ /cleanupscript.pl/)
		{
			# Run the cleanupscript then delete it
			system "perl \"".$rsu_data->cwd."/cleanupscript.pl\" && rm \"".$rsu_data->cwd."/cleanupscript.pl\"";
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

# Create mutator function from "Programming Perl"
sub create_mutator
{

	my $self = shift;

	# From "Programming Perl" 3rd Ed. p338.
	for my $attribute (@_)
	{

		no strict "refs"; # So symbolic ref to typeglob works.
		no warnings;      # Suppress "subroutine redefined" warning.

		*$attribute = sub : lvalue
		{

			my $self = shift;

			$self->{$attribute} = shift if @_;
			$self->{$attribute};

		};

	}

}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
