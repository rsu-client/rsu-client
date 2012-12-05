#!/usr/bin/perl -w

# Be strict to avoid messy code
use strict;

# Use FindBin module to get script directory
use FindBin;

# Name of our xrc gui resource file
my $xrc_gui_file = "windowframe.xrc";

# Disable buffering
$|=1;

# Get script directory
my $cwd = $FindBin::RealBin;
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

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;
# Which events shall we include
use Wx::Event qw(EVT_BUTTON);

use base qw(Wx::Frame Wx::ScrolledWindow);

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
	
	set_events($self);
	
	set_tooltips($self);
}

sub load_xrc_gui
{
	# Get the pointers
	my $self = shift;
	
	# Get the xrc file
	my $xrc_file = "$cwd/$xrc_gui_file";
	
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

sub set_events
{
	# Get the pointers
	my $self = shift;
	
	# Setup the events
	# EVT_BUTTON($self, Wx::XmlResource::GetXRCID('objectname'), \&function);
	
	# Find the widgets from xrc file (for more complex stuff build the gui self by using Wx::WIDGETNAME->new)
	# $self->{objectname} = $self->FindWindow('objectname');
	$self->{windowpanel} = Wx::ScrolledWindow->new($self, -1, wxDefaultPosition, wxDefaultSize, );
	
	# Create gridsizers so the widgets can be resized with the window
	$self->{mainsizer} = Wx::GridSizer->new(1,1,0,0);
	$self->{addonlist} = Wx::GridSizer->new(1,1,7,7);
	
	# Make a vertical box sizer for use to organize stuff
	$self->{addonvertical} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Make a label and add it to the boxsizer
	$self->{labeltop} = Wx::StaticText->new($self->{windowpanel}, -1, "Click on the buttons to launch \naddons when you need them!", wxDefaultPosition, wxDefaultSize,);
	$self->{addonvertical}->Add($self->{labeltop}, 0,wxALIGN_TOP|wxALL|wxALIGN_CENTER|wxEXPAND,0);
	
	# Add the widgets to the sizers
	$self->{mainsizer}->Add($self->{windowpanel},1,wxEXPAND|wxALL,0);
	
	# Run a function to add all addons to the list
	add_addons($self);
	
	# Add the sizer to the layout
	$self->{addonvertical}->Add($self->{addonlist},0,wxEXPAND,0);
	$self->{windowpanel}->SetSizer( $self->{addonvertical} );
	$self->SetSizer( $self->{mainsizer} );
	
	$self->{mainsizer}->Fit($self);
	
	# Set default size
	$self->SetSize(250,300);
	$self->SetMinSize($self->GetSize);
	
	# Set the layout
	$self->Layout;
	# Refresh window
	$self->Refresh;
	
	# Move to top left corner
	$self->Move(1,1);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub setScrollBars
{
	# Get the widgets to make scrollable
	my @scrolledWindows = @_;
	
	# Set scroll properties
	my $pixelsPerUnitX = 5; 
    my $pixelsPerUnitY = 5; 
    my $noUnitsX = 100; 
    my $noUnitsY = 100; 
	
	# For each widget to make scrollable
	foreach my $window (@scrolledWindows)
	{
		# Enable scrolling
		$window->SetScrollbars($pixelsPerUnitX, $pixelsPerUnitY, $noUnitsX, $noUnitsY);
	} 
}

#
#---------------------------------------- *** ----------------------------------------
#

sub add_addons
{
	# Get pointers
	my $self = shift;
	
	# Get list of addon directories
	my $addonsfolders = `ls "$cwd/../" | grep -v "framework" | grep -v "Addon_Launcher"`;
	
	# Split up the list into an array
	my @addons = split (/\n/, $addonsfolders);
	my $addon;
	
	# Make a counter so we can add the correct amount of rows for the gridsizer
	# (to prevent crashes on some platforms)
	my $counter = 1;
	
	# For each value in the array
	foreach $addon (@addons)
	{
		# Make sure we have enough rows in the grid
		$self->{addonlist}->SetRows($self->{addonlist}->GetRows()+1);
		
		# Make a button for the addon
		$self->{$addon} = Wx::Button->new($self->{windowpanel}, -1, "$addon", wxDefaultPosition, wxDefaultSize, );
		
		# Make an event trigger for the newly created button
		EVT_BUTTON($self, -1, \&launch_addon);
		
		# Add the button to the vertical addon list sizer
		$self->{addonlist}->Add($self->{$addon}, 1, wxEXPAND,0);
		
		# Increase counter by 1
		$counter += 1;
	}
	
	# Enable scrollbars on scrolledwindows
	setScrollBars($self->{windowpanel});
}

#
#---------------------------------------- *** ----------------------------------------
#

sub launch_addon
{
	my ($self, $event) = @_;
	
	# Get the name of the addon that triggered the event
	my $addon = $event->GetEventObject()->GetLabel();
	
	# Launch addon
	system "perl -w \"$cwd/../$addon/moduleloader.pl\" &";
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

