package client::launch::updater;
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
#################################
#   Contributors in this file   #
#################################
# HikariKnight - Main developer #
# Fallen Unia - Zenity support  #
#################################

my $windowsurl = "http://www.runescape.com/downloads/runescape.msi";
my $macurl = "http://www.runescape.com/downloads/runescape.dmg";
my $updateurl = "https://github.com/HikariKnight/rsu-client/archive/rsu-api-latest.tar.gz";

# Be strict to avoid messy code
use strict;

# Use FindBin module to get script directory
use FindBin;

# Use the Cwd module so we can find the current working directory
use Cwd;

# Name of our xrc gui resource file
my $xrc_gui_file = "rsu-updater.xrc";

# Disable buffering
$|=1;

# Get the cwd
my $cwd = getcwd;

# Get script directory
my $scriptdir = $FindBin::RealBin;
# Get script filename
my $scriptname = $FindBin::Script;
# Detect the current OS
my $OS = "$^O";

# Make a variable for users homedir
my $HOME;
# If we are on windows
if ($OS =~ /MSWin32/)
{
	# Get the environment variable for USERPROFILE
	$HOME = $ENV{"USERPROFILE"};
	# Replace all / with \
	$HOME =~ s/\//\\/g;
}
# Else we are on UNIX
else
{
	$HOME = $ENV{"HOME"};
}

# Require the clientdir module
require rsu::files::clientdir;

# Get the client directory
my $clientdir = rsu::files::clientdir::getclientdir();

# Get the resource directory for this script
my $resourcedir = "$cwd/rsu/framework/resources/client/launch/updater";

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;
# Which events shall we include
use Wx::Event qw(EVT_BUTTON);

use base qw(Wx::Frame);

# Use File::Path so we can make and remove directories
use File::Path qw(make_path remove_tree);

# Require the files IO module
require rsu::files::IO;

# Require the files grep module
require rsu::files::grep;

# Require the files copy module
require rsu::files::copy;

# Require the extract query_bin module
require updater::extract::query_bin;

# Require the archive module
require rsu::extract::archive;

sub new
{
	# Create a class
	my $class = shift;
	
	# Assign class object to $self
	my $self = $class->SUPER::new;
	
	# Initialize everything
	$self->initialize;
	
	return $self;
}

sub initialize
{
	# Get pointers
	my $self = shift;
	
	# Create mutators for widgets (enter the objectname for every object here)
	$self->create_mutator
	(
		qw
		(
			xrc_resource
		)
	);
	
	load_xrc_gui($self);
	
	set_layout($self);
	
	set_events($self);
	
	set_tooltips($self);
	
}

