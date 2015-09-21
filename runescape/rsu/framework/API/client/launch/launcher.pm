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

# Use the File::Path module
use File::Path qw(make_path remove_tree);

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

# Use the rsu copy module
require rsu::files::copy;

# Use the grep module
require rsu::files::grep;

# Use the rsu dirs module
require rsu::files::dirs;

# Use client environment module
use client::env;

# Get the users home directory
my $HOME = client::env::home();

# If this script have been installed systemwide
if ($cwd =~ /^(\/usr\/s?bin|\/opt\/|\/usr\/local\/s?bin)/)
{
	# Print debug info
	print "The script is running from a system path!\n".$HOME."/.config/runescape will be used as client folder instead!\n\n";
		
	# Make the client folders
	make_path($clientdir."/bin", $clientdir."/share/img", $clientdir."/share/configs", $clientdir."/share/prms");
	
	# Tell user what we are doing
	print "Symlinking icon and updating examples\n";
	
	# Remove old unused icon
	unlink "\"".$clientdir."/share/img/jagexappletviewer.png\"";
	
	# Symlink or Copy needed resources to the clientdir
	system "ln -sf \"".$cwd."/share/img/OldSchool\" \"".$clientdir."/share/img/OldSchool\"" unless -e $clientdir."/share/img/OldSchool/jagexappletviewer.png";
	system "ln -sf \"".$cwd."/share/img/RuneScape3\" \"".$clientdir."/share/img/RuneScape3\"" unless -e $clientdir."/share/img/RuneScape3/jagexappletviewer.png";
	system "ln -sf \"".$cwd."/share/img/Retro\" \"".$clientdir."/share/img/Retro\"" unless -e $clientdir."/share/img/Retro/jagexappletviewer.png";
	system "ln -sf \"".$cwd."/share/img/FunOrb\" \"".$clientdir."/share/img/FunOrb\"" unless -e $clientdir."/share/img/FunOrb/jagexappletviewer.png";
	
	# Copy the examples (should always be kept up to date)
	rsu::files::copy::print_cp($cwd."/share/configs/settings.conf.example", $clientdir."/share/configs/settings.conf.example");
	rsu::files::copy::print_cp($cwd."/share/prms/runescape.prm.example", $clientdir."/share/prms/runescape.prm.example");
	
	# Check the contents of $clientdir/share
	my @localcheck = rsu::files::dirs::rlist("$clientdir/share");
	#my $prmfile_exists = `ls -la $clientdir/share|grep -P \"runescape.prm\$\"`;
	
	# Tell what we are doing
	print "Checking if any known files are still using the old folder structure\n";
	
	# For each value in the @localcheck array
	foreach my $checkfile (@localcheck)
	{
		# If runescape.prm exists in old directory format
		if ($checkfile =~ /$clientdir\/share\/runescape\.prm$/)
		{
			# Copy the example file to clientdir as runescape.prm
			rsu::files::copy::print_mv($clientdir."/share/runescape.prm", $clientdir."/share/prms/runescape.prm");
		}
		# If oldschool.prm exists in old directory format
		if ($checkfile =~ /$clientdir\/share\/oldschool\.prm$/)
		{
			# Copy the oldschool.prm file to clientdir
			rsu::files::copy::print_mv($clientdir."/share/oldschool.prm", $clientdir."/share/prms/oldschool.prm");
		}
		# If settings.conf exists in the old directory format
		if ($checkfile =~ /$clientdir\/share\/settings\.conf$/)
		{
			# Copy the oldschool.prm file to clientdir
			rsu::files::copy::print_mv($clientdir."/share/settings.conf", $clientdir."/share/configs/settings.conf");
		}
	}
	
	# Tell user what we are doing
	print "\nChecking if any default configurations are missing\n";
	
	# If runescape.prm do not exist
	if (!-e "$clientdir/share/prms/runescape.prm")
	{
		# Copy the example file to clientdir as runescape.prm
		rsu::files::copy::print_cp($cwd."/share/prms/runescape.prm.example", $clientdir."/share/prms/runescape.prm");
	}
	# If runescape-beta.prm do not exist
	if (!-e "$clientdir/share/prms/runescape-beta.prm")
	{
		# Copy the example file to clientdir as runescape.prm
		rsu::files::copy::print_cp($cwd."/share/prms/runescape-beta.prm", $clientdir."/share/prms/runescape-beta.prm");
	}
	# If oldschool.prm do not exist
	if (!-e "$clientdir/share/prms/oldschool.prm")
	{
		# Copy the oldschool.prm file to clientdir
		rsu::files::copy::print_cp($cwd."/share/prms/oldschool.prm", $clientdir."/share/prms/oldschool.prm");
	}
	# If addons_updater.conf do not exist
	if (!-e "$clientdir/share/configs/addons_updater.conf")
	{
		# Copy the oldschool.prm file to clientdir
		rsu::files::copy::print_cp($cwd."/share/configs/addons_updater.conf", $clientdir."/share/configs/addons_updater.conf");
	}
	
	# Check for funorb configs
	my @funorb = rsu::files::grep::dirgrep($cwd."/share/prms/","funorb_");
	
	# For each prm we found in the array
	foreach my $funorbprm(@funorb)
	{
		# If the funorb prm does not exist then
		if (!-e "$clientdir/share/prms/$funorbprm")
		{
			# Copy the funorb prm to the clientdir
			rsu::files::copy::print_cp($cwd."/share/prms/$funorbprm", $clientdir."/share/prms/$funorbprm")
		}
	}
		
	# Add a newline for tidyness
	print "\n";
}

# Require the files IO module
require rsu::files::IO;

# Read from the config file to find out which newschannel the user wants
my $newschannel = rsu::files::IO::readconf("newschannel", "runescape", "settings.conf");

#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------
#---------------------------------------- *** ----------------------------------------

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;
# Which events shall we include
use Wx::Event qw(EVT_BUTTON EVT_PAINT EVT_HTML_LINK_CLICKED EVT_CHOICE);

# FileSystem module, used for addons tab
#use Wx::FS;

# Use Wx::WebView if it exists
eval "use Wx::WebView";
# Use XML::RSSLite if it exists
eval "use XML::RSSLite";

# Require sysdload which containd a readurl function
require updater::download::sysdload;
require updater::download::file;

# Use the File::Path module so we can make and remove paths
use File::Path qw(make_path remove_tree);

use base qw(Wx::Frame Wx::ScrolledWindow);

# Require the files grep module
require rsu::files::grep;

# Require the files IO module
require rsu::files::IO;

# Require the info module so we can fetch the version number	
require rsu::info;

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
	
	#Wx::FileSystem::AddHandler(Wx::InternetFSHandler->new());
	
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
		#$self->{rssview} = Wx::ScrolledWindow->new($self->{mainpanel}, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxFULL_REPAINT_ON_RESIZE);
		$self->{rssview} = Wx::Panel->new($self->{mainpanel}, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxFULL_REPAINT_ON_RESIZE);
		
		# Make a painting event
		#EVT_PAINT( $self->{rssview}, \&OnPaint );
		# Change the RSSView background to black
		$self->{rssview}->SetBackgroundColour(Wx::Colour->new("#222222"));
	}
	
	# Create the boxsizer needed for the layout
	$self->{layoutsizer} = Wx::BoxSizer->new(wxHORIZONTAL);
	
	# Make a vertical box sizer for use to organize buttons
	$self->{buttonsizer} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Create a scrolledwindow for the buttons
	$self->{verticalbuttons} = Wx::ScrolledWindow->new($self->{mainpanel}, -1, wxDefaultPosition, wxDefaultSize );
	
