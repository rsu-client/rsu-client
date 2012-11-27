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
use Wx::WebView;
# Which events shall we include
use Wx::Event qw(EVT_BUTTON);

use base qw(Wx::Frame);

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
	# $self->objectname = $self->FindWindow('objectname');
	$self->{musicplayer} = Wx::Panel->new($self, -1, wxDefaultPosition, wxDefaultSize, );
	
	
	# Create gridsizers so the widgets can be resized with the window
	$self->{mainsizer} = Wx::GridSizer->new(1,1,0,0);
	$self->{musicsizer} = Wx::GridSizer->new(1,1,0,0);
	
	# Create a webview which loads our music player
	$self->{webview} = Wx::WebView::New($self->{musicplayer}, wxID_ANY,  "http://html5.grooveshark.com" );
	
	# Add the widgets to the sizers
	$self->{mainsizer}->Add($self->{musicplayer},1,wxEXPAND|wxALL,0);
	$self->{musicsizer}->Add($self->{webview},1,wxEXPAND|wxALL,0);
	
	# Add the sizer to the layout
	$self->{musicplayer}->SetSizer( $self->{musicsizer} );
	$self->SetSizer( $self->{mainsizer} );
	
	$self->{mainsizer}->Fit($self);
	
	# Set default size
	$self->SetSize(450,550);
	$self->SetMinSize($self->GetSize);
	
	# Set the layout
	$self->Layout;
	# Refresh window
	$self->Refresh;
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