sub load_xrc_gui
{
	# Get the pointers
	my $self = shift;
	
	# Get the xrc file
	my $xrc_file = "$resourcedir/$xrc_gui_file";
	
	# Initialize WX
	Wx::InitAllImageHandlers();
	
	# Create xrc/xml resource
	$self->xrc_resource = Wx::XmlResource->new;
	# Initialize handlers
	$self->xrc_resource->InitAllHandlers;
	# Load the xrc file
	$self->xrc_resource->Load($xrc_file);
	
	# Tell what window/frame to load
	$self->xrc_resource->LoadFrame($self,undef,"mainwindow");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_layout
{
	# Get the pointers
	my $self = shift;
	
	# Find the widgets
	# $self->objectname = $self->FindWindow('objectname
	
	# Get the scrolledlist which will contain the buttons and description
	$self->{scrolledlist} = $self->FindWindow('scrolledlist');
	
	# Get the addonlist which will contain the buttons and description
	$self->{addonlist} = $self->FindWindow('addonlist');
	
	# Make a flexible gridsizer to make everything look good
	$self->{listgrid} = Wx::FlexGridSizer->new(3,2,0,0);
	
	# Make the 2nd column growable
	$self->{listgrid}->AddGrowableCol(1);
	
	# Make the buttons list
	create_button_list($self);
	
	# Make a flexible gridsizer to make everything look good
	$self->{addongrid} = Wx::FlexGridSizer->new(3,2,0,0);
	
	# Make the 2nd column growable
	$self->{addongrid}->AddGrowableCol(1);
	
	# Make the addonlist
	create_addon_page($self);
	
	# Set the sizer for scrolledlist
	$self->{scrolledlist}->SetSizer($self->{listgrid});
	
	# Set the sizer for addonlist
	$self->{addonlist}->SetSizer($self->{addongrid});
	
	# Set minimum size and maximum size of the window
	$self->SetMinSize($self->GetSize);
	#$self->SetMaxSize($self->GetSize);
	
	# If the icon exists
	if (-e "$cwd/share/img/runescape.png")
	{
		# Set the window icon
		$self->SetIcon(Wx::Icon->new("$cwd/share/img/runescape.png", wxBITMAP_TYPE_PNG));
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub create_button_list
{
	# Get the pointers
	my $self = shift;
	
	# If we are on Windows
	if ($OS =~ /MSWin32/)
	{
		# Generate an update entry for windows
		generate_update_entry($self, "msi", "Update jagexappletviewer;$windowsurl;Download and extract the jagexappletviewer.jar from the Official Windows Client (from Jagex)");
	}
	# Else if we are on mac
	elsif($OS =~ /darwin/)
	{
		# Generate an update entry for mac
		generate_update_entry($self, "dmg", "Update jagexappletviewer;$macurl;Download and extract the jagexappletviewer.jar from the Official Mac Client (from Jagex)");
	}
	# Else (we are on linux or some other unix)
	else
	{
		# Generate an update entry for windows
		generate_update_entry($self, "msi", "Update jagexappletviewer;$windowsurl;Download and extract the jagexappletviewer.jar from\nthe Official Windows Client (from Jagex)");
		
		# Generate an update entry for mac
		generate_update_entry($self, "dmg", "Update jagexappletviewer;$macurl;Download and extract the jagexappletviewer.jar from\nthe Official Mac Client (from Jagex)");
	}
	
	# If clientdir is not $HOME/.config/runescape
	if ($clientdir !~ /$HOME\/\.config\/runescape/)
	{
		# Generate an update entry for windows
		generate_update_entry($self, "api", "Update rsu-api;$updateurl;Update the rsu-api to the newest version\n(from HikariKnight)");
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub generate_update_entry
{
	# Get the passed data
	my ($self, $type, $default) = @_;
	
	# Get the information needed for the updater gui
	my $buttonconfig = rsu::files::IO::readconf($type."_button", $default, "buttons.conf", "$resourcedir/configs");
	
	# Split the buttonconfig into an array
	my @buttondata = split /;/, $buttonconfig;
	
	# Make a update button for the msi client
	make_button($self, $type."_button", "$buttondata[0]");
	
	# Replace \n with newlines
	$buttondata[2] =~ s/\\n/\n/g;
	
	# Make a description
	$self->{$type."_label"} = Wx::StaticText->new($self->{scrolledlist}, -1, "$buttondata[2]", wxDefaultPosition, wxDefaultSize);
	
	# Add description to list
	$self->{listgrid}->Add($self->{$type."_label"},2,wxEXPAND|wxALL,5);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_button
{
	# Get the passed data
	my ($self, $button, $label) = @_;
	
	# Make a button for the launcher
	$self->{$button} = Wx::Button->new($self->{scrolledlist}, -1, "$label");
	$self->{$button}->SetName("$button");
	$self->{listgrid}->Add($self->{$button},1,wxEXPAND|wxALL,5);
	
	# Make an event trigger for the newly created button
	EVT_BUTTON($self->{$button}, -1, \&update_clicked);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_addon_button
{
	# Get the passed data
	my ($self, $button, $label) = @_;
	
	# Make a button for the launcher
	$self->{$button} = Wx::Button->new($self->{addonlist}, -1, "$label");
	$self->{$button}->SetName("$button");
	$self->{addongrid}->Add($self->{$button},1,wxEXPAND|wxALL,5);
	
	# Make an event trigger for the newly created button
	EVT_BUTTON($self->{$button}, -1, \&update_addon_clicked);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub create_addon_page
{
	# Get the pointers
	my $self = shift;
	
	# Generate list of RSU verified addons
	generate_addon_list($self, "$cwd/rsu/framework/resources/client/launch/updater/configs", "repos.conf");
	
	# Generate list of player added addons
	generate_addon_list($self, "$clientdir/share/configs", "addons_updater.conf");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub generate_addon_list
{
	# Get the passed data
	my ($self, $location, $file) = @_;
	
	# Get the content of the addons
	my $addons_conf = rsu::files::IO::getcontent("$location", "$file");
	
	# Get all addons that are universal or specific to our platform
	my @addons = rsu::files::grep::strgrep($addons_conf, "^(".$OS."_|universal_|repo_)");
	
	# For each of the addons we found
	foreach (@addons)
	{
		# Split the config so we can get the id
		my @addon_id = split /=|;/, $_;
		
		# Get the config data for the addon
		my $config = rsu::files::IO::readconf($addon_id[0],"0","$addons_conf", "string://");
		
		# Next if config is 0
		next if $config eq '0';
		
		# Split the config into sections
		my @addon_data = split /;/, $config;
		
		# If this is a repository then
		if ($addon_id[0] =~ /^repo_/i)
		{
			# Run the generation again but against the remote file
			generate_addon_list($self,$addon_data[0],$addon_data[1]);
			
			# Jump to next entry
			next;
		}
		
		# Make an addon button
		make_addon_button($self, $addon_id[0], $addon_data[0]);
		
		# Replace \\n with \n in the description
		$addon_data[2] =~ s/\\n/\n/g;
		
		# Make a description
		$self->{$addon_id[0]."_label"} = Wx::StaticText->new($self->{addonlist}, -1, "$addon_data[2]", wxDefaultPosition, wxDefaultSize);
		
		# Add description to list
		$self->{addongrid}->Add($self->{$addon_id[0]."_label"},2,wxEXPAND|wxALL,5);
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub update_clicked
{
	# Get the pointers
	my ($self, $event) = @_;
	
	# Get the name of the addon that triggered the event
	my $caller = $event->GetEventObject()->GetName();
	
	# Remove _button from the caller name
	$caller =~ s/_button//i;
	
	# Make the download directory
	make_path("$clientdir/.download");
	
	# If the caller was the dmg or msi button
	if ($caller =~ /^(msi|dmg)$/)
	{
		# Get the location to store the jar file
		my $jardir = rsu::files::IO::readconf("jardir", "bin", "updater.conf", "$resourcedir/configs");
		
		# If we are on windows
		if ($OS =~ /MSWin32/)
		{
			# Launch the client downloader in a new process for extra resources for this task
			system ("$cwd/rsu/rsu-query.exe rsu.download.client $jardir $caller");
		}
		# Else we are on a unix platform
		else
		{
			# Launch the client downloader in a new process for extra resources for this task
			system ("$cwd/rsu/rsu-query rsu.download.client $jardir $caller");
		}
		
		# Show a message that we are done
		Wx::MessageBox("jagexappletviewer.jar should now be the newest version.", "Done updating jagexappletviewer", wxOK, $self);
	}
	# Else if the caller was the api button
	elsif($caller =~ /^api$/)
	{
		# Check if binary is installed and update it
		updater::extract::query_bin::update(0);
		
		# Get the download link
		my $callerconfig = rsu::files::IO::readconf("api_button", "Update rsu-api;$updateurl;Update the rsu-api to the newest version\n(from HikariKnight)", "buttons.conf", "$resourcedir/configs");
		
		# Split the config
		my @callerdata = split /;/, $callerconfig;
		
		# Download the api in a new process
		system("$cwd/rsu/rsu-query rsu.download.file $callerdata[1] \"$clientdir/.download\"");
		
		# Intended function, however can only be used once per script, kept incase i manage to fix the problem
		#updater::download::file::from("$callerdata[1]", "$clientdir/.download/rsu-api-latest.tar.gz");
		
		# Extract the api
		rsu::extract::archive::extract("$clientdir/.download/rsu-api-latest.tar.gz", "$clientdir/.download/extracted_files/");
		
		# Replace the old API files with the new ones (rewrites directories)
		rsu::files::copy::print_mvr("$clientdir/.download/extracted_files/rsu-client-rsu-api-latest/runescape/rsu/framework/API", "$clientdir/rsu/framework/API", 1);
		rsu::files::copy::print_mvr("$clientdir/.download/extracted_files/rsu-client-rsu-api-latest/runescape/rsu/framework/modules", "$clientdir/rsu/framework/modules", 1);
		rsu::files::copy::print_mvr("$clientdir/.download/extracted_files/rsu-client-rsu-api-latest/runescape/rsu/framework/resources", "$clientdir/rsu/framework/resources", 1);
		rsu::files::copy::print_mvr("$clientdir/.download/extracted_files/rsu-client-rsu-api-latest/runescape/templates", "$clientdir/templates", 1);
		
		# Append the remaining files to the $clientdir (replacing files, does not rewrite directories)
		rsu::files::copy::print_cpr("$clientdir/.download/extracted_files/rsu-client-rsu-api-latest/runescape", "$clientdir", 0);
		
		# Show a message that we are done
		Wx::MessageBox("The rsu-api have now been updated\nto the newest version.", "Done updating the rsu-api", wxOK, $self);
	}
	
	# Remove the update directory
	remove_tree("$clientdir/.download");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub update_addon_clicked
{
	my ($self, $event) = @_;
	
	# Get the name of the addon that triggered the event
	my $caller = $event->GetEventObject()->GetName();
	
	# Make a variable that contains the config for the addon
	my $config = rsu::files::IO::readconf($caller, "0", "addons_updater.conf");
	
	# If the config cannot be found
	if ($config eq '')
	{
		Wx::MessageBox("Found no addon config for $caller inside\n$clientdir/share/configs/addons.conf", "Error! No Config");
		
		# Return to call
		return;
	}
	
	# Split the config into sections by ;
	my @addon_info = split /;/, $config;
	
	# Make the download directory
	make_path("$clientdir/.download");
	
	## If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Download the archive file
		system ("$cwd/rsu/rsu-query.exe rsu.download.file $addon_info[1]");
	}
	# Else we are on a unix platform
	else
	{
		# Download the archive file
		system ("$cwd/rsu/rsu-query rsu.download.file $addon_info[1]");
	}
	
	# Find out the filename
	my @filename = split /\//, $addon_info[1];
	
	# Extract the archive
	rsu::extract::archive::extract("$clientdir/.download/$filename[-1]", "$clientdir/.download/extracted_files");
	
	# Locate the moduleloader.pm
	my @moduleloader = rsu::files::grep::rdirgrep("$clientdir/.download/extracted_files", "\/moduleloader\.pm\$");
	
	# Move the moduleloader location to a variable
	my $addonroot = $moduleloader[0];
	
	# Remove /moduleloader.pm from the path
	$addonroot =~ s/\/moduleloader\.pm$//;
	
	# Create a variable that will contain only the id of the addon
	my $addon_id = $caller;
	
	# Remove the identifier from the $addon_id
	$addon_id =~ s/^(universal|$OS)_//;
	
	# If this is an universal addon
	if ($caller =~ /^universal_/)
	{
		# Move the addon to its proper place and use the caller name as folder ID and rewrite the destination folder
		rsu::files::copy::print_mvr($addonroot, "$clientdir/share/addons/universal/$addon_id", 1)
	}
	# Else
	else
	{
		# Move the addon to its proper place and use the caller name as folder ID and rewrite the destination folder
		rsu::files::copy::print_mvr($addonroot, "$clientdir/share/addons/$OS/$addon_id", 1)
	}
	
	# Remove the .download folder
	remove_tree("$clientdir/.download");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_events
{
	# Get the pointers
	my $self = shift;
	
	# Setup the events
	# EVT_BUTTON($self, Wx::XmlResource::GetXRCID('objectname'), \&function);
	
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


### Events

sub close_clicked
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Close window
	$self->Destroy();
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_tooltips
{
	my ($self) = @_;
		
	# Set tooltips with info about the settings
	# $self->objectname->SetToolTip("message");
	
}

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package application;
use base qw(Wx::App);

sub OnInit
{
	# Get pointers
	my $self = shift;
	
	# Create mainwindow(new window)
	my $mainwindow = wxTopLevelFrame->new(undef, -1);
	
	# Set mainwindo/topwindow
	$self->SetTopWindow($mainwindow);
	
	# Show the window
	$mainwindow->Show(1);
}

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------


package main;

my $app = application->new;
$app->MainLoop;

1;
