package client::launch::launcher;
#!/usr/bin/perl -w

# Tell the script to do this before anything else
BEGIN
{
	# Be strict to avoid messy code
	use strict;

	# Use FindBin module to get script directory
	use FindBin;

	# Include OS Specific modules
	if ($^O  eq "MSWin32")
	{
		# Use Win32::FileOp so we can access to ShellExecute
		require Win32::FileOp;
		
		# Import to namespace
		Win32::Job->import();
	}
}

# Name of our xrc gui resource file
my $xrc_gui_file = "rsu-launcher.xrc";

# Disable buffering
$|=1;

# Use the module for getting the current working directory
use Cwd;

# Get the cwd
my $cwd = getcwd;

# Get the resource directory for this script
my $resourcedir = "$cwd/rsu/framework/resources/client/launch/launcher";

# Get script directory
my $scriptdir = $FindBin::RealBin;

# Get script filename
my $scriptname = $FindBin::Script;
# Detect the current OS
my $OS = "$^O";

# Use the API for getting the client dir
use rsu::files::clientdir;

# Get the location of the clientdir
my $clientdir = rsu::files::clientdir::getclientdir();

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;
# Which events shall we include
use Wx::Event qw(EVT_BUTTON EVT_PAINT);

# Use Wx::WebView if it exists
eval "use Wx::WebView";
# Use XML::RSSLite if it exists
eval "use XML::RSSLite";

# Use LWP::Simple module to get website content (crossplatform)
use LWP::Simple;

use base qw(Wx::Frame Wx::ScrolledWindow);

# Require the files grep module
require rsu::files::grep;