#	# If we are on windows or mac
#	if ($OS =~ /(darwin)/)
#	{
#		# Make buttons
#		make_button($self, "playnow", "&Play Now");
#		make_button($self, "playoldschool", "Play &OldSchool");
#		make_button($self, "update", "Run &Updater");
#		make_button($self, "settings", "&Settings");
#		make_button($self, "forums", "RS &Forums");
#		$self->{buttonsizer}->Add(1,1,1);
#		make_button($self, "linuxthread", "&Linux Thread");
#	}

	# Make bitmap buttons (mainobject, parent, sizer, eventname, imageprefix)
	make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "playnow", "playnow");
	#make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "playoldschool", "oldschool");
	make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "update", "runupdater");
	make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "settings", "settings");
	make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "forums", "forums");
	$self->{buttonsizer}->Add(1,1,1);
	make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "linuxthread", "linuxthread");
	
	# Make a bitmap button for the about dialog
	make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "about", "about");
	
	# If the --add-exitbutton is passed as an argument
	if ("@ARGV" =~ /--closebutton=1/)
	{
		# Make an exit button
		make_bitmapbutton($self, $self->{verticalbuttons}, $self->{buttonsizer}, "close_clicked", "close");
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
		
		# Make a vertical box sizer for use to organize the rss
		$self->{rss_container} = Wx::BoxSizer->new(wxVERTICAL);
		
		# Make a horizontal boz sizer for the top of the rssfeed
		$self->{rss_top} = Wx::BoxSizer->new(wxHORIZONTAL);
		
		# Make a label for the top of the rssfeed
		$self->{playercount} = Wx::StaticText->new($self->{rssview}, -1, get_playercount(), wxDefaultPosition, wxDefaultSize,);
		
		# Make a refresh button
		#$self->{rssRefresh} = Wx::Button->new($self->{rssview}, wxID_ANY, "Refresh News") if $OS =~ /(darwin)/;
		$self->{rssRefresh} = Wx::BitmapButton->new($self->{rssview}, -1, Wx::Bitmap->new("$resourcedir/bitmaps/refresh.png", wxBITMAP_TYPE_PNG), wxDefaultPosition, wxDefaultSize, wxNO_BORDER);
		$self->{rssRefresh}->SetBitmapSelected(Wx::Bitmap->new("$resourcedir/bitmaps/refresh_press.png", wxBITMAP_TYPE_PNG)) if $OS =~ /(MSWin32|darwin)/;
		$self->{rssRefresh}->SetBackgroundColour(Wx::Colour->new("#222222"));
		$self->{rssRefresh}->SetName("refreshnews");
        
        # Make the foreground around the refresh button appear black
        $self->{rssRefresh}->SetForegroundColour(Wx::Colour->new("#222222"));
			
		# Add a tooltip to the button
		$self->{rssRefresh}->SetToolTip("Click here to refresh the news RSS feed.");
		
		# Make an event for the refresh button
		EVT_BUTTON($self, $self->{rssRefresh}, \&refreshnews_clicked);
		
		# Make a choice for the profile selector
		$self->{prmSelect} = Wx::Choice->new($self->{rssview}, wxID_ANY);
		loadprms($self);
		
		# Add the playercount and button to the sizer
		$self->{rss_top}->Add($self->{playercount},1, wxALL|wxALIGN_CENTER_VERTICAL,0);
		$self->{rss_top}->Add($self->{rssRefresh}, 0, wxALL|wxALIGN_RIGHT, 1);
		$self->{rss_top}->Add($self->{prmSelect},0,wxALL|wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL,1);
		$self->{rss_container}->Add($self->{rss_top}, 0, wxALL|wxEXPAND, 1);
		
		# Create a HtmlWindow  (not to be confused with a browser window!)
		$self->{htmlview} = Wx::HtmlWindow->new($self->{rssview}, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxHW_DEFAULT_STYLE);
		
		# Add the htmlview to the sizer
		$self->{rss_container}->Add($self->{htmlview}, 1, wxALL|wxEXPAND, 0);
		
		# Use the rss_container as the sizer for rssview
		$self->{rssview}->SetSizer($self->{rss_container});
		
		# Make an empty newspage
		make_newspage($self);
		
		# If the newschannel is oldschool
		if ($newschannel =~ /oldschool/)
		{
			# Fetch rssfeed for oldschool
			fetch_rssnews($self, "http://services.runescape.com/m=news/latest_news.rss?oldschool=true");
		}
		# Else
		else
		{
			# Fetch rssfeed for oldschool
			fetch_rssnews($self, "http://services.runescape.com/m=news/latest_news.rss");
		}
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
	if ($OS =~ /darwin/)
	{
		$self->SetSize(800,450);
	}
	# Else
	else
	{
		$self->SetSize(1,450);
		$self->SetMinSize($self->GetSize);
		$self->Fit();
	}
	
	# Set the colors
	set_colors($self);
	
	# Set minimum size
	$self->SetMinSize($self->GetSize);
	
	# Set the layout
	$self->Layout;
	# Refresh window
	$self->Refresh;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_colors
{
	# Get the passed data
	my ($self) = @_;
	
	# If we are not on windows
	if ($OS !~ /MSWin32/)
	{
		# Set these colors
		#$self->{tabcontrol}->SetBackgroundColour(Wx::Colour->new("#222222"));
		#$self->{tabcontrol}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
		$self->SetBackgroundColour(Wx::Colour->new("#000000"));
		#$self->SetForegroundColour(Wx::Colour->new("#000000"));
	}
	
	# Set the colors
	$self->{playercount}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	$self->{playercount}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{verticalbuttons}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{verticalbuttons}->SetForegroundColour(Wx::Colour->new("#222222"));
	$self->{mainpanel}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{mainpanel}->SetForegroundColour(Wx::Colour->new("#222222"));
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
	
	# Create a addons htmlwindow for displaying installed addons
	$self->{addonsview} = Wx::HtmlWindow->new($self->{addonspage}, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxHW_DEFAULT_STYLE);
	
	# Add the addons htmlwindow to the sizer
	$self->{addonsvertical}->Add($self->{addonsview},1,wxALL|wxEXPAND,0);
	
	# Load the addons into the addonsview
	load_addons($self);
	
	# Set colors the widgets
	$self->{addonspage}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$self->{addonspage}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	#$self->{addons_labeltop}->SetBackgroundColour(Wx::Colour->new("#222222"));
	#$self->{addons_labeltop}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	#$self->{addonsdirbutton}->SetForegroundColour(Wx::Colour->new("#222222"));
	#$self->{addons_installed}->SetBackgroundColour(Wx::Colour->new("#222222"));
	#$self->{addons_installed}->SetForegroundColour(Wx::Colour->new("#E8B13F"));
	
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

sub load_addons 
{
	# Get the passed data
	my ($self) = @_;
	
	# Create a variable to contain the addonsview html code
	my $addonshtml = "<html>
	<body bgcolor=#222222>
		<table width=100%>
		<tr>
			<td width=87%>
				<center>
					<a href=\"open://addonsdir\">
						<font size=4 color=#E8B13F>
							Click here to open the Addons Folder!
						</font>
					</a>
				</center>
			</td>
			<td>
				<a href=\"refresh://addons\">
					<font size=3 color=#E8B13F>
						Refresh list
					</font>
				</a>
			</td>
		</tr>
		<tr>
			<td>
				<center>	
					<font size=2 color=#E8B13F>
						<b>Addons you have installed are shown below.</b>
					</font>
				</center>
			</td>
		</tr>
		</table>
		<table width=100% bgcolor=#222222>
			<tr>";
			
	# Create a variable of the addons content
	my @addonscontent;
	
	# Get the addon directories which are supported by this platform
	my @addondirs = rsu::files::grep::dirgrep("$clientdir/share/addons/","^(universal|$OS)\$");
	
	# For each addon directory found
	foreach my $addondir (@addondirs)
	{
		# If the current content is either named universal or the same as $OS
		if (($addondir =~ /^universal$/ && -d "$clientdir/share/addons/$addondir") || ($addondir =~ /^$OS$/ && -d "$clientdir/share/addons/$addondir"))
		{
			# Create addon tables and put them in an array
			@addonscontent = make_addon_buttons($self, "$clientdir/share/addons/$addondir", @addonscontent);
		}
	}
	
	# Make a counter so we know when to add a new row to the grid
	my $counter = 0;
	
	# For each addon table we have inside the addonscontent array
	foreach my $addontable (@addonscontent)
	{
		# If $counter is a modulo of 4 (translation: every 4th)
		if (($counter %= 4) == 0)
		{
			# Increase the amount of rows by 1
			$addonshtml = "$addonshtml
			</tr>
			<tr>";
		}
		
		# Add the addon table to the addonshtml
		$addonshtml = "$addonshtml
		$addontable";
		
		# Increase counter by 1
		$counter += 1;
	}
	
	# Add the end of the addonshtml
	$addonshtml = "$addonshtml
			</tr>
		</table>
	</body>
</html>";

	# Add the html to the addonsview
	$self->{addonsview}->SetPage($addonshtml);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_newspage
{
	# Get the passed data
	my ($self) = @_;
	
	$self->{htmlview}->SetPage("<html>
	<body bgcolor=#222222>
			<table width=100%>
				<td>
					<b>
						<font color=#E8B13F size=+1>Failed to load newsfeed from http://runescape.com</font>
					</b>
				</td>
			</table>
			<table width=100%>
				<td width=5%>
				</td>
				<td>
					<font color=#B8B8B8 size=-1 >Published: Sometime</font>
				</td>
			</table>
			<table width=100%>
				<tr>
					<td>
						<font color=#B8B8B8 size=3>If you see this then the newsfeed might have timed out...<br>Press the refresh button to try reload the newsfeed.</font>
					</td>
				</tr>
				<tr>
					<td>
						<a href=''><font color=#E8B13F size=3>Read More...</font></a>
					</td>
				</tr>
			</table>
	</body>
</html>");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub get_playercount
{
	# Make the download path
	make_path("$clientdir/.download/");
	
	# Tell the user what we are doing
	print "Fetching the current playercount.\n";
	
	# Download the file containing the current playercount (does not output to STDOUT)
	updater::download::file::from("http://www.runescape.com/player_count.js?varname=iPlayerCount&callback=jQuery17209493430445436388_1382425275438&_=".time,"$clientdir/.download/playercount.js",1);
	
	# Read the contents of the playercount.js
	my $playercount = rsu::files::IO::getcontent("$clientdir/.download","playercount.js");
	
	# If we managed to get the playercount
	if ($playercount =~ /jQuery.+\((.+)\);/)
	{
		# Remove the jQuery part of the output
		$playercount =~ s/jQuery.+\((.+)\);/$1/;
	}
	# Else
	else
	{
		# Set playercount to 0
		$playercount = 0;
	}
	
	# Remove the temp download folder
	remove_tree("$clientdir/.download/");
	
	# Tell the user what we are doing
	print "Fetching the current playercount from Old School RuneScape.\n";
	
	# Get the html from the oldschool homepage
	my $osrs_html = updater::download::sysdload::readurl("http://oldschool.runescape.com",5);
	
	# Fetch the oldschool homepage html so we can find the playercount
	my @osrs_grep = rsu::files::grep::strgrep($osrs_html, "There are currently");
	
	# Transfer the playercount to a string so we can edit it
	my $osrs_playercount = "@osrs_grep";
	
	# If we managed to get the amount of OSRS players
	if ($osrs_playercount =~ /There are currently\s(.+)\speople playing!/)
	{
		# Remove the text
		$osrs_playercount =~ s/.+There are currently\s(.+)\speople playing!.+/$1/;
		
		# If OSRS player count failed (as in we dont have a number)
		if ($osrs_playercount !~ /^\d+$/)
		{
			# Replace the OSRS playercount with 0
			$osrs_playercount = 0;
		}
		
		# Remove OSRS players from RS3 playercount if $playercount is not 0
		$playercount = $playercount-$osrs_playercount if $playercount !~ /^0$/;
	}
	# Else
	else
	{
		# Set OSRS playercount to 0
		$osrs_playercount = 0;
	}
	
	# Return the playercount
	return "RS3 Players Online: ".commify($playercount)."\nOSRS Players Online: ".commify($osrs_playercount);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetch_rssnews
{
	# Get the passed data
	my ($self, $rssurl) = @_;
	
	# Make a vertical box sizer for use to organize the rss
	#$self->{rss_sizer} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Fetch the recent activity rss feed (timeout after 3 seconds)
	my $rssfeed = updater::download::sysdload::readurl($rssurl,3);
	
	# Display the response, for debugging purposes
	print "\n\nResponse from RSSFEED: $rssfeed\n\n";
	
	# If the rssfeed contains html code, nothing or a "bad response"
	if ($rssfeed =~ /<(html|ul|li|ol|body|div)>/ || $rssfeed =~ /^$/ || $rssfeed =~ /(could not connect to|bad hostname)/i)
	{
		# Print error message
		print "Error reading rssfeed, found html code instead!\nMaybe the website is down for maintenance?\n\n";
		
		# Add the error page to the newsfeed
		$self->{htmlview}->SetPage("<html>
	<body bgcolor=#222222>
			<table width=100%>
				<td>
					<b>
						<font color=#E8B13F size=+1>Failed to load newsfeed from http://runescape.com</font>
					</b>
				</td>
			</table>
			<table width=100%>
				<td width=5%>
				</td>
				<td>
					<font color=#B8B8B8 size=-1 >Published: Sometime</font>
				</td>
			</table>
			<table width=100%>
				<tr>
					<td>
						<font color=#B8B8B8 size=3>If you see this then the newsfeed might have timed out or the rssfeed is down...<br>Press the refresh button to try reload the newsfeed.</font>
					</td>
				</tr>
				<tr>
					<td>
						<a href=''><font color=#E8B13F size=3>Read More...</font></a>
					</td>
				</tr>
			</table>
	</body>
</html>");
	}
	# Else
	else
	{
		# Write debug info to STDOUT
		print "This is the RSS contents we found:\n$rssfeed\n\n";
		
		# Make a hash reference for the RSSLite parser
		my %rssnews;
		
		# Parse the RSSfeed
		parseRSS(\%rssnews, \$rssfeed);
		
		# Write debug info to STDOUT
		print "Parsing the news RSS feed(output is shown the way the GUI reads it):\n";
		
		# Make a counter to keep track of the news
		my $counter = 1;
		
		# Make a variable to hold the html code
		my $newspage = "<html>
	<body bgcolor=\"#222222\">";
	
		# If the rssfeed is the oldschool news
		if ($rssnews{'title'} =~ /oldschool/i)
		{
			# Add the rssfeed title to the page and a link to switch to the other rssfeed
			$newspage = "$newspage
		<table width=100% valign=top>
			<td>
					<font color=#E8B13F size=+1>$rssnews{'title'}</font>
			</td>
			<td valign=top>
					<div align=right><a href='news://runescape'><font color=#E8B13F size=0>View RuneScape News</font></a></div>
			</td>
		</table>";
		}
		else
		{
			# Add the rssfeed title to the page and a link to switch to the other rssfeed
			$newspage = "$newspage
		<table width=100% valign=top>
			<td>
					<font color=#E8B13F size=+1>$rssnews{'title'}</font>
			</td>
			<td valign=top>
					<div align=right><a href='news://oldschool'><font color=#E8B13F size=0>View OldSchool News</font></a></div>
			</td>
		</table>";
		}
	
		# For each value in the array
		foreach my $item (@{$rssnews{'item'}})
		{
			##### Generate Title #####
			
			# Get the news title text so we can format it
			my $rssTitle = "$item->{'title'}";
			
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
			
			# Write debug info to STDOUT
			print "Adding News Title$counter: \"$rssTitle\"\n";
			
			# Add the news title to the html code
			$newspage = "$newspage
		<table width=100%>
			<td>
				<b>
					<font color=#E8B13F size=+1>$item->{'title'}</font>
				</b>
			</td>
		</table>";
		
			##### Generate Date #####
			
			# Get the published date so we can remove the unused time
			my $rssDate = "$item->{'pubDate'}";
			
			# Remove the timestamp because it is always 00:00:00 GMT
			$rssDate =~ s/\s+\d{2,2}:\d{2,2}:\d{2,2}\s+GMT//g;
			
			# Write debug info to STDOUT
			print "Adding Published Date$counter: \"$rssDate\"\n";
			
			# Add the published date to the html code
			$newspage = "$newspage
		<table width=100%>
			<td width=25px>
			</td>
			<td>
				<font color=#B8B8B8 size=-1 >Published: $rssDate</font>
			</td>
		</table>";
		
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
			
			# Write debug info to STDOUT
			print "Adding News Description$counter: \"$rssDescription\"\n";
			
			# Add the news description to the html code
			$newspage = "$newspage
		<table width=100%>
			<tr>
				<td>
					<font color=#B8B8B8 size=3>$item->{'description'}</font>
				</td>
			</tr>";
		
			##### Generate Link #####
			
			# Write debug info to STDOUT
			print "Adding News Link$counter: \"$item->{'link'}\"\n\n";
			
			# Add the Read More... link to the html code
			$newspage = "$newspage
			<tr>
				<td>
					<a href=\"$item->{'link'}\"><font color=#E8B13F size=3>Read More...</font></a>
				</td>
			</tr>
		</table>
		<hr>";
		
			# Increase counter by 1
			$counter += 1;
		}
	
		# Add the ending html code to the newspage
		$newspage = "$newspage
	</body>
</html>";

		# Tell the user the generated html code
		print "Generated html code from rssfeed:\n$newspage\n\n";

		# Display the html we generated from the rssfeed
		$self->{htmlview}->SetPage($newspage);	
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub refreshnews_clicked
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Print debug information
	print "Refreshing the playercount!\n";
	
	# Set the playercount
	$self->{playercount}->SetLabel(get_playercount());
	
	# Print debug information
	print "User requested to refresh the newsfeed!\nRefreshing the newsfeed now!\n\n";
	
	# Get the current newschannel
	$newschannel = rsu::files::IO::readconf("newschannel","runescape","settings.conf");
	
	# If the current newschannel is oldschool
	if ($newschannel =~ /oldschool/)
	{
		# Refresh the rssfeed for oldschool
		fetch_rssnews($self, "http://services.runescape.com/m=news/latest_news.rss?oldschool=true");
	}
	# Else
	else
	{
		# Refresh the rssfeed for runescape
		fetch_rssnews($self, "http://services.runescape.com/m=news/latest_news.rss");
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub hyperlink_clicked
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Get the call (link)
	my $call = $event->GetLinkInfo()->GetHref();
	
	# If the call is a news call
	if ($call =~ /^news:\/\//)
	{
		# If the call is for the oldschool news
		if ($call =~ /^news:\/\/oldschool/)
		{
			# Refresh the rssfeed with oldschool news
			fetch_rssnews($self, "http://services.runescape.com/m=news/latest_news.rss?oldschool=true");
			
			# Set the newschannel to oldschool in settings
			rsu::files::IO::writeconf("_", "newschannel", "oldschool", "settings.conf");
		}
		# Else if the call is for the runescape news
		elsif ($call =~ /^news:\/\/runescape/)
		{
			# Refresh the rssfeed with RuneScape news
			fetch_rssnews($self, "http://services.runescape.com/m=news/latest_news.rss");
			
			# Set the newschannel to oldschool in settings
			rsu::files::IO::writeconf("_", "newschannel", "runescape", "settings.conf");
		}
	}
	else
	{
		# Print debug information
		print "Clicked on link: ".$event->GetLinkInfo()->GetHref()."\nOpening link in the default Web Browser\n\n";
	
		# Open the hyperlink url in the default web browser
		Wx::LaunchDefaultBrowser($event->GetLinkInfo()->GetHref());
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub getsource_clicked
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Print debug information
	print "User requested the sourcecode!\nOpening link in the default Web Browser\n\n";
	
	# Get the URL we are supposed to launch
	my $hyperlink = $event->GetEventObject()->GetToolTip()->GetTip();
	
	# Open the hyperlink url in the default web browser
	Wx::LaunchDefaultBrowser($hyperlink);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_addon_buttons
{
	# Get the passed data
	my ($self, $addondir, @addonscontent) = @_;
	
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
		
		# Generate an id for the addon
		my $addon_id = "$folder_id[-3]://$folder_id[-2]";
		
		# Try to get the addon name (if nothing is found then use the folder id as addon name)
		my $addon_name = rsu::files::IO::readconf("name", "$addon_id", "info.conf", $addon_path);
		
		# Incase the id becomes the name we can remove universal_ or $OS_ from the start of the name
		$addon_name =~ s/^(universal|$OS):\/\///;
		
		# Get the addon description
		my $addon_description = rsu::files::IO::readconf("description", "No description available for $addon_name", "info.conf", $addon_path);
		
		# Replace \n with space in the description
		$addon_description =~ s/\\n/ /g;
		
		# Get the addon description
		my $addon_icon = rsu::files::IO::readconf("icon", "noicon", "info.conf", $addon_path);
		
		# Check if there is a download url in the info.conf
		my $addon_url = rsu::files::IO::readconf("url", "", "info.conf", $addon_path);
		
		# If the addon url is not empty
		if ($addon_url ne '')
		{
			# Generate an updater entry
			generate_updater_entry($addon_id, $addon_name, $addon_url, $addon_description);
		}
		print "adding table for $addon_name\n\n";
		# Make the addons buttons
		push @addonscontent, "<td bgcolor=#000000 valign=top>
			<table width=100%>
				<tr>
				<td width=90%>
					<div align=right><a href=\"delete://$addon_id\"><font size=4 color=#E8B13F>[X]</font></a></div>
				</td>
				</tr>
				<tr>
				<a href=\"$addon_id\">
				<td width=90%>
					<center><img src=\"$addon_path/$addon_icon\" width=64 height=64></center>
				</td>
				</a>
				</tr>
				<tr>
				<a href=\"$addon_id\">
				<td width=90%>
					<center><font size=3 color=#E8B13F>$addon_name</font></center>
				</td>
				</a>
				</tr>
				<tr>
				<td width=90%>
					<center><font size=2 color=#E8B13F>$addon_description</font></center>
				</td>
				</tr>
			</table>
		</td>";
	}
	
	return @addonscontent;
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
	if ("@ARGV" !~ /--webview/)
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
	
	EVT_CHOICE($self,$self->{prmSelect},\&prmChanged);
	
	EVT_HTML_LINK_CLICKED($self, $self->{htmlview}, \&hyperlink_clicked);
	EVT_HTML_LINK_CLICKED($self, $self->{addonsview}, \&addon_handler);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub prmChanged
{
	# Get the pointers
	my ($self) = @_;
	
	# Save the prm selection
	rsu::files::IO::writeconf("_", "prmfile", $self->{prmSelect}->GetString($self->{prmSelect}->GetSelection()), "settings.conf");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_button
{
	my ($self, $button, $label) = @_;
	
	# Make a button for the launcher
	$self->{$button} = Wx::Button->new($self->{verticalbuttons}, -1, "$label");
	$self->{$button}->SetForegroundColour(Wx::Colour->new("#222222"));
	$self->{buttonsizer}->Add($self->{$button},0,wxEXPAND|wxALL,5);
	
	# Make an event trigger for the newly created button
	EVT_BUTTON($self->{$button}, -1, \&$button);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub make_bitmapbutton
{
	my ($self, $parent, $sizer, $button, $bitmap) = @_;
	
	# Make a button for the launcher
	$self->{$button} = Wx::BitmapButton->new($parent, -1, Wx::Bitmap->new("$resourcedir/bitmaps/$bitmap.png", wxBITMAP_TYPE_PNG), wxDefaultPosition, wxDefaultSize, wxNO_BORDER|wxTRANSPARENT_WINDOW);
	$self->{$button}->SetBitmapSelected(Wx::Bitmap->new("$resourcedir/bitmaps/$bitmap"."_press.png", wxBITMAP_TYPE_PNG)) if $OS =~ /(MSWin32|darwin|linux)/;
	$self->{$button}->SetForegroundColour(Wx::Colour->new("#222222"));
	$self->{$button}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$sizer->Add($self->{$button},0,wxEXPAND|wxALL,5) if $OS =~ /(MSWin32)/;
	$sizer->Add($self->{$button},0,wxEXPAND|wxALL,3) if $OS =~ /(darwin)/;
	$sizer->Add($self->{$button},0,wxEXPAND|wxALL,0) if $OS !~ /(MSWin32|darwin)/;
	
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
	$about->{dialog} = Wx::Dialog->new($self, -1, "About RuneScape Unix Client");
	
	# Set the colors of the dialog
	$about->{dialog}->SetBackgroundColour(Wx::Colour->new("#222222"));
	
	# Get the rsu version
	my $version = get_rsuversion();
	
	# Prepare the interface sizers
	$about->{vertical} = Wx::BoxSizer->new(wxVERTICAL);
	$about->{horizontal} = Wx::BoxSizer->new(wxHORIZONTAL);
	
	# Create a HtmlWindow  (not to be confused with a browser window!)
	$about->{info} = Wx::HtmlWindow->new($about->{dialog}, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxHW_DEFAULT_STYLE);
	
	# Connect the htmlwindow to the html link event
	EVT_HTML_LINK_CLICKED($about->{info},$about->{info}, \&about_link);
	
	# Fill the htmlwindow with information
	$about->{info}->SetPage("<html>
	<body bgcolor=#222222>
		<table bgcolor=#222222>
			<tr>
				<td><center><img src='$cwd/share/img/runescape.png'></center></td>
			</tr>
			<tr>
				<td><center><b><font color=#E8B13F size=+1>RuneScape Unix Client<br>Version: $version</font></b></center></td>
			</tr>
			<tr>
				<td><center><font color=#B8B8B8>The Unofficial Universal Unix port of the RuneScape Downloadable Client for Windows</font></center></td>
			</tr>
			<tr>
				<td><center><font color=#B8B8B8>&copy; 2011-2014 <a href=http://twitter.com/rsHikariKnight><font color=#B8B8B8>HikariKnight</font></a></font></center></td>
			</tr>
			<tr>
				<td><center><a href=https://github.com/HikariKnight/rsu-client><font color=#E8B13F>Get the sourcecode from GitHub.com</font></a></center></td>
			</tr>
		</table>
	</body>
</html>");
	
	# Make bitmapbuttons for the bottom of the about dialog
	# And make the events for the buttons
	make_bitmapbutton($about, $about->{dialog},$about->{horizontal},"about_credits", "credits");
	make_bitmapbutton($about, $about->{dialog},$about->{horizontal},"about_license", "license");
	$about->{horizontal}->Add(70,10,10,wxALL|wxEXPAND,0);
	make_bitmapbutton($about, $about->{dialog},$about->{horizontal},"about_close", "close");
	
	# Add everything to the vertical sizer
	$about->{vertical}->Add($about->{info},1, wxEXPAND,0);
	$about->{vertical}->Add($about->{horizontal}, 0, wxALIGN_CENTER_HORIZONTAL|wxALL,5);
	
	# Set the sizers
	$about->{dialog}->SetSizer($about->{vertical});
	
	# Set max and min size of the aboutdialog
	$about->{dialog}->SetMaxSize(Wx::Size->new(405,435));
	$about->{dialog}->SetMinSize(Wx::Size->new(405,435));
	$about->{dialog}->SetSize(Wx::Size->new(405,435));
	
	# Show the dialog
	$about->{dialog}->Show();
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about_link
{
	# Get the passed data
	my ($about, $event) = @_;
	
	# Get the name of the addon that triggered the event
	my $url = $event->GetLinkInfo()->GetHref();
	
	# If the url starts with http or https
	if ($url =~ /^(http|https):/)
	{
		# Open the hyperlink url in the default web browser
		Wx::LaunchDefaultBrowser($url);
	}
	# Else
	else
	{
		# If we are on windows
		if ($OS =~ /MSWin32/)
		{
			# Use the default application to open the url handle
			system (1, "start \"$url\"");
		}
		# Else if we are on mac
		elsif ($OS =~ /darwin/)
		{
			# Use the default application to open the url handle
			system "open \"$url\"";
		}
		# Else
		else
		{
			# Remove mailto: from the url incase it is an E-Mail adress
			$url =~ s/^mailto://;
			
			# Use the default application to open the url handle
			system "xdg-open \"$url\"";
		}
	}
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
	$credits->{writtenby} = "name:HikariKnight;mailto:rshikariknight+client\@gmail.com;youtube:rsCommunityTech;twitter:rsHikariKnight;github:HikariKnight";
	$credits->{artworkby} = "none so far";
	$credits->{contributors} = "file:AUTHORS";
	
	# Make the dialog window
	$credits->{dialog} = Wx::Dialog->new($about, -1, "Credits");
	
	# Set the colors of the dialog
	$credits->{dialog}->SetBackgroundColour(Wx::Colour->new("#222222"));
	
	# Make a tab window
	$credits->{tabwindow} = Wx::Notebook->new($credits->{dialog}, -1);
	
	# Make a gridsizer for the tabwindow
	$credits->{mainsizer} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Make tabs
	about_credits_maketab($credits, "writtenby", $credits->{writtenby}, "Written By");
	about_credits_maketab($credits, "contributors", $credits->{contributors}, "Contributors");
	#about_credits_maketab($credits, $credits->{artworkby}, "Artwork By");
		
	# Add stuff to the window
	$credits->{mainsizer}->Add($credits->{tabwindow},1,wxEXPAND|wxALL,0);
	
	# Make the close button and make it close the window when clicked
	make_bitmapbutton($credits, $credits->{dialog},$credits->{mainsizer},"about_close", "close");
	
	$credits->{dialog}->SetSizer($credits->{mainsizer});
	
	# Set size of the window
	$credits->{dialog}->SetSize(545,430);
	
	# Show the window
	$credits->{dialog}->Show();
}

#
#---------------------------------------- *** ----------------------------------------
#

sub about_credits_maketab
{
	# Get the passed data
	my ($credits, $name, $info, $tabname) = @_;
	
	# Make the page
	$page = Wx::Panel->new($credits->{tabwindow}, -1);
	
	# Make a gridsizer
	$grid = Wx::GridSizer->new(1,1,0,0);
	
	# Make a variable for the credits content
	my $content = "<html>
	<body bgcolor=#222222>
		<table bgcolor=#000000>
			<tr>
				<td width=36%>
					<b><font color=#E8B13F>Name (or RS Name):</font></b>
				</td>
				<td width=64%>
					<b><font color=#E8B13F>Contact or Website:</font></b>
				</td>
			</tr>
";
	
	# If the info starts with file: 
	if ($info =~ /^file:/)
	{
		# Remove file: from the $info
		$info =~ s/^file://;
		
		# Read the file provided
		my $file = rsu::files::IO::ReadFile("$cwd/$info");
		
		# Grep for only the authors and remove other text
		@authors = rsu::files::grep::strgrep("@$file","^\\s+\\*\\s+");
		
		# For each author listed
		foreach my $author(@authors)
		{
			# Skip these names as they are listed in a different tab
			next if $author =~ /HikariKnight/;
			
			# Format the string a bit better
			$author =~ s/^\s+\*\s+(.+)/$1/;
						
			# If the author has a website/email listed
			if ($author =~ /<(.+)>/)
			{
				# Format the string again
				$author =~ s/^(.+)\s<(.+)>/$1;$2/;
				
				# Split the string at ;
				my @authorinfo = split(/;/,$author);
				
				# Make a variable for the clickable link
				my $link;
				
				# If the second column will be a website then
				if ($authorinfo[1] =~ /^(http|https):/)
				{
					# Split the url into an array using the rfc2396 regex so we can easily get the protocol and domain
					my @website = split(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/,$authorinfo[1]);
					
					# Generate a link for the website
					$link = "<font color=#B8B8B8>&lt;<a href='$authorinfo[1]'><font color=#E8B13F>$website[1]$website[3]</font></a>&gt;</font>";
				}
				# Else
				else
				{
					# Generate an email link
					$link = "<font color=#B8B8B8>&lt;<a href='mailto:$authorinfo[1]'><font color=#E8B13F>$authorinfo[1]</font></a>&gt;</font>";
				}
				
				# Generate the table entry for that contributor
				$content = "$content
			<tr>
				<td bgcolor=#222222>
					<font color=#B8B8B8>$authorinfo[0]</font>
				</td>
				<td bgcolor=#222222>
					$link
				</td>
			</tr>";
			}
			# Else
			else
			{
				# Generate the table entry for the contributor without email/website
				$content = "$content
			<tr>
				<td bgcolor=#222222>
					<font color=#B8B8B8>$author</font>
				</td>
				<td bgcolor=#222222>
					
				</td>
			</tr>";
			}
		}
	}
	# Else
	else
	{
		# Split the authors by newline
		my @authors = split(/\n/,$info);
		
		# For each author that is hardcoded
		foreach my $authordata(@authors)
		{
			# Split the authorinfo by ;
			my @authorinfo = split(/;/, $authordata);
			
			# Generate a new table row
			$content = "$content
			<tr>";
			
			# For each piece of info about the author
			foreach my $authorvalue(@authorinfo)
			{
				# If the value is a name
				if ($authorvalue =~ /^name:/)
				{
					# Remove the "name:" part of the string
					$authorvalue =~ s/^name://;
					
					# Generate the table entry
					$content = "$content
				<td bgcolor=#222222 valign=top>
					<br><br><font color=#B8B8B8>$authorvalue</font>
				</td>
				<td bgcolor=#222222>";
				}
				# Else if the value is a youtube name
				elsif ($authorvalue =~ /^youtube:/)
				{
					# Remove the "youtube:" part of the string
					$authorvalue =~ s/^youtube://;
					
					# Generate the table data
					$content = "$content
					<table>
						<td>
							<a href='http://youtube.com/user/$authorvalue'><img height=24 width=24 src=$resourcedir/bitmaps/links/youtube.png></a>
						</td>
						<td>
							<div valign=top><a href='http://youtube.com/user/$authorvalue'><font color=#E8B13F>$authorvalue</font></div></a>
						</td>
					</table>";
				}
				# Else if the value is a twitter name
				elsif ($authorvalue =~ /^twitter:/)
				{
					# Remove the "twitter:" part of the string
					$authorvalue =~ s/^twitter://;
					
					# Generate the table data
					$content = "$content
					<table>
						<td>
							<a href='http://twitter.com/$authorvalue'><img height=24 width=24 src=$resourcedir/bitmaps/links/twitter.png></a>
						</td>
						<td>
							<div valign=top><a href='http://twitter.com/$authorvalue'><font color=#E8B13F>\@$authorvalue</font></div></a>
						</td>
					</table>";
				}
				# Else if the value is a github name
				elsif ($authorvalue =~ /^github:/)
				{
					# Remove the "github:" part of the string
					$authorvalue =~ s/^github://;
					
					# Generate the table data
					$content = "$content
					<table>
						<td>
							<a href='http://github.com/$authorvalue'><img height=24 width=24 src=$resourcedir/bitmaps/links/github.png></a>
						</td>
						<td>
							<div valign=top><a href='http://github.com/$authorvalue'><font color=#E8B13F>\@$authorvalue</font></div></a>
						</td>
					</table>";
				}
				# Else if the value is a twitter name
				elsif ($authorvalue =~ /^mailto:/)
				{
					# Remove the "mailto:" part of the string
					$authorvalue =~ s/^mailto://;
					
					# Generate the table data
					$content = "$content
					<table>
						<td>
							<a href='mailto:$authorvalue'><img height=24 width=24 src=$resourcedir/bitmaps/links/mail.png></a>
						</td>
						<td>
							<div valign=top><a href='mailto:$authorvalue'><font color=#E8B13F>$authorvalue</font></div></a>
						</td>
					</table>";
				}
			}
			
			# Close the table row
			$content = "$content
				</td>
			</tr>";
		}
	}
	# Finish the html for the creditsbox
	$content = "$content
		</table>
	</body>
</html>";
	
	# Make a htmlwindow
	$credits->{$name} = Wx::HtmlWindow->new($page, -1, wxDefaultPosition, wxDefaultSize, wxHW_DEFAULT_STYLE);
	
	# Connect the htmlwindow to the html link event
	EVT_HTML_LINK_CLICKED($credits->{$name},$credits->{$name}, \&about_link);
	
	# Set the colors of the htmlwindow
	$credits->{$name}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$credits->{$name}->SetForegroundColour(Wx::Colour->new("#222222"));
	
	# Set the content for the creditsbox
	$credits->{$name}->SetPage($content);
	
	# Add the textcontrol to the sizer
	$grid->Add($credits->{$name}, 0, wxALL|wxEXPAND, 0);
	
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
	$license->{dialog} = Wx::Dialog->new($about, -1, "License");
	
	# Set the colors of the dialog
	$license->{dialog}->SetBackgroundColour(Wx::Colour->new("#222222"));
	
	# Make a scrolledwindow
	$license->{panel} = Wx::Panel->new($license->{dialog}, -1);
	
	# Set the colors of the dialog
	$license->{panel}->SetBackgroundColour(Wx::Colour->new("#222222"));
	$license->{dialog}->SetForegroundColour(Wx::Colour->new("#222222"));
	
	# Make a flexgrid sizer with 1 column and 2 rows (works better for this purpose)
	$license->{vertical} = Wx::BoxSizer->new(wxVERTICAL);
	
	# Make a gridsizer for the scrolledwindow to contain the label
	$license->{scrollgrid} = Wx::GridSizer->new(1,1,0,0);
	
	# Make label to with the license text (so much text!)
	$license->{text} = Wx::HtmlWindow->new($license->{panel}, -1, wxDefaultPosition, wxDefaultSize, wxHW_DEFAULT_STYLE);
	$license->{text}->SetPage("<html>
	<body bgcolor=#222222>
		<center><table>
			<tr>
				<td>
					<center><font color=#E8B13F size=+1>GNU GENERAL PUBLIC LICENSE</font></center>
				</td>
			</tr>
			<tr>
				<td>
					<center><font color=#E8B13F size=+1>Version 2, June 1991</font></center>
				</td>
			</tr>
			<tr>
				<td>
					<center><font size=-1 color=#B8B8B8>Copyright (C) 1989, 1991 Free Software Foundation, Inc.
<br>
59 Temple Place, Suite 330, Boston, MA02111-1307USA
<br>
Everyone is permitted to copy and distribute verbatim copies
<br>
of this license document, but changing it is not allowed.
<br>

<br>
Preamble
<br>

<br>
The licenses for most software are designed to take away your
<br>
freedom to share and change it.By contrast, the GNU General Public
<br>
License is intended to guarantee your freedom to share and change free
<br>
software--to make sure the software is free for all its users.This
<br>
General Public License applies to most of the Free Software
<br>
Foundation's software and to any other program whose authors commit to
<br>
using it.(Some other Free Software Foundation software is covered by
<br>
the GNU Library General Public License instead.)You can apply it to
<br>
your programs, too.
<br>

<br>
When we speak of free software, we are referring to freedom, not
<br>
price.Our General Public Licenses are designed to make sure that you
<br>
have the freedom to distribute copies of free software (and charge for
<br>
this service if you wish), that you receive source code or can get it
<br>
if you want it, that you can change the software or use pieces of it
<br>
in new free programs; and that you know you can do these things.
<br>

<br>
To protect your rights, we need to make restrictions that forbid
<br>
anyone to deny you these rights or to ask you to surrender the rights.
<br>
These restrictions translate to certain responsibilities for you if you
<br>
distribute copies of the software, or if you modify it.
<br>

<br>
For example, if you distribute copies of such a program, whether
<br>
gratis or for a fee, you must give the recipients all the rights that
<br>
you have.You must make sure that they, too, receive or can get the
<br>
source code.And you must show them these terms so they know their
<br>
rights.
<br>

<br>
We protect your rights with two steps: (1) copyright the software, and
<br>
(2) offer you this license which gives you legal permission to copy,
<br>
distribute and/or modify the software.
<br>

<br>
Also, for each author's protection and ours, we want to make certain
<br>
that everyone understands that there is no warranty for this free
<br>
software.If the software is modified by someone else and passed on, we
<br>
want its recipients to know that what they have is not the original, so
<br>
that any problems introduced by others will not reflect on the original
<br>
authors' reputations.
<br>

<br>
Finally, any free program is threatened constantly by software
<br>
patents.We wish to avoid the danger that redistributors of a free
<br>
program will individually obtain patent licenses, in effect making the
<br>
program proprietary.To prevent this, we have made it clear that any
<br>
patent must be licensed for everyone's free use or not licensed at all.
<br>

<br>
The precise terms and conditions for copying, distribution and
<br>
modification follow.
<br>

<br>
GNU GENERAL PUBLIC LICENSE
<br>
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
<br>

<br>
0. This License applies to any program or other work which contains
<br>
a notice placed by the copyright holder saying it may be distributed
<br>
under the terms of this General Public License.The \"Program\", below,
<br>
refers to any such program or work, and a \"work based on the Program\"
<br>
means either the Program or any derivative work under copyright law:
<br>
that is to say, a work containing the Program or a portion of it,
<br>
either verbatim or with modifications and/or translated into another
<br>
language.(Hereinafter, translation is included without limitation in
<br>
the term \"modification\".)Each licensee is addressed as \"you\".
<br>

<br>
Activities other than copying, distribution and modification are not
<br>
covered by this License; they are outside its scope.The act of
<br>
running the Program is not restricted, and the output from the Program
<br>
is covered only if its contents constitute a work based on the
<br>
Program (independent of having been made by running the Program).
<br>
Whether that is true depends on what the Program does.
<br>

<br>
1. You may copy and distribute verbatim copies of the Program's
<br>
source code as you receive it, in any medium, provided that you
<br>
conspicuously and appropriately publish on each copy an appropriate
<br>
copyright notice and disclaimer of warranty; keep intact all the
<br>
notices that refer to this License and to the absence of any warranty;
<br>
and give any other recipients of the Program a copy of this License
<br>
along with the Program.
<br>

<br>
You may charge a fee for the physical act of transferring a copy, and
<br>
you may at your option offer warranty protection in exchange for a fee.
<br>

<br>
2. You may modify your copy or copies of the Program or any portion
<br>
of it, thus forming a work based on the Program, and copy and
<br>
distribute such modifications or work under the terms of Section 1
<br>
above, provided that you also meet all of these conditions:
<br>

<br>
a) You must cause the modified files to carry prominent notices
<br>
stating that you changed the files and the date of any change.
<br>

<br>
b) You must cause any work that you distribute or publish, that in
<br>
whole or in part contains or is derived from the Program or any
<br>
part thereof, to be licensed as a whole at no charge to all third
<br>
parties under the terms of this License.
<br>

<br>
c) If the modified program normally reads commands interactively
<br>
when run, you must cause it, when started running for such
<br>
interactive use in the most ordinary way, to print or display an
<br>
announcement including an appropriate copyright notice and a
<br>
notice that there is no warranty (or else, saying that you provide
<br>
a warranty) and that users may redistribute the program under
<br>
these conditions, and telling the user how to view a copy of this
<br>
License.(Exception: if the Program itself is interactive but
<br>
does not normally print such an announcement, your work based on
<br>
the Program is not required to print an announcement.)
<br>

<br>
These requirements apply to the modified work as a whole.If
<br>
identifiable sections of that work are not derived from the Program,
<br>
and can be reasonably considered independent and separate works in
<br>
themselves, then this License, and its terms, do not apply to those
<br>
sections when you distribute them as separate works.But when you
<br>
distribute the same sections as part of a whole which is a work based
<br>
on the Program, the distribution of the whole must be on the terms of
<br>
this License, whose permissions for other licensees extend to the
<br>
entire whole, and thus to each and every part regardless of who wrote it.
<br>

<br>
Thus, it is not the intent of this section to claim rights or contest
<br>
your rights to work written entirely by you; rather, the intent is to
<br>
exercise the right to control the distribution of derivative or
<br>
collective works based on the Program.
<br>

<br>
In addition, mere aggregation of another work not based on the Program
<br>
with the Program (or with a work based on the Program) on a volume of
<br>
a storage or distribution medium does not bring the other work under
<br>
the scope of this License.
<br>

<br>
3. You may copy and distribute the Program (or a work based on it,
<br>
under Section 2) in object code or executable form under the terms of
<br>
Sections 1 and 2 above provided that you also do one of the following:
<br>

<br>
a) Accompany it with the complete corresponding machine-readable
<br>
source code, which must be distributed under the terms of Sections
<br>
1 and 2 above on a medium customarily used for software interchange; or,
<br>

<br>
b) Accompany it with a written offer, valid for at least three
<br>
years, to give any third party, for a charge no more than your
<br>
cost of physically performing source distribution, a complete
<br>
machine-readable copy of the corresponding source code, to be
<br>
distributed under the terms of Sections 1 and 2 above on a medium
<br>
customarily used for software interchange; or,
<br>

<br>
c) Accompany it with the information you received as to the offer
<br>
to distribute corresponding source code.(This alternative is
<br>
allowed only for noncommercial distribution and only if you
<br>
received the program in object code or executable form with such
<br>
an offer, in accord with Subsection b above.)
<br>

<br>
The source code for a work means the preferred form of the work for
<br>
making modifications to it.For an executable work, complete source
<br>
code means all the source code for all modules it contains, plus any
<br>
associated interface definition files, plus the scripts used to
<br>
control compilation and installation of the executable.However, as a
<br>
special exception, the source code distributed need not include
<br>
anything that is normally distributed (in either source or binary
<br>
form) with the major components (compiler, kernel, and so on) of the
<br>
operating system on which the executable runs, unless that component
<br>
itself accompanies the executable.
<br>

<br>
If distribution of executable or object code is made by offering
<br>
access to copy from a designated place, then offering equivalent
<br>
access to copy the source code from the same place counts as
<br>
distribution of the source code, even though third parties are not
<br>
compelled to copy the source along with the object code.
<br>

<br>
4. You may not copy, modify, sublicense, or distribute the Program
<br>
except as expressly provided under this License.Any attempt
<br>
otherwise to copy, modify, sublicense or distribute the Program is
<br>
void, and will automatically terminate your rights under this License.
<br>
However, parties who have received copies, or rights, from you under
<br>
this License will not have their licenses terminated so long as such
<br>
parties remain in full compliance.
<br>

<br>
5. You are not required to accept this License, since you have not
<br>
signed it.However, nothing else grants you permission to modify or
<br>
distribute the Program or its derivative works.These actions are
<br>
prohibited by law if you do not accept this License.Therefore, by
<br>
modifying or distributing the Program (or any work based on the
<br>
Program), you indicate your acceptance of this License to do so, and
<br>
all its terms and conditions for copying, distributing or modifying
<br>
the Program or works based on it.
<br>

<br>
6. Each time you redistribute the Program (or any work based on the
<br>
Program), the recipient automatically receives a license from the
<br>
original licensor to copy, distribute or modify the Program subject to
<br>
these terms and conditions.You may not impose any further
<br>
restrictions on the recipients' exercise of the rights granted herein.
<br>
You are not responsible for enforcing compliance by third parties to
<br>
this License.
<br>

<br>
7. If, as a consequence of a court judgment or allegation of patent
<br>
infringement or for any other reason (not limited to patent issues),
<br>
conditions are imposed on you (whether by court order, agreement or
<br>
otherwise) that contradict the conditions of this License, they do not
<br>
excuse you from the conditions of this License.If you cannot
<br>
distribute so as to satisfy simultaneously your obligations under this
<br>
License and any other pertinent obligations, then as a consequence you
<br>
may not distribute the Program at all.For example, if a patent
<br>
license would not permit royalty-free redistribution of the Program by
<br>
all those who receive copies directly or indirectly through you, then
<br>
the only way you could satisfy both it and this License would be to
<br>
refrain entirely from distribution of the Program.
<br>

<br>
If any portion of this section is held invalid or unenforceable under
<br>
any particular circumstance, the balance of the section is intended to
<br>
apply and the section as a whole is intended to apply in other
<br>
circumstances.
<br>

<br>
It is not the purpose of this section to induce you to infringe any
<br>
patents or other property right claims or to contest validity of any
<br>
such claims; this section has the sole purpose of protecting the
<br>
integrity of the free software distribution system, which is
<br>
implemented by public license practices.Many people have made
<br>
generous contributions to the wide range of software distributed
<br>
through that system in reliance on consistent application of that
<br>
system; it is up to the author/donor to decide if he or she is willing
<br>
to distribute software through any other system and a licensee cannot
<br>
impose that choice.
<br>

<br>
This section is intended to make thoroughly clear what is believed to
<br>
be a consequence of the rest of this License.
<br>

<br>
8. If the distribution and/or use of the Program is restricted in
<br>
certain countries either by patents or by copyrighted interfaces, the
<br>
original copyright holder who places the Program under this License
<br>
may add an explicit geographical distribution limitation excluding
<br>
those countries, so that distribution is permitted only in or among
<br>
countries not thus excluded.In such case, this License incorporates
<br>
the limitation as if written in the body of this License.
<br>

<br>
9. The Free Software Foundation may publish revised and/or new versions
<br>
of the General Public License from time to time.Such new versions will
<br>
be similar in spirit to the present version, but may differ in detail to
<br>
address new problems or concerns.
<br>

<br>
Each version is given a distinguishing version number.If the Program
<br>
specifies a version number of this License which applies to it and \"any
<br>
later version\", you have the option of following the terms and conditions
<br>
either of that version or of any later version published by the Free
<br>
Software Foundation.If the Program does not specify a version number of
<br>
this License, you may choose any version ever published by the Free Software
<br>
Foundation.
<br>

<br>
10. If you wish to incorporate parts of the Program into other free
<br>
programs whose distribution conditions are different, write to the author
<br>
to ask for permission.For software which is copyrighted by the Free
<br>
Software Foundation, write to the Free Software Foundation; we sometimes
<br>
make exceptions for this.Our decision will be guided by the two goals
<br>
of preserving the free status of all derivatives of our free software and
<br>
of promoting the sharing and reuse of software generally.
<br>

<br>
NO WARRANTY
<br>

<br>
11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
<br>
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.EXCEPT WHEN
<br>
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
<br>
PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
<br>
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
<br>
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.THE ENTIRE RISK AS
<br>
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.SHOULD THE
<br>
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
<br>
REPAIR OR CORRECTION.
<br>

<br>
12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
<br>
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
<br>
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
<br>
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
<br>
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
<br>
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
<br>
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
<br>
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
<br>
POSSIBILITY OF SUCH DAMAGES.
<br>

<br>
END OF TERMS AND CONDITIONS</font></center>
				</td>
			</tr>
		</table></center>
	</body>
</html>");	
	#$license->{close} = Wx::Button->new($license->{dialog}, -1, "Close");
	#EVT_BUTTON($license->{close}, -1, \&about_close);
	
	# Add everything to the sizer
	$license->{scrollgrid}->Add($license->{text}, 1, wxALL|wxEXPAND, 0);
	$license->{panel}->SetSizer($license->{scrollgrid});
	$license->{vertical}->Add($license->{panel}, 1, wxALL|wxEXPAND, 5);
	# Make a close button and connect it to an event
	make_bitmapbutton($license,$license->{dialog}, $license->{vertical},"about_close", "close");
	#$license->{vertical}->Add($license->{about_close}, 0, wxALL|wxALIGN_RIGHT, 5);
	$license->{dialog}->SetSizer($license->{vertical});
	
	# Set size of the dialog
	$license->{dialog}->SetSize(600,465);
	$license->{dialog}->SetMinSize($license->{dialog}->GetSize());
	$license->{dialog}->SetMaxSize($license->{dialog}->GetSize());
	
	# Show the dialog
	$license->{dialog}->Show();
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
	# Get the version number
	my $version = rsu::info::getVersion();
	
	# Return the result
	return $version;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub playoldschool
{
	# If we are not on windows
	if ($OS =~ /MSWin32/)
	{
		# Run the runescape executable
		system (1,"\"$cwd/rsu/rsu-query.exe\" client.launch.runescape --prmfile=oldschool.prm");
	}
	# If we are on Mac OSX
	elsif ($OS =~ /darwin/)
	{
		# Run the runescape oldschool call
		system "DYLD_LIBRARY_PATH=$cwd/rsu/3rdParty/darwin \"$cwd/rsu/bin/rsu-query-darwin\" client.launch.runescape --prmfile=oldschool.prm &";
	}
	# Else
	else
	{
		# Run the runescape script
		system "\"$cwd/rsu/rsu-query\" client.launch.runescape --prmfile=oldschool.prm --unixquery &";
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub playnow
{
	# Get the passed data
	my ($self, $event) = @_;
	
	# Get the prmfile that is selected	
	my $selectedPrm = rsu::files::IO::readconf("prmfile", "runescape.prm", "settings.conf");
	
	# If we are not on windows
	if ($OS =~ /MSWin32/)
	{
		# Run the runescape executable
		system (1,"\"$cwd/rsu/rsu-query.exe\" client.launch.runescape --prmfile=$selectedPrm");
	}
	# If we are on Mac OSX
	elsif ($OS =~ /darwin/)
	{
		# Run the runescape api call
		system "DYLD_LIBRARY_PATH=$cwd/rsu/3rdParty/darwin \"$cwd/rsu/bin/rsu-query-darwin\" client.launch.runescape --prmfile=$selectedPrm &";
	}
	# Else
	else
	{
		# Run the runescape script
		system "\"$cwd/rsu/rsu-query\" client.launch.runescape --prmfile=$selectedPrm --unixquery &";
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
		# Run the runescape executable
		system (1, "\"$cwd/rsu/rsu-query.exe\" client.launch.updater");
	}
	# Else if we are on Mac OSX
	elsif ($OS =~ /darwin/)
	{
		# Run the updater api call
		system "DYLD_LIBRARY_PATH=$cwd/rsu/3rdParty/darwin \"$cwd/rsu/bin/rsu-query-darwin\" client.launch.updater &";
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
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Run the settings api call
		system (1,"\"$cwd/rsu/rsu-query.exe\" client.launch.settings");
	}
	# If we are on Mac OSX
	elsif ($OS =~ /darwin/)
	{
		# Run the settings api call
		system "DYLD_LIBRARY_PATH=$cwd/rsu/3rdParty/darwin \"$cwd/rsu/bin/rsu-query-darwin\" client.launch.settings &";
	}
	# Else
	else
	{
		# Run the settings api call
		system "\"$cwd/rsu/rsu-query\" client.launch.settings &";
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

# Method by ivanpu to make the numbers more readable
sub commify {
	# Get the passed data
	local $_  = shift;
	
	# Make higher values easier to read by adding commas
	1 while s/^(-?\d+)(\d{3})/$1,$2/;
	
	# Return the improved number
	return $_;
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
	Wx::LaunchDefaultBrowser("http://services.runescape.com/m=forum/forums.ws?25,26,5,65329684,goto,99999");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub addon_handler
{
	# Get the passed data
	my ($self, $event) = @_;
	
	# Get the name of the addon that triggered the event
	my $addon_id = $event->GetLinkInfo()->GetHref();
	
	# Make a variable which will contain only the unique id and not the universal:// or $OS:// identifier
	my $addon = $addon_id;
	
	# Check if this is the addonsdir link
	if ($addon =~ /^open:\/\/addonsdir/)
	{
		# Open the addons directory
		open_addonsdir($self);
	}
	# Else if the refresh link
	elsif ($addon =~ /^refresh:\/\/addons/)
	{
		# Refresh the list of addons
		load_addons($self);
	}
	# Else if the delete addon link is clicked
	elsif ($addon =~ /^delete:\/\//)
	{
		# Remove delete:// from begining of addon call
		$addon =~ s/^delete:\/\/(universal|$OS):\/\///;
		
		# Ask if they are sure they want to delete the addon
		my $answer = Wx::MessageBox("Do you want to remove the addon \"$addon\"?", 'Addon removal!', wxYES_NO, $self);
		
		# If they say yes
		if ($answer == wxYES)
		{
			# Display a console message
			print "User requested to delete $addon\n";
			
			# If this is an universal addon
			if ($addon_id =~ /^delete:\/\/universal:\/\//)
			{
				# Tell what is happening
				print "ID clicked was: $addon_id\nRemoving directory: \"$clientdir/share/addons/universal/$addon\"\n";
				
				# Delete the universal addon
				remove_tree("$clientdir/share/addons/universal/$addon");
			}
			# Else
			else
			{
				# Tell what is happening
				print "ID clicked was: $addon_id\nRemoving directory: \"$clientdir/share/addons/$OS/$addon\"\n";
				
				# Delete the platform specific addon
				remove_tree("$clientdir/share/addons/$OS/$addon");
			}
			
			# Tell what is happening
			print "Refreshing the list of addons!\n\n";
			
			# Refresh the list of addons
			load_addons($self);
		}
	}
	# Else
	else
	{
		# Remove the identifier from the variable $addon
		$addon  =~ s/^(universal|$OS):\/\///;
		
		# If the addon_id starts with universal_
		if ($addon_id =~ /^universal:\/\//)
		{
			# If we are on windows
			if ($OS =~ /MSWin32/)
			{
				# Launch the universal addon
				system (1,"\"$cwd/rsu/rsu-query.exe\" addon.universal.launch $addon &");
			}
			# Else if we are on Mac OSX
			elsif ($OS =~ /darwin/)
			{
				# Launch the universal addon
				system "DYLD_LIBRARY_PATH=$cwd/rsu/3rdParty/darwin \"$cwd/rsu/bin/rsu-query-darwin\" addon.universal.launch $addon &";
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
				system (1,"\"$cwd/rsu/rsu-query.exe\" addon.platform.launch $addon &");
			}
			# Else if we are on Mac OSX
			elsif ($OS =~ /darwin/)
			{
				# Launch the platform specific addon
				system "DYLD_LIBRARY_PATH=$cwd/rsu/3rdParty/darwin \"$cwd/rsu/bin/rsu-query-darwin\" addon.platform.launch $addon &";
			}
			# Else
			else
			{
				# Launch the platform specific addon
				system "\"$cwd/rsu/rsu-query\" addon.platform.launch $addon &";
			}
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

sub loadprms
{
	# Get the pointers
	my ($self) = @_;
	
	# Get a list of all the prm files and put them in an array
	my @prmlist = rsu::files::dirs::list("$clientdir/share/prms");
	
	# Sort the prmlist in decending order (makes runescape appear at top)
	@prmlist = sort {$b cmp $a} @prmlist;
	
	# For each value in the array
	foreach my $prmfilefound(@prmlist)
	{
		# Next if filename starts with .
		next if $prmfilefound =~ /^\./;
		# Next if filename is runescape.prm, oldschool.prm or runescape-beta.prm
		#next if $prmfilefound =~ /^(runescape|oldschool|runescape-beta)\.prm$/;
		# Next if filename ends with .example
		#next if $prmfilefound =~ /\.example$/;
                # Next if filenname does not end with .prm
                next if $prmfilefound !~ /\.prm$/;
		
		# Append the file to the choice
		$self->{prmSelect}->Append("$prmfilefound");
	}

	# Set the selected prm to what the user used last
        $self->{prmSelect}->SetSelection($self->{prmSelect}->FindString(rsu::files::IO::readconf("prmfile", "runescape.prm", "settings.conf")));
        if ($self->{prmSelect}->GetSelection() == wxNOT_FOUND)
        {
            $self->{prmSelect}->SetSelection(0);
        }
}

#
#---------------------------------------- *** ----------------------------------------
#

### Events

sub close_clicked
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Close the mainwindow
	$self->GetParent()->GetParent()->GetParent()->GetParent()->Destroy();
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_tooltips
{
	my ($self) = @_;
		
	# Set tooltips with info about the settings
	# $self->objectname->SetToolTip("message");
	
	$self->{prmSelect}->SetToolTip("Use this to select what profile to use");
	
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
