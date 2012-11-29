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
use Wx::Event qw(EVT_BUTTON EVT_WEB_VIEW_LOADED EVT_TEXT_ENTER EVT_WEB_VIEW_NAVIGATING);

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
	
	# Find the widgets
	# $self->objectname = $self->FindWindow('objectname');
	
	# Make a panel we can put contents on
	$self->{mainpanel} = Wx::Panel->new($self, -1, wxDefaultPosition, wxDefaultSize, );
	
	# Create a lineedit to act as a search bar
	$self->{searchbar} = Wx::TextCtrl->new($self->{mainpanel}, -1,"", wxDefaultPosition, wxDefaultSize, wxTE_PROCESS_ENTER);
	EVT_TEXT_ENTER($self, -1, \&search_wiki);
	
	# Make back and forward buttons and connect them to event triggers
	$self->{goback} = Wx::Button->new($self->{mainpanel}, -1,"<-", wxDefaultPosition, wxDefaultSize);
	EVT_BUTTON($self, -1, \&goback);
	
	$self->{lookupbutton} = Wx::Button->new($self->{mainpanel}, -1,"Search", wxDefaultPosition, wxDefaultSize);
	EVT_BUTTON($self, -1, \&search_wiki);
	
	# Make a webview which we will use for displaying the wikia articles
	$self->{webview} = Wx::WebView::New($self->{mainpanel}, -1, "http://runescape.wikia.com");
	
	# Make an event trigger for the webviewer
	EVT_WEB_VIEW_LOADED($self, -1, \&process_wiki);
	#EVT_WEB_VIEW_NAVIGATING($self, -1, \&process_wiki);
	
	# Make a horizontal sizer
	$self->{controlsholder} = Wx::BoxSizer->new(wxHORIZONTAL);
	
	# Make a gridsizer with 2 rows and a mainsizer with 1 row and 1 coloum
	$self->{gridsizer} = Wx::BoxSizer->new(wxVERTICAL);#(2,0,0,0);
	$self->{mainsizer} = Wx::GridSizer->new(1,0,0,0);
	
	$self->SetSize(710,480);
	$self->SetMinSize($self->GetSize);
	
	# Place the widgets in the layout
	make_layout($self);
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_layout
{
	# Get pointers
	my $self = shift;
	
	# Add the buttons and searchbar to the controlsholder
	$self->{controlsholder}->Add($self->{goback},0,,0);
	$self->{controlsholder}->Add($self->{searchbar},1,wxEXPAND,0);
	$self->{controlsholder}->Add($self->{lookupbutton},0,,0);
	
	# Add the sizers to the GUI
	$self->{gridsizer}->Add($self->{controlsholder}, 0 , wxEXPAND, 0);
	$self->{gridsizer}->Add($self->{webview}, 1 , wxEXPAND|wxALL, 0);
	$self->{mainpanel}->SetSizer($self->{gridsizer});
	$self->{mainsizer}->Add($self->{mainpanel}, 1, wxEXPAND,0);
	$self->SetSizer( $self->{mainsizer} );
	
	
	
	$self->{mainsizer}->Fit($self);
	
	# Set the layout
	$self->Layout;
	# Refresh window
	$self->Refresh;
}

#
#---------------------------------------- *** ----------------------------------------
#


sub search_wiki
{
	# Get the pointers
	my ($self, $event) = @_;
	
	# Get the text we are searching for
	my $searchfor = $self->{searchbar}->GetValue();
	
	# Replace whitespaces with +
	$searchfor =~ s/\s+/\+/g;
	
	# Load the search page for wikia
	$self->{webview}->LoadURL("http://runescape.wikia.com/wiki/index.php?search=$searchfor&fulltext=Search");
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub goback
{
	# Get the pointers
	my ($self, $event) = @_;
	
	# Go back
	$self->{webview}->GoBack();
}

#
#---------------------------------------- *** ----------------------------------------
#

sub process_wiki
{
	# Get the pointers
	my ($self,$event) = @_;
	
	# Run a javascript to process the page to show only the article 
	#(the full page will however be shown until everything is loaded)
	# The javascript used is written by Whos-Dr
	$self->{webview}->RunScript('
var Pres = document.getElementById("WikiaArticle").cloneNode(true);
document.body.innerHTML = "";
document.body.appendChild(Pres);
document.body.style.background = "#cda172";
');

	if ($self->{webview}->GetPageSource() =~ /<div id="toctitle">/)
	{
		$self->{webview}->RunScript('
var toc = document.getElementById("toctitle");
toc.onclick = function() {
 var e = this.parentNode.getElementsByTagName("ul")[0];
 e.style.display = (e.style.display == "block" ? "none" : "block");
 var l = document.getElementById("togglelink");
 l.childNodes[0].nodeValue = (l.childNodes[0].nodeValue == "show" ? "hide" : "show");
}
	');
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