# Require the files IO module
require rsu::files::IO;

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
	# $self->objectname = $self->FindWindow('objectname');
	
	# Make a vertical box sizer for use to organize stuff
	$self->{mainsizer} = Wx::GridSizer->new(1,1,0,0);
	
	# Make a tabbed window(wxNoteBook) for the launcher
	$self->{tabcontrol} = Wx::Notebook->new($self,-1,wxDefaultPosition, wxDefaultSize);
	
	# Make the mainpanel and add it to the boxsizer
	$self->{mainpanel} = Wx::ScrolledWindow->new($self->{tabcontrol}, -1, wxDefaultPosition, wxDefaultSize );

	# Add the mainpanel to the tabbed window
	$self->{tabcontrol}->AddPage($self->{mainpanel}, "RSU-Launcher");
	
	# If --webview is passed
	if ("@ARGV" =~ /--webview/)
	{
		# Create a webview which loads the runescape news page
		$self->{webview} = Wx::WebView::New($self->{mainpanel}, wxID_ANY,  "http://services.runescape.com/m=news/" );
	}
	# Else
	else
	{
		# Make a scrolledwindow (uses less resources than webview)
		$self->{rssview} = Wx::ScrolledWindow->new($self->{mainpanel}, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxFULL_REPAINT_ON_RESIZE);
		
		# Make a painting event
		#EVT_PAINT( $self->{rssview}, \&OnPaint );
		# Change the RSSView background to black
		$self->{rssview}->SetBackgroundColour(wxBLACK);
	}
	
	# Create the boxsizer needed for the layout
	$self->{layoutsizer} = Wx::BoxSizer->new(wxHORIZONTAL);
	
	# Make a vertical box sizer for use to organize buttons
	$self->{buttonsizer} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Create a scrolledwindow for the buttons
	$self->{verticalbuttons} = Wx::ScrolledWindow->new($self->{mainpanel}, -1, wxDefaultPosition, wxDefaultSize );
	
	# Make buttons
	make_button($self, "playnow", "&Play Now");
	make_button($self, "playoldschool", "Play &OldSchool");
	make_button($self, "update", "Run &Updater");
	make_button($self, "settings", "&Settings");
	make_button($self, "forums", "RS &Forums");
	$self->{buttonsizer}->Add(1,1,1);
	make_button($self, "linuxthread", "&Linux Thread");
	
	# If we are on MacOSX
	if ($OS =~ /darwin/)
	{
		# Use the fallback/old aboutdialog as mac have issues with the modern one
		make_button($self, "about_FALLBACK", "&About RSU");
	}
	# Else
	else
	{
		# Use the new and improved aboutdialog
		make_button($self, "about", "&About RSU");
	}
	
	# Add the webview or rssview to the sizers
	if ("@ARGV" =~ /--webview/)
	{
		# Add the webview to the layout sizer
		$self->{layoutsizer}->Add($self->{webview},4,wxEXPAND|wxALL,5);
	}
	# Else
	else
	{
		# Add the rssview to the layout sizer
		$self->{layoutsizer}->Add($self->{rssview},4,wxEXPAND|wxALL,5);
		
		# Fetch rssfeed
		fetch_rssnews($self, "http://services.runescape.com/m=news/latest_news.rss");
		
		# Add scrollbars to the rssview if needed
		setScrollBars($self->{rssview});
	}
	
	# Add the sizers and panels together to form the layout
	$self->{verticalbuttons}->SetSizer($self->{buttonsizer});
	$self->{layoutsizer}->Add($self->{verticalbuttons},1,wxEXPAND|wxALL,5);
	# Make everything inside the mainsizer fit the window
	$self->{layoutsizer}->Fit($self);
	$self->{mainsizer}->Add($self->{tabcontrol},1,wxEXPAND|wxALL,0);
	
	# Add scrollbars to the verticalbuttons if needed
	setScrollBars($self->{verticalbuttons});
	
	# Add scrollbars to the mainpanel if needed
	setScrollBars($self->{mainpanel});
	
	# If we are on linux, darwin/mac or windows (which supports addons)
	if ($OS =~ /(linux|darwin|MSWin32)/)
	{
		# Check if there is any addons folder inside the clients share folder
		my @addoncheck = rsu::files::grep::dirgrep("$clientdir/share", "^addons\$");
		
		# For each file/folder found
		foreach my $addondir (@addoncheck)
		{
			# If the current content is the addons folder
			if ($addondir =~ /^addons$/ && -d "$clientdir/share/$addondir")
			{
				# Add the addons/module page
				create_addons_page($self);
			}
		}
	}
	
	# Set the events
	set_events($self);
	
	# If the icon exists
	if (-e "$cwd/share/img/runescape.png")
	{
		# Set the window icon
		$self->SetIcon(Wx::Icon->new("$cwd/share/img/runescape.png", wxBITMAP_TYPE_PNG));
	}
	
	# Add the contents of the layoutsizer to the mainpanel
	$self->{mainpanel}->SetSizer($self->{layoutsizer});
	# Set the sizer for the window itself
	$self->SetSizer( $self->{mainsizer} );
	# Make everything inside the mainsizer fit the window
	$self->{mainsizer}->Fit($self);
	
	# Set default size
	$self->SetSize(880,500);
	$self->SetMinSize($self->GetSize);
	
	# Set the layout
	$self->Layout;
	# Refresh window
	$self->Refresh;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub create_addons_page
{
	# Get the passed data
	my ($self) = @_;
	
	# Make the new page for the tabbed window
	$self->{addonspage} = Wx::ScrolledWindow->new($self->{tabcontrol}, -1, wxDefaultPosition, wxDefaultSize, );
	
	# Add the page to the tabbed window
	$self->{tabcontrol}->AddPage($self->{addonspage}, "Installed Add-Ons");
	
	# Make sizers for the top of the page
	$self->{addonsvertical} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Make a gridsizer which will contain the addons
	$self->{addonlist} = Wx::GridSizer->new(1,4,5,5);
	
	# Make a button which tells the user how to add addons
	$self->{addons_labeltop} = Wx::StaticText->new($self->{addonspage}, -1, "\nClick on the button coresponding to the addon you want to manually launch!\nClick the button below to open the addons directory. Install only addons you trust!", wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE_HORIZONTAL);
	
	# Make a button to open the addons dir and make it run the function open_addonsdir when clicked
	$self->{addonsdirbutton} = Wx::Button->new($self->{addonspage}, -1, "Open Addons Folder (place manually extracted addons here)", wxDefaultPosition, wxDefaultSize, );
	EVT_BUTTON($self->{addonsdirbutton}, $self->{addonsdirbutton}, \&open_addonsdir);
	
	# Add the label and button to the vertical boxsizer
	$self->{addonsvertical}->Add($self->{addons_labeltop}, 0, wxALL|wxALIGN_CENTER,0);
	$self->{addonsvertical}->Add($self->{addonsdirbutton}, 0, wxALL|wxALIGN_CENTER,0);
	$self->{addonsvertical}->Add(10,10,0,0);
	
	# Make a groupbox for tidyness
	$self->{addonsbox} = Wx::StaticBox->new($self->{addonspage},-1, "Addons you have installed:");
	$self->{addonscontainer} = Wx::StaticBoxSizer->new($self->{addonsbox},wxVERTICAL); 
	
	# Add the addonslist to the container
	$self->{addonscontainer}->Add($self->{addonlist},0,wxEXPAND|wxALL,0);
	
	# Add the gridsizer to the vertical boxsizer
	$self->{addonsvertical}->Add($self->{addonscontainer},1,wxEXPAND|wxALL,0);
	
	# Open the addons directory
	opendir(my $addondirs, "$clientdir/share/addons/");
	
	# While there is still content in the folder
	while (readdir $addondirs)
	{
		# If the current content is either named universal or the same as $OS
		if (($_ =~ /^universal$/ && -d "$clientdir/share/addons/$_") || ($_ =~ /^$OS$/ && -d "$clientdir/share/addons/$_"))
		{
			# Make the addons buttons
			make_addon_buttons($self, "$clientdir/share/addons/$_");
		}
	}
	
	# Close the directory to free memory
	closedir($addondirs);
	
	# Make sure the layout is displayed properly
	$self->{addonspage}->SetSizer($self->{addonsvertical});
	$self->{addonsvertical}->Fit($self->{addonspage});
	$self->{addonspage}->Layout();
	
	# Add scrollbars if neccessary
	setScrollBars($self->{addonspage});
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetch_rssnews
{
	# Get the passed data
	my ($self, $rssurl) = @_;
	
	# Make a vertical box sizer for use to organize the rss
	$self->{rss_sizer} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Fetch the recent activity rss feed
	my $rssfeed = get($rssurl);
	
	# Make a hash reference for the RSSLite parser
	my %rssnews;
	
	# Parse the RSSfeed
	parseRSS(\%rssnews, \$rssfeed);
	
	# For each value in the array
	foreach my $item (@{$rssnews{'item'}})
	{
		##### Generate Title #####
		
		# Get the news title text so we can format it
		$rssTitle = "$item->{'title'}";
		
		# Fix some formating issues from html
		$rssTitle =~ s/(&#8217;|&APOS;)/'/gi;
		$rssTitle =~ s/(&#8211;)/-/gi;
		$rssTitle =~ s/(&#13;|&#10;|&#9;)//gi;
		
		# If we are on mac or windows
		if ($OS =~ /(darwin|MSWin32)/)
		{
			# fix the & on mac and windows
			$rssTitle =~ s/(&amp;)/&&/gi;
		}
		# Else
		else
		{
			# Fix the & on unix
			$rssTitle =~ s/(&amp;)/&&&&/gi;
		}
		
		# Make a title label for the news
		my $newsTitle = Wx::StaticText->new($self->{rssview}, -1, "\n$rssTitle");
		
		# Make font bigger
		$newsTitle->SetFont(Wx::Font->new(14, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_BOLD, 0, "Times New Roman"));
		
		# Change the title color to the same color that Jagex use on news articles
		$newsTitle->SetForegroundColour(Wx::Colour->new(243,177,63));
		
		# Add label to the sizer
		$self->{rss_sizer}->Add($newsTitle, 0, wxEXPAND|wxALL, 5);
		
		##### Generate Date #####
		
		# Get the published date so we can remove the unused time
		my $rssDate = "$item->{'pubDate'}";
		
		# Remove the timestamp because it is always 00:00:00 GMT
		$rssDate =~ s/\s+\d{2,2}:\d{2,2}:\d{2,2}\s+GMT//g;
		
		# Make a date label for the news
		my $newsDate = Wx::StaticText->new($self->{rssview}, -1, "Published: $rssDate");
		
		# Change the text color to the same color that Jagex use on news articles
		$newsDate->SetForegroundColour(Wx::Colour->new(184,184,184));
		
		# Make font bigger
		$newsDate->SetFont(Wx::Font->new(10, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL, 0));
		
		# Add label to the sizer
		$self->{rss_sizer}->Add($newsDate, 0, wxEXPAND|wxLEFT, 25);
		
		##### Generate Description #####
		
		# Make a variable to contain the description because it needs fixing too
		my $rssDescription = $item->{'description'};
		
		# Remove all tabs
		$rssDescription =~ s/^\s+//g;
		
		# Replace all multiple whitespaces with normal whitespace
		$rssDescription =~ s/\s+/ /g;
		
		# Fix some stuff in the finished activity list
		$rssDescription =~ s/(&#8217;|&APOS;)/'/gi;
		$rssDescription =~ s/(&#8211;)/-/gi;
		$rssDescription =~ s/(&#13;|&#10;|&#9;)//gi;
		
		# If we are on mac or windows
		if ($OS =~ /(darwin|MSWin32)/)
		{
			# fix the & on mac and windows
			$rssDescription =~ s/(&amp;)/&&/gi;
		}
		# Else
		else
		{
			# Fix the & on unix
			$rssDescription =~ s/(&amp;)/&&&&&&&&/gi if "@INC" !~ /(par-|\s{1,1}CODE\()/;
			$rssDescription =~ s/(&amp;)/&&/gi if "@INC" =~ /(par-|\s{1,1}CODE\()/;
		}
		
		# Make a date label for the news
		my $newsDescription = Wx::StaticText->new($self->{rssview}, -1, "$rssDescription");
		
		# Change the text color to the same color that Jagex use on news articles
		$newsDescription->SetForegroundColour(Wx::Colour->new(184,184,184));
		
		$newsDescription->Wrap(480);
		
		# Add label to the sizer
		$self->{rss_sizer}->Add($newsDescription, 0, wxEXPAND|wxALL, 5);
		
		##### Generate Link #####
		
		# Make a hyperlink
		my $rssLink = Wx::Button->new($self->{rssview}, wxID_ANY, "Read More..");
		
		# Add a tooltip showing the url to the article
		$rssLink->SetToolTip("$item->{'link'}");
		
		# Connect the hyperlink to an event named hyperlink_clicked
		EVT_BUTTON($rssLink, -1, \&hyperlink_clicked);
		
		# Add a link to the article to the sizer
		$self->{rss_sizer}->Add($rssLink, 0, wxALL, 0);
		
		##### Generate Static Line #####
		
		# Add a static line to the sizer to nicely split the newsposts
		$self->{rss_sizer}->Add(Wx::StaticLine->new($self->{rssview}, -1), 0, wxEXPAND|wxALL, 5);
	}
	
	# Add the sizer to the rssview
	$self->{rssview}->SetSizer($self->{rss_sizer});
}

#
#---------------------------------------- *** ----------------------------------------
#

sub hyperlink_clicked
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Get the URL we are supposed to launch
	my $hyperlink = $event->GetEventObject()->GetToolTip()->GetTip();
	
	# Open the hyperlink url in the default web browser
	Wx::LaunchDefaultBrowser("$hyperlink");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_addon_buttons
{
	# Get the passed data
	my ($self, $addondir) = @_;
	
	# Make a counter so we know when to add a new row to the grid
	my $counter = 1;
	
	# Get all moduleloaders in the addon directory
	my @addons = rsu::files::grep::rdirgrep($addondir, "\/moduleloader\.pm");
	
	# For each addon we found
	foreach my $addon_path (@addons)
	{
		# Skip if we found a folder named moduleloader.pm (you never know)
		next if -d $addon_path;
		
		# Split the path by /
		my @folder_id = split /\//, $addon_path;
		
		# Remove moduleloader.pm from the path
		$addon_path =~ s/\/moduleloader\.pm$//;
		
		# If this is an universal addon
		if ($folder_id[-3] =~ /^universal$/)
		{
			# Try to get the addon name (if nothing is found then use the folder id as addon name)
			my $addon_platforms = rsu::files::IO::readconf("platforms", "linux;MSWin32;darwin;", "info.conf", $addon_path);
			
			# Split the list of platforms by ;
			my @platforms = split /;/, $addon_platforms;
			
			# Go to next addon if this universal addon is not supported on this platform
			next if "@platforms" !~ /$OS/i;
		}
		
		my $addon_id = "$folder_id[-3]_$folder_id[-2]";
		
		# Try to get the addon name (if nothing is found then use the folder id as addon name)
		my $addon_name = rsu::files::IO::readconf("name", "$addon_id", "info.conf", $addon_path);
		
		# Incase the id becomes the name we can remove universal_ or $OS_ from the start of the name
		$addon_name =~ s/^(universal|$OS)_//;
		
		# Check if there is a download url in the info.conf
		my $addon_url = rsu::files::IO::readconf("url", "", "info.conf", $addon_path);
		
		# If the addon url is not empty
		if ($addon_url ne '')
		{
			# Get the addon description
			my $addon_description = rsu::files::IO::readconf("description", "No description available for $addon_name", "info.conf", $addon_path);
			
			# Generate an updater entry
			generate_updater_entry($addon_id, $addon_name, $addon_url, $addon_description);
		}
		
		# If $counter is a modulo of 4 (translation: every 4th)
		if (($counter %= 4) == 0)
		{
			# Increase the amount of rows by 1
			$self->{addonlist}->SetRows($self->{addonlist}->GetRows()+1);
		}
			
		# Make a button for the addon
		$self->{$addon_id} = Wx::Button->new($self->{addonspage}, -1, "$addon_name", wxDefaultPosition, wxDefaultSize, );
			
		# Make an event trigger for the newly created button
		EVT_BUTTON($self, -1, \&launch_addon);
		
		# Set the buttons name to $addon_id
		$self->{$addon_id}->SetName($addon_id);
			
		# Add the button to the vertical addon list sizer
		$self->{addonlist}->Add($self->{$addon_id}, 0, wxEXPAND|wxALL,5);
		
		# Increase counter by 1
		$counter += 1;
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub generate_updater_entry
{
	# Get the passed data
	my ($id, $name, $url, $description) = @_;
	
	# Get the contents of the addons_updater.conf
	my $addons_updater_config = rsu::files::IO::getcontent("$clientdir/share/configs", "addons_updater.conf");		
	
	# Check if there is already an entry for this addon in the config
	my @entry_test = rsu::files::grep::strgrep($addons_updater_config, "^$id=");
	
	# If the test shows that an entry exists then
	if ($entry_test[0] ne '')
	{
		# Replace the existing entry with the new one
		$addons_updater_config =~ s/$entry_test[0]/$id=$name;$url;$description;/i;
		
		# Remove the newline at the end
		$addons_updater_config =~ s/\n$//;
		
		# Rewrite the addons_updater.conf file
		rsu::files::IO::WriteFile("$addons_updater_config", ">", "$clientdir/share/configs/addons_updater.conf");
	}
	# Else
	else
	{
		# Append the entry to the existing file
		rsu::files::IO::WriteFile("$id=$name;$url;$description;", ">>", "$clientdir/share/configs/addons_updater.conf");
	}
}

#
#---------------------------------------- *** ----------------------------------------
#



sub setScrollBars
{
	# Get the widgets to make scrollable
	my @scrolledWindows = @_;
	
	# Set scroll properties
	my $pixelsPerUnitX = 0; 
	my $pixelsPerUnitY = 15; 
	
	# If we are using the rssfeed
	if ("@ARGV" =~ /--rssfeed/)
	{
		# Scroll more pixels on the Y axis
		$pixelsPerUnitY = 30;
	}
	
    my $noUnitsX = 0; 
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

sub set_events
{
	my $self = shift;
	
	# Setup the events
	# EVT_BUTTON($self, Wx::XmlResource::GetXRCID('objectname'), \&function);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_button
{
	my ($self, $button, $label) = @_;
	
	# Make a button for the launcher
	$self->{$button} = Wx::Button->new($self->{verticalbuttons}, -1, "$label");
	$self->{buttonsizer}->Add($self->{$button},0,wxEXPAND|wxALL,5);
	
	# Make an event trigger for the newly created button
	EVT_BUTTON($self->{$button}, -1, \&$button);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about
{
	## This function recreates the about dialog used in linux so that
	## It will work the same on windows and mac too
	
	# Get the passed data
	my ($self, $event) = @_;
	
	# Make an object to contain the aboutframe
	my $about = {};
	
	# Make the aboutframe
	$about->{dialog} = Wx::Dialog->new(undef, -1, "About RuneScape Unix Client");
	
	# Get the rsu version
	my $version = get_rsuversion();
	
	# Prepare the interface sizers
	$about->{vertical} = Wx::BoxSizer->new(wxVERTICAL);
	$about->{horizontal} = Wx::BoxSizer->new(wxHORIZONTAL);
	
	# Else if we are not on windows and the icon exists
	if ($OS =~ /(MSWin32|linux)/ && -e "$cwd/share/img/runescape.png")
	{
		# Set the window icon
		$about->{dialog}->SetIcon(Wx::Icon->new("$cwd/share/img/runescape.png", wxBITMAP_TYPE_PNG));
		
		# Set the aboutdialog icon
		$about->{icon} = Wx::StaticBitmap->new($about->{dialog}, -1, Wx::Bitmap->new("$cwd/share/img/runescape.png", wxBITMAP_TYPE_PNG));
		
		# Set the size of the aboutdialog
		$about->{dialog}->SetSize(365,400);
		
		# Add the aboutdialog icon to the dialog
		$about->{vertical}->Add($about->{icon}, 0, wxALIGN_CENTER_HORIZONTAL|wxALL,0);
	}
	# Else
	else
	{
		# Set the size of the aboutdialog
		$about->{dialog}->SetSize(365,225);
	}
	
	# Set max and min size of the aboutdialog
	$about->{dialog}->SetMaxSize($about->{dialog}->GetSize);
	$about->{dialog}->SetMinSize($about->{dialog}->GetSize);
	
	
	# Create the Program name label
	$about->{version} = Wx::StaticText->new($about->{dialog}, -1, "\nRuneScape Unix Client $version", wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE_HORIZONTAL);
	
	# Make the label the correct size
	$about->{version}->SetFont(Wx::Font->new(15, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_BOLD, 0));
	
	# Make a description label
	$about->{description} = Wx::StaticText->new($about->{dialog}, -1, "\nThe Unofficial Universal Unix port of the RuneScape Downloadable Client for Windows", wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE_HORIZONTAL);
	$about->{description}->Wrap(300);
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Make the copyright line (windows cannot read \xc2)
		$about->{copyright} = Wx::StaticText->new($about->{dialog}, -1, "\n\xa9 2011-2013 HikariKnight\n", wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE_HORIZONTAL);
	}
	# Else
	else
	{
		# Make the copyright line
		$about->{copyright} = Wx::StaticText->new($about->{dialog}, -1, "\n\xc2\xa9 2011-2013 HikariKnight\n", wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE_HORIZONTAL);
	}
	
	# Set the correct font size
	$about->{copyright}->SetFont(Wx::Font->new(8, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL, 0));
	
	# Make a hyperlink to the sourcecode/projectpage
	$about->{website} = Wx::Button->new($about->{dialog}, -1, 'Get the &sourcecode from GitHub.com');
	$about->{website}->SetToolTip("https://github.com/HikariKnight/rsu-client");
	# Make an event for the get source button
	EVT_BUTTON($about->{website}, -1, \&hyperlink_clicked);
	
	# Make buttons for the bottom of the about dialog (with hotkeys support &key = alt+key)
	# And make the events for the buttons
	$about->{credits} = Wx::Button->new($about->{dialog}, -1, 'C&redits');
	EVT_BUTTON($about->{credits}, -1, \&about_credits);
	$about->{license} = Wx::Button->new($about->{dialog}, -1, '&License');
	EVT_BUTTON($about->{license}, -1, \&about_license);
	$about->{close} = Wx::Button->new($about->{dialog}, -1, '&Close');
	EVT_BUTTON($about->{close}, -1, \&about_close);
	
	# Add the buttons to the horizontal sizer
	$about->{horizontal}->Add($about->{credits}, 0, wxALL, 2);
	$about->{horizontal}->Add($about->{license}, 0, wxALL, 2);
	$about->{horizontal}->Add(70,10,10,wxALL|wxEXPAND,0);
	$about->{horizontal}->Add($about->{close}, 0, wxALL, 2);
	
	# Add everything to the vertical sizer
	$about->{vertical}->Add($about->{version}, 0, wxALIGN_CENTER_HORIZONTAL|wxALL,0);
	$about->{vertical}->Add($about->{description}, 0, wxALIGN_CENTER_HORIZONTAL|wxALL,0);
	$about->{vertical}->Add($about->{copyright}, 0, wxALIGN_CENTER_HORIZONTAL|wxALL,0);
	$about->{vertical}->Add($about->{website}, 0, wxALIGN_CENTER_HORIZONTAL|wxALL,0);
	
	# Set the sizers
	$about->{vertical}->Add($about->{horizontal}, 0, wxALIGN_CENTER_HORIZONTAL|wxALL,0);
	$about->{dialog}->SetSizer($about->{vertical});
	
	# Show the dialog
	$about->{dialog}->ShowModal();
	
	# Destroy the object when the user closes the window
	$about->{dialog}->Destroy;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about_credits
{
	# Get the passed data
	my ($about, $event) = @_;
	
	# Make an object for the license window
	my $credits = {};
	
	# Add credits to the object
	$credits->{writtenby} = "HikariKnight - <mu.antilag\@gmail.com>";
	$credits->{artworkby} = "none so far";
	$credits->{contributors} = "Ker Laeda - AUR Repository maintainer \nGarage Punk - forcepulseaudio code \nJmb71 - findjavalib regex \nEthoxyethaan - original launch script for Linux \nFallen_Unia - Zenity support in the Updater";
	
	# Make the dialog window
	$credits->{dialog} = Wx::Dialog->new(undef, -1, "Credits");
	
	# Make a tab window
	$credits->{tabwindow} = Wx::Notebook->new($credits->{dialog}, -1);
	
	# Make a gridsizer for the tabwindow
	$credits->{mainsizer} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Make tabs
	about_credits_maketab($credits, $credits->{writtenby}, "Written By");
	about_credits_maketab($credits, $credits->{contributors}, "Contributors");
	#about_credits_maketab($credits, $credits->{artworkby}, "Artwork By");
	
	# Make the close button and make it close the window when clicked
	$credits->{close} = Wx::Button->new($credits->{dialog}, -1, "Close");
	EVT_BUTTON($credits->{close}, -1, \&about_close);
	
	# Add stuff to the window
	$credits->{mainsizer}->Add($credits->{tabwindow},1,wxEXPAND|wxALL,5);
	$credits->{mainsizer}->Add($credits->{close},0,wxALIGN_RIGHT,0);
	$credits->{dialog}->SetSizer($credits->{mainsizer});
	
	# Set size of the window
	$credits->{dialog}->SetSize(350,300);
	
	# Show the window
	$credits->{dialog}->ShowModal;
	$credits->{dialog}->Destroy;
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about_credits_maketab
{
	# Get the passed data
	my ($credits, $names, $tabname) = @_;
	
	# Make the page
	$page = Wx::Panel->new($credits->{tabwindow}, -1);
	
	# Make a gridsizer
	$grid = Wx::GridSizer->new(1,1,0,0);
	
	# Make a textcontrol
	$textcontrol = Wx::TextCtrl->new($page,-1,"$names",wxDefaultPosition,wxDefaultSize,wxTE_READONLY|wxTE_MULTILINE);
	
	# Add the textcontrol to the sizer
	$grid->Add($textcontrol, 0, wxALL|wxEXPAND, 5);
	
	# Add the sizer to the page
	$page->SetSizer($grid);
	
	# Add page to tabwindow
	$credits->{tabwindow}->AddPage($page,$tabname);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about_license
{
	# Get the passed data
	my ($about, $event) = @_;
	
	# Make an object for the license window
	my $license = {};
	
	# Make the dialog window
	$license->{dialog} = Wx::Dialog->new(undef, -1, "License");
	
	# Make a scrolledwindow
	$license->{scroll} = Wx::ScrolledWindow->new($license->{dialog}, -1);
	
	# Make a flexgrid sizer with 1 column and 2 rows (works better for this purpose)
	$license->{vertical} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Make a gridsizer for the scrolledwindow to contain the label
	$license->{scrollgrid} = Wx::GridSizer->new(1,1,0,0);
	
	# Make label to with the license text (so much text!)
	$license->{text} = Wx::TextCtrl->new($license->{scroll}, -1, "            GNU GENERAL PUBLIC LICENSE
               Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.
     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.

            GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The \"Program\", below,
refers to any such program or work, and a \"work based on the Program\"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term \"modification\".)  Each licensee is addressed as \"you\".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.

  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.

  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and \"any
later version\", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

                NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

             END OF TERMS AND CONDITIONS",wxDefaultPosition,wxDefaultSize,wxTE_READONLY|wxTE_MULTILINE);
	
	# Make a close button and connect it to an event
	$license->{close} = Wx::Button->new($license->{dialog}, -1, "Close");
	EVT_BUTTON($license->{close}, -1, \&about_close);
	
	# Add everything to the sizer
	$license->{scrollgrid}->Add($license->{text}, 1, wxALL|wxEXPAND, 5);
	$license->{scroll}->SetSizer($license->{scrollgrid});
	$license->{vertical}->Add($license->{scroll}, 1, wxALL|wxEXPAND, 5);
	$license->{vertical}->Add($license->{close}, 0, wxALL|wxALIGN_RIGHT, 5);
	$license->{dialog}->SetSizer($license->{vertical});
	
	# Set size of the dialog
	$license->{dialog}->SetSize(600,465);
	$license->{dialog}->SetMinSize($license->{dialog}->GetSize());
	$license->{dialog}->SetMaxSize($license->{dialog}->GetSize());
	
	setScrollBars($license->{scroll});
	
	# Show the dialog
	$license->{dialog}->ShowModal;
	$license->{dialog}->Destroy;
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about_close
{
	# Get the passed data
	my ($about, $event) = @_;
	
	# Close the about dialog
	$about->GetParent()->Destroy;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub get_rsuversion
{
	# Make a variable to contain the version number
	my $version;
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Launch the runescape script and get the version
		$version = `"$cwd/rsu/rsu-query" client.launch.runescape --version --showcmd=true`;
	}
	# Else
	else
	{
		# Launch the runescape script and get the version
		$version = `"$cwd/rsu/rsu-query" client.launch.runescape --version --unixquery`;
	}
	
	# Use regular expression to get only the version number
	$version =~ s/.+version\s+(\d{1,1}\.\d{1,1}\.\d{1,1})\s+/$1/;
	
	# Return the result
	return $version;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub playoldschool
{
	# If we are not on windows
	if ($OS !~ /MSWin32/)
	{
		# Run the runescape script
		system "\"$cwd/rsu/rsu-query\" client.launch.runescape --prmfile=oldschool.prm --unixquery &";
	}
	# Else
	else
	{
		# Run the runescape executable
		system (1,"\"$cwd/rsu/rsu-query.exe\" client.launch.runescape --prmfile=oldschool.prm --showcmd=true");
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub playnow
{
	# If we are not on windows
	if ($OS !~ /MSWin32/)
	{
		# Run the runescape script
		system "\"$cwd/rsu/rsu-query\" client.launch.runescape --unixquery &";
	}
	# Else
	else
	{
		# Run the runescape executable
		system (1,"\"$cwd/rsu/rsu-query.exe\" client.launch.runescape --showcmd=true");
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub update
{
	# Get the passed data
	my ($self, $event) = @_;
	
	# If we are not on windows
	if ($OS =~ /MSWin32/)
	{
		# Get the handle for the perl window
		my $cmdwindow = Win32::GUI::GetPerlWindow();
		# Show the cmd window
		Win32::GUI::Show($cmdwindow) if "@ARGV" =~ /--showcmd=true/;
		
		# Run the runescape executable
		system "\"$cwd/rsu/rsu-query.exe\" client.launch.updater";
		
		# If --showcmd=false is passed
		if ("@ARGV" =~ /--showcmd=false/)
		{
			# Hide the cmd window again
			Win32::GUI::Hide($cmdwindow);
		}
		
		# Tell the user that they should close the launcher and run "Download-Windows-Files.exe" to finish the update
		#Wx::MessageBox("Finished running the updater!\nPlease close the Launcher and run the \"Download-Windows-Files.exe\"\nlocated in the client's folder to finish the update.", "Running update complete!", wxOK,$self);
		
	}
	# Else
	else
	{
		# Run the update script
		system "\"$cwd/rsu/rsu-query\" client.launch.updater &";
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub settings
{
	# If we are not on windows
	if ($OS !~ /MSWin32/)
	{
		# Run the runescape script
		system "\"$cwd/rsu/rsu-query\" client.launch.settings &";
	}
	# Else
	else
	{
		# Run the runescape executable
		system (1,"\"$cwd/rsu/rsu-query.exe\" client.launch.settings");
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub forums
{
	# Open the forums in the default web browser
	Wx::LaunchDefaultBrowser("http://services.runescape.com/m=forum/forums.ws");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub linuxthread
{
	# Open the linux thread in the default web browser
	Wx::LaunchDefaultBrowser("http://services.runescape.com/m=forum/forums.ws?25,26,99,61985129,goto,99999");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about_FALLBACK
{
	my $self = shift;
	
	# Make the about dialog info
	my $info = Wx::AboutDialogInfo->new;
	
	# Make a variable to contain the version number and also get the version number
	my $version = get_rsuversion();

	# Add info to the about dialog
	$info->SetName( 'RuneScape Unix Client' );
    $info->SetVersion( $version );
    $info->SetDescription( 'The Unofficial Universal Unix port of the RuneScape Downloadable Client for Windows' );
    $info->SetCopyright( '(c) 2011-2013 HikariKnight' );
    $info->SetWebSite( 'https://github.com/HikariKnight/rsu-client', 'Get the sourcecode from GitHub.com' );
    $info->SetDevelopers( ['HikariKnight - Main developer\n', '### Contributors ###\n', 'Ker Laeda - AUR Repository maintainer', 'Garage Punk - forcepulseaudio code', 'Jmb71 - findjavalib regex', 'Ethoxyethaan - original launch script for Linux', 'Fallen_Unia - Zenity support in the Updater' ] );
    $info->SetLicense("GNU General Public License Version2
Copyright (C) 2011-2013  HikariKnight

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

See the file COPYING for more information.");

    $info->SetArtists( [ 'None' ] );

    Wx::AboutBox( $info );
}

#
#---------------------------------------- *** ----------------------------------------
#

sub launch_addon
{
	# Get the passed data
	my ($self, $event) = @_;
	
	# Get the name of the addon that triggered the event
	my $addon_id = $event->GetEventObject()->GetName();
	
	# Make a variable which will contain only the unique id and not the universal_ or $OS_ identifier
	my $addon = $addon_id;
	
	# Remove the identifier from the variable $addon
	$addon  =~ s/^(universal|$OS)_//;
	
	# If the addon_id starts with universal_
	if ($addon_id =~ /^universal_/)
	{
		# If we are on windows
		if ($OS =~ /MSWin32/)
		{
			# Launch the universal addon
			system (1,"\"$cwd/rsu/rsu-query.exe\" addon.universal.launch $addon --showcmd=true &");
		}
		# Else
		else
		{
			# Launch the universal addon
			system "\"$cwd/rsu/rsu-query\" addon.universal.launch $addon &";
		}
	}
	# Else
	else
	{
		# If we are on windows
		if ($OS =~ /MSWin32/)
		{
			# Launch the platform specific addon
			system (1,"\"$cwd/rsu/rsu-query.exe\" addon.platform.launch $addon --showcmd=false &");
		}
		# Else
		else
		{
			# Launch the platform specific addon
			system "\"$cwd/rsu/rsu-query\" addon.platform.launch $addon &";
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

sub open_addonsdir
{
	# Get the pointers
	my ($self,$event) = @_;
	
	# Put the path to the addons directory into a variable
	my $addonsdir = "$clientdir/share/addons";
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Replace all / with \
		$addonsdir =~ s/\//\\/g;
		
		# Open the addons directory
		system (1,"explorer.exe \"$addonsdir\"");
	}
	# Else if we are on darwin/mac
	elsif($OS =~ /darwin/)
	{
		# Open the addons directory
		system "open \"$addonsdir/\"";
	}
	# Else
	else
	{
		# Open the addons directory
		system "xdg-open \"$addonsdir/\"";
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
