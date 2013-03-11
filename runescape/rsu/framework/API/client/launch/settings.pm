package client::launch::settings;

# Be strict to avoid messy code
use strict;

# Use FindBin module to get script directory
use FindBin;

# Use the Cwd module to translate relative paths and symlinks to the real path
use Cwd;

# Get script directory
my $scriptdir = $FindBin::RealBin;

# Get the current working directory
my $cwd = getcwd;

# Use the file IO module
use rsu::files::IO;

# Tell if this is the settings editor that i sent to jagex or
# used in the the RSU client (the difference is that 0 makes it read
# the official clients parameter files)
my $RSU = 1;

# If we are not in RSU mode
if ($RSU =~ /0/)
{
	# $cwd is the same as $scriptdir
	$cwd = $scriptdir;
}

# Get the resources directory
my $resourcedir = "$cwd/rsu/framework/resources/client/launch/settings";

# Name of our xrc gui resource file
my $xrc_gui_file = "rsu-settings_gui.xrc";

# Autoflush outputs from terminal/cmd
$|=1;

# Get script filename
my $scriptname = $FindBin::Script;
# Detect the current OS
my $OS = "$^O";

# Make a variable to contain the client directory
my $clientdir = "$cwd";

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

# If this script have been installed systemwide
if ($cwd =~ /^(\/usr\/s?bin|\/opt\/|\/usr\/local\/s?bin)/)
{	
	# Change $clientdir to ~/.config/runescape
	$clientdir = "$HOME/.config/runescape/";
		
	# Make the client folders
	system "mkdir -p \"$HOME/.config/runescape/bin\" && mkdir -p \"$HOME/.config/runescape/share\"";
}

# Read from the config file if the user want to run in compabilitymode/wine,
# if nothing is found then dont use it
my $compabilitymode = rsu::files::IO::readconf("compabilitymode", "False", "settings.conf", "$clientdir/share");

# Read the preferred java in the config file, if nothing is found then use default-java
my $preferredjava = rsu::files::IO::readconf("preferredjava", "default-java", "settings.conf", "$clientdir/share");

# If we are running on windows then
if ($OS =~ /MSWin32/)
{
	$preferredjava = rsu::files::IO::readconf("win32java.exe", "default-java", "settings.conf", "$clientdir/share");
}

# Read from the config file if the user want to force the client to use pulseaudio
# if nothing then dont use it (incase a system does not have pulseaudio/padsp installed)
my $forcepulseaudio = rsu::files::IO::readconf("forcepulseaudio", "False", "settings.conf", "$clientdir/share");

# Read from the config file if the user want to tell java to use alsa in the base for sounds
# If nothing is found then do not use alsa and instead use the java default
my $forcealsa = rsu::files::IO::readconf("forcealsa", "False", "settings.conf", "$clientdir/share");

# Read from the config file, the name of the prm file to use
my $prmfile = rsu::files::IO::readconf("prmfile", "runescape.prm", "settings.conf", "$clientdir/share");

# Read from the config file if the user have told the script to use primusrun or not if it is available
my $useprimusrun = rsu::files::IO::readconf("useprimusrun", "false", "settings.conf", "$clientdir/share");

# Define a text inside the script for use
my $plist_template = << "plist_template";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>RuneScape</string>
	<key>CFBundleIdentifier</key>
	<string>com.jagex.jagexappletviewer</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>CFBundleAllowMixedLocalizations</key>
	<string>true</string>
	<key>CFBundleExecutable</key>
	<string>JavaApplicationStub</string>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleIconFile</key>
	<string>RuneScape.icns</string>
	<key>Java</key>
	<dict>
		<key>Arguments</key>
		<string>\$JAVAROOT/</string>
		<key>MainClass</key>
		<string>jagexappletviewer</string>
		<key>JVMVersion</key>
		<string>1.5+</string>
		<key>ClassPath</key>
		<string>\$JAVAROOT/jagexappletviewer.jar</string>
		<key>Properties</key>
		<dict>
			<key>com.jagex.config</key>
			<string>\$configurl</string>
		</dict>
		<key>VMOptions.ppc</key>
		<string>\$prms</string>
		<key>VMOptions.i386</key>
		<string>\$prms</string>
		<key>VMOptions.x86_64</key>
		<string>\$prms</string>
	</dict>
</dict>
</plist>
plist_template

package wxTopLevelFrame;

use Wx qw[:everything];
use Wx::XRC;
use Wx::Event qw(EVT_BUTTON EVT_CHOICE EVT_NOTEBOOK_PAGE_CHANGED EVT_CHECKBOX);

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
	
	# Create mutators for widgets
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
	
	loadsettings($self);
	
	loadconfig($self);
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



sub set_events
{
	# Get the pointers
	my $self = shift;
	
	# Setup the events
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('save'), \&save_clicked);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('close'), \&close_clicked);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('close2'), \&close_clicked);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('saveconf'), \&saveconf_clicked);
	EVT_CHOICE($self, Wx::XmlResource::GetXRCID('preferredjava'), \&preferredjava_changed);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('clear_main'), \&delete_maincache);
	EVT_BUTTON($self, Wx::XmlResource::GetXRCID('clear_beta'), \&delete_betacache);
	EVT_NOTEBOOK_PAGE_CHANGED($self, Wx::XmlResource::GetXRCID('tab_box1'), \&tab_box1_changepage);
	
	# Find the widgets
	$self->{classpath} = $self->FindWindow('classpath');
	$self->{Xms} = $self->FindWindow('Xms');
	$self->{Xmx} = $self->FindWindow('Xmx');
	$self->{Xss} = $self->FindWindow('Xss');
	$self->{configurl} = $self->FindWindow('configurl');
	$self->{prms} = $self->FindWindow('prms');
	$self->{configfilepath} = $self->FindWindow('configfilepath');
	$self->{clear_main} = $self->FindWindow('clear_main');
	$self->{clear_beta} = $self->FindWindow('clear_beta');
	$self->{terminal_output} = $self->FindWindow('terminal_output');
	$self->{prmFile} = $self->FindWindow('prmFile');
	$self->{close2} = $self->FindWindow('close2');
	$self->{preferredjava} = $self->FindWindow('preferredjava');
	$self->{saveconf} = $self->FindWindow('saveconf');
	$self->{customjava} = $self->FindWindow('customjava');
	$self->{soundsystem} = $self->FindWindow('soundsystem');
	$self->{winemode} = $self->FindWindow('winemode');
	$self->{tab_box1} = $self->FindWindow('tab_box1');
	$self->{primusmode} = $self->FindWindow('primusmode');
	
	# If we are on linux, darwin/mac or windows (which supports addons)
	#if ($OS =~ /(linux|darwin|MSWin32)/)
	#{
		## Check whats is inside the modules folder
		#opendir(my $modulefolders, "$clientdir/modules") || die "Incomplete client structure! You must reinstall the rsu-client!";
		
		## While there is still content inside the folder
		#while (readdir $modulefolders)
		#{
			## If the current content is the addons folder
			#if ($_ =~ /^addons$/ && -d "$clientdir/modules/$_")
			#{
				## Add the addons/module page
				#addmodulepage($self);
			#}
		#}
		
		## Close the directory to free up memory
		#closedir($modulefolders);
	#}
	
	# Set default size
	$self->SetSize(510,520);
	
	# If we are on Mac OSX use 500x600 instead due to widget borders being thicker
	if ($OS =~ /darwin/)
	{
		# Set default size
		$self->SetSize(510,600);
	}
	
	# Make sure the window cannot be resized
	$self->SetMinSize($self->GetSize);
	$self->SetMaxSize($self->GetSize);

	# Set scrollbar properties on these widgets
	setScrollBars(
			$self->FindWindow('scriptwindow'),
			$self->FindWindow('rswindow'),
			$self->FindWindow('cachewindow'),
	);
	
	# If RSU mode is disabled
	if ($RSU =~ /0/)
	{
		# Change to the RS Settings page
		$self->{tab_box1}->ChangeSelection(1);
		# Remove the script settings page
		$self->{tab_box1}->RemovePage(0);
		# The $prmfile is always runescape.prm
		$prmfile = "runescape.prm";
		# $clientdir is always $HOME/.config/runescape
		$clientdir = "$HOME/.config/runescape";
	}
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub addmodulepage
{
	my $self = shift;
	
	# Make a module page manually
	$self->{modulepage} = Wx::ScrolledWindow->new($self->{tab_box1}, -1, wxDefaultPosition, wxDefaultSize, );
	$self->{tab_box1}->AddPage($self->{modulepage}, "Add-Ons");
	$self->{modulehorizontal} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{modulehorizontal}->Add(20,20,0,0);
	$self->{modulevertical} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{addonlist} = Wx::GridSizer->new(1,2,5,5);
	$self->{labeltop} = Wx::StaticText->new($self->{modulepage}, -1, "\nSelect the addons you want to start with RuneScape!\nSelect only addons you trust!\n", wxDefaultPosition, wxDefaultSize,);
	
	# Make a button to open the addons dir and make it run the function open_addonsdir when clicked
	$self->{addonsdirbutton} = Wx::Button->new($self->{modulepage}, -1, "Open Addons Folder (place extracted addons here)", wxDefaultPosition, wxDefaultSize, );
	EVT_BUTTON($self, $self->{addonsdirbutton}, \&open_addonsdir);
	
	# Add stuff to the sizers
	$self->{modulehorizontal}->Add($self->{modulevertical}, 1, wxEXPAND, 0);
	$self->{modulevertical}->Add($self->{labeltop},0,wxEXPAND|wxALL,0);
	$self->{modulevertical}->Add($self->{addonsdirbutton},0,wxEXPAND|wxALL,0);
	$self->{modulevertical}->Add(20,20,0,0);
	$self->{modulevertical}->Add($self->{addonlist},0,wxEXPAND|wxALL,0);
	$self->{modulehorizontal}->Add(20,20,0,0);
	
	# Open the addons directory
	opendir(my $addons, "$clientdir/modules/addons/");
	
	# While there is still contents in the directory
	while (readdir $addons)
	{
		# If the current content is either named universal or the same as $OS
		if (($_ =~ /^universal$/ && -d "$clientdir/modules/addons/$_") || ($_ =~ /^$OS$/ && -d "$clientdir/modules/addons/$_"))
		{
			# Display addons from the detected addons directory
			displayaddons($self,"$clientdir/modules/addons/$_");
		}
	}
	
	# Close the addons directory to free memory
	closedir($addons);
	
	# Make sure the layout is displayed properly
	$self->{modulepage}->SetSizer($self->{modulehorizontal});
	$self->{modulehorizontal}->Fit($self);
	$self->Layout();
	
	# Add scrollbars if neccessary
	setScrollBars($self->{modulepage});
}

#
#---------------------------------------- *** ----------------------------------------
#

sub displayaddons
{	
	my ($self, $addonsdir) = @_;
	
	# Read the addon list
	my $addonconfig = rsu::files::IO::ReadFile($clientdir."/share/addons.conf");
	
	# Make a counter to know when we need to increase the amount of rows in the grid
	my $counter = 1;
	
	# Open the addons directory
	opendir(my $addons_handle, $addonsdir);
	
	# While there is still content in the addons directory
	while (readdir $addons_handle)
	{
		# Go to next if the current content is a relative directory (. or ..) or if the folder is named framework
		next if $_ =~ /^(\.|\.\.|framework)$/;
		
		# Move the current folder to a variable so we can reuse it several times (as $_ gets overwritten during this while loop)
		my $addon = $_;
		
		# If the addon name is a directory
		if (-d "$addonsdir/$addon")
		{
			# If file does not exist
			if ($addonconfig =~ /error reading file/)
			{
				# If $counter modulus 2 is 0 (translation: every 2nd)
				if ($counter %= 2)
				{
					# Increase the gridsizers rows by 1
					$self->{addonlist}->SetRows($self->{addonlist}->GetRows()+1);
				}
				
				# Make a checkbox
				$self->{$addon} = Wx::CheckBox->new($self->{modulepage}, -1, "$_", wxDefaultPosition, wxDefaultSize, );
				EVT_CHECKBOX($self, -1, \&change_addonstatus);
				
				# Add addon to addons.conf but disable it
				rsu::files::IO::WriteFile("$addon=disable", ">>", $clientdir."/share/addons.conf");
				
				# Set checkbox to unchecked
				$self->{$addon}->SetValue(0);
				
				# Add checkbox to vertical sizer
				$self->{addonlist}->Add($self->{$addon}, 0, wxEXPAND,0);
			}
			# Else
			else
			{
				# If $counter modulus 2 is 0
				if ($counter %= 2)
				{
					# Increase the gridsizers rows by 1
					$self->{addonlist}->SetRows($self->{addonlist}->GetRows()+1);
				}
				
				# Get the status of the addon
				my $addonstatus = rsu::files::IO::readconf("$addon", "undef", "addons.conf", "$clientdir");
				
				# If addon is enabled
				if ("@$addonconfig" =~ /$addon=enable/i)
				{
					# Make a checkbox
					$self->{$addon} = Wx::CheckBox->new($self->{modulepage}, -1, "$addon", wxDefaultPosition, wxDefaultSize, );
					EVT_CHECKBOX($self, -1, \&change_addonstatus);
					
					# Set checkbox to checked
					$self->{$addon}->SetValue(1);
					
					# Add checkbox to vertical sizer
					$self->{addonlist}->Add($self->{$addon}, 1, wxEXPAND,0);
				}
				# Else if addon status is undef(undefined)
				elsif("@$addonconfig" =~ /undef/)
				{
					# Add addon to addons.conf but disable it
					rsu::files::IO::WriteFile("$addon=disable", ">>", $clientdir."/share/addons.conf");
					EVT_CHECKBOX($self, -1, \&change_addonstatus);
					
					# Make a checkbox
					$self->{$addon} = Wx::CheckBox->new($self->{modulepage}, -1, "$addon", wxDefaultPosition, wxDefaultSize, );
					
					# Set checkbox to checked
					$self->{$addon}->SetValue(0);
					
					# Add checkbox to vertical sizer
					$self->{addonlist}->Add($self->{$addon}, 1, wxEXPAND,0);
				}
				else
				{
					# Make a checkbox
					$self->{$addon} = Wx::CheckBox->new($self->{modulepage}, -1, "$addon", wxDefaultPosition, wxDefaultSize, );
					EVT_CHECKBOX($self, -1, \&change_addonstatus);
					
					# Set checkbox to checked
					$self->{$addon}->SetValue(0);
					
					# Add checkbox to vertical sizer
					$self->{addonlist}->Add($self->{$addon}, 1, wxEXPAND,0);
				}
			}
			
			# Increase counter by 1
			$counter += 1;
		}
	}
	
	# Close the addons directory to free memory
	closedir($addons_handle);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub open_addonsdir
{
	# Get the pointers
	my ($self,$event) = @_;
	
	# Put the path to the addons directory into a variable
	my $addonsdir = "$clientdir/modules/addons";
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Replace all / with \
		$addonsdir =~ s/\//\\/g;
		
		# Open the addons directory
		system (1,"explorer.exe \"addonsdir\"");
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

#
#---------------------------------------- *** ----------------------------------------
#

sub change_addonstatus
{
	# Get pointers
	my ($self, $event) = @_;
	
	# Get the name of the addon that triggered the event
	my $addon = $event->GetEventObject()->GetLabel();
	
	# Get the status of the addon
	my $addonstatus = rsu::files::IO::readconf("$addon", "undef", "addons.conf", "$clientdir");
	
	# If status is enabled
	if ($addonstatus =~ /enable/i)
	{
		# Read the addons.config
		my $addonsconfig = rsu::files::IO::ReadFile($clientdir."/share/addons.conf");
		
		# Transfer contents to a variable
		my $addonscontent = "@$addonsconfig";
		
		# Disable addon
		$addonscontent =~ s/$addon=enable/$addon=disable/;
		
		# Write changes back to addons.config
		rsu::files::IO::WriteFile($addonscontent, ">", $clientdir."/share/addons.conf");
	}
	# Else if status is undef
	elsif($addonstatus =~ /undef/)
	{
		# Write enable the addon in addons.config
		rsu::files::IO::WriteFile("$addon=enable", ">>", $clientdir."/share/addons.conf");
	}
	else
	{
		# Read the addons.config
		my $addonsconfig = rsu::files::IO::ReadFile($clientdir."/share/addons.conf");
		
		# Transfer contents to a variable
		my $addonscontent = "@$addonsconfig";
		
		# Disable addon
		$addonscontent =~ s/$addon=disable/$addon=enable/;
		
		# Write changes back to addons.config
		rsu::files::IO::WriteFile($addonscontent, ">", $clientdir."/share/addons.conf");
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
    my $pixelsPerUnitY = 10; 
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


sub save_clicked
{
	# Get pointers
	my $self = shift;
	my $event = shift;
	
	# Make a variable for the path to the settings file
	my $settingsfile;
		
	# If RSU mode is active
	if ($RSU =~ /1/)
	{
		# Get the prmfile from gui
		$settingsfile = $self->{configfilepath}->GetValue;
	}
	# Else
	else
	{
		# Use runescape.prm
		$prmfile = "runescape.prm";
		
		# Set the prm file to the $settingsfile variable
		$settingsfile = "$clientdir/share/$prmfile";
	}
	
	# If we are on windows
	if ($OS =~ /MSWin32/ && $RSU =~ /0/)
	{
		# Set the correct settings file path for the client
		$settingsfile = "$HOME/jagexcache/jagexlauncher/runescape/runescape.prm"
	}
	# Else if we are on darwin/MacOSX
	elsif($OS =~ /darwin/ && $RSU =~ /0/)
	{
		# Use the info.plist from the client in /Applications
		$settingsfile = "/Applications/RuneScape.app/Contents/Info.plist";
	}
	
	# If we are in RSU mode
	if ($RSU =~ /1/)
	{
		writeprmfile($self, $settingsfile);
	}
	# Else if we are not on darwin/MacOSX
	elsif ($OS !~ /(darwin)/)
	{
		writeprmfile($self, $settingsfile);
	}
	else
	{
		# Get the template
		my $template = $plist_template;
		
		# Get the values for all the settings
		my $configurl = $self->{configurl}->GetValue;
		my $Xms = $self->{Xms}->GetValue;
		my $Xss = $self->{Xss}->GetValue;
		my $Xmx = $self->{Xmx}->GetValue;
		my $prms = $self->{prms}->GetValue;
		
		# Add "m" behind Xms, Xss and Xmx
		$Xms = $Xms."m";
		$Xmx = $Xmx."m";
		$Xss = $Xss."m";
		
		# Replace all newlines in $prms with whitespace
		$prms =~ s/[\n\r]/\ /g;
		
		# Add the configurl
		$template =~ s/\$configurl/$configurl/;
		
		# If a minimum memory allocation is set (must be 3 or 4 digits)
		if ($self->{Xms}->GetValue =~ /\d{3,4}/)
		{
			# Add it to the template along with the other parameters
			$template =~ s/\$prms/-Xms$Xms -Xmx$Xmx -Xss$Xss $prms/g;
		}
		# Else
		else
		{
			# Add only the other parameters
			$template =~ s/\$prms/-Xmx$Xmx -Xss$Xss $prms/g;
		}
		
		# Write template to Info.plist
		rsu::files::IO::WriteFile("$template", ">", "$settingsfile");
	}
	
	
	# Display a messagebox to notify that the function is done
	Wx::MessageBox("Settings Saved!", "Settings Saved!", wxOK,$self);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub writeprmfile
{
	my ($self, $settingsfile) = @_;
	
	# Get the values from the gui
	my $Xms = $self->{Xms}->GetValue;
	my $Xss = $self->{Xss}->GetValue;
	my $Xmx = $self->{Xmx}->GetValue;
	
	# Add "m" behind Xms, Xss and Xmx
	$Xms = $Xms."m";
	$Xmx = $Xmx."m";
	$Xss = $Xss."m";
	
	# Write .prm file
	rsu::files::IO::WriteFile("-Djava.class.path=".$self->{classpath}->GetValue, ">", "$settingsfile");
	rsu::files::IO::WriteFile("-Dcom.jagex.config=".$self->{configurl}->GetValue, ">>", "$settingsfile");
	rsu::files::IO::WriteFile("-Xmx$Xmx", ">>", "$settingsfile");
	rsu::files::IO::WriteFile("-Xss$Xss", ">>", "$settingsfile");
	
	# If a minimum memory allocation is set (must be 3 or 4 digits)
	if ($self->{Xms}->GetValue =~ /\d{3,4}/)
	{
		# Write the minimum memory allocation prm
		rsu::files::IO::WriteFile("-Xms$Xms", ">>", "$settingsfile");
	}
	
	# Get misc parameters
	my $prm_content = $self->{prms}->GetValue;
	
	# Remove all newlines
	$prm_content =~ s/\ //g;
	
	# Split by newline
	my @prms = split /\r\n/, $prm_content;
	
	# For each value in the array
	foreach my $prm (@prms)
	{
		# Write the parameter to the .prm file
		rsu::files::IO::WriteFile("$prm", ">>", "$settingsfile");
	}
	
	# Write the client class to .prm file
	rsu::files::IO::WriteFile("jagexappletviewer", ">>", "$settingsfile");
}

#
#---------------------------------------- *** ----------------------------------------
#



sub loadconfig
{
	# Get the pointers
	my ($self) = @_;
	
	# Set the prmfile to the gui
	$self->{prmFile}->SetValue("$prmfile");
	
	# If forcealsa and forcepulse is enabled
	if ($forcealsa =~ /true|1/i && $forcepulseaudio =~ /true/i)
	{
		# Set the options in the gui
		$self->{soundsystem}->SetSelection(3);
	}
	# Else if only forcealsa is enabled
	elsif($forcealsa =~ /true|1/i && $forcepulseaudio =~ /false/i)
	{
		# Set the options in the gui
		$self->{soundsystem}->SetSelection(2);
	}
	# Else if only forcepulse is enabled
	elsif($forcepulseaudio =~ /true|1/i && $forcealsa =~ /false/i)
	{
		# Set the options in the gui
		$self->{soundsystem}->SetSelection(1);
	}
	# Else
	else
	{
		# Let java decide
		$self->{soundsystem}->SetSelection(0);
	}
	
	# If preferredjava starts with / or X:\ where X is a letter
	if ($preferredjava =~ /^(\/|[a-z]:)/i)
	{
		# Set the selection to custom-java
		$self->{preferredjava}->SetSelection(3);
		
		# Enable the filepicker
		$self->{customjava}->Enable(1);
		
		# Set the path to the customjava
		$self->{customjava}->SetPath("$preferredjava");
	}
	# Else if preferredjava is 6-openjdk
	elsif($preferredjava =~ /6-openjdk/)
	{
		# Set the selection to 6-openjdk
		$self->{preferredjava}->SetSelection(2);
	}
	# Else if preferredjava is 7-openjdk
	elsif($preferredjava =~ /7-openjdk/)
	{
		# Set the selection to 7-openjdk
		$self->{preferredjava}->SetSelection(1);
	}
	else
	{
		# Set the selection to default-java
		$self->{preferredjava}->SetSelection(0);
	}
	
	# If compabilitymode is enabled
	if ($compabilitymode =~ /true|1/i)
	{
		# Make the checkbox for compabilitymode checked
		$self->{winemode}->SetValue(1);
	}
	
	# If useprimusrun is enabled
	if ($useprimusrun =~ /true|1/i)
	{
		# Make the checkbox for primusmode checked
		$self->{primusmode}->SetValue(1);
	}
		
}

#
#---------------------------------------- *** ----------------------------------------
#

sub loadsettings
{
	# Get the pointers to the widgets
	my $self = shift;
	
	# Make a variable for the settingsfile (use the Cwd::abs_path function to show the direct path)
	my $settingsfile = Cwd::abs_path("$clientdir/share/$prmfile");
	
	# If we are on windows and not in RSU mode
	if ($OS =~ /MSWin32/ && $RSU =~ /0/)
	{
		## Location of the official prm file
		$settingsfile = "$HOME\\jagexcache\\jagexlauncher\\runescape\\runescape.prm";
	}
	# Else if we are on darwin/MacOSX and not in RSU mode
	elsif($OS =~ /darwin/ && $RSU =~ /0/)
	{
		## Location of the official parameter file
		$settingsfile = "/Applications/RuneScape.app/Contents/Info.plist";
	}
	
	# Show the user what file we are changing
	$self->{configfilepath}->SetValue($settingsfile);
	
	# Read the settings file
	my $contents = rsu::files::IO::ReadFile($settingsfile);
	
	# If we are not on darwin/MacOSX
	if (($OS !~ /(darwin)/ && $contents !~ /error reading file/) || ($RSU =~ /1/ && $contents !~ /error reading file/))
	{
		# Empty the prms list
		$self->{prms}->ChangeValue("");
		
		# Parse the prm file
		parse_prm("@$contents", $self);
	}
	# Else if we did not fail opening the file
	elsif($contents !~ /error reading file/ && $RSU =~ /0/)
	{
		# Parse the plist/xml
		parse_plist("@$contents", $self);
	}
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub parse_prm
{
	my ($contents, $self) = @_;
		
	# Get rid of pesky whitespaces
	$contents =~ s/\ //g;
	$contents =~ s/[\r\n]/¤/g;
	
	# Split the string by ¤
	my @parameters = split /¤/, $contents;
	
	# For each value in the array
	foreach my $prm(@parameters)
	{
		# If $prm is -Xmx then
		if ($prm =~ /^-Xmx/)
		{
			# Add $prm to a new variable we can play with
			my $xmx = $prm;
			# Remove all letters and dashes
			$xmx =~ s/[a-z\-]//ig;
			# Set the value in the gui
			$self->{Xmx}->SetValue($xmx);
		}
		# Else if $prm is -Xms then
		elsif($prm =~ /^-Xms/)
		{
			# Add $prm to a new variable we can play with
			my $xms = $prm;
			# Remove all letters and dashes
			$xms =~ s/[a-z\-]//ig;
			# Set the value in the gui
			$self->{Xms}->SetValue($xms);
		}
		# Else if $prm contains jagexappletviewer then
		elsif($prm =~ /jagexappletviewer/i)
		{
			# Do nothing
		}
		# Else if $prm is -Xss then
		elsif($prm =~ /^-Xss/)
		{
			# Add $prm to a new variable we can play with
			my $xss = $prm;
			# Remove all letters and dashes
			$xss =~ s/[a-z\-]//ig;
			# Set the value in the gui
			$self->{Xss}->SetValue($xss);
		}
		
		# Else if $prm is the com.jagex.config url then
		elsif($prm =~ /^-Dcom\.jagex\.config=/)
		{
			# Split by config=
			my @configurl = split /config=/, $prm;
			
			# Set the value in the gui
			$self->{configurl}->SetValue($configurl[1]);
		}
		# Else if $prm contains nothing useful
		elsif($prm =~ /^(|\n|\r|\r\n|\n\r)$/)
		{
			# Do nothing
		}
		else
		{
			# Set the value in the gui
			$self->{prms}->AppendText("$prm\n");
		}
	}
	
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub parse_plist
{
	# Get the passed variables
	my ($contents, $self) = @_;
	
	# Replace all newlines with ¤
	$contents =~ s/[\r\n]/¤/g;
	
	# Split the string by ¤
	my @parameters = split /¤/, $contents;
	
	# Make a counter for this foreach loop
	my $counter = 0;
	
	# Make a variable to contain the parameters
	my $prm;
	
	# For each value in the array
	foreach (@parameters)
	{
		# If the current line contains com.jagex.config
		if ($parameters[$counter] =~ /com\.jagex\.config/)
		{
			# Get the next line
			$prm = $parameters[$counter+1];
			
			# Remove <string></string>
			$prm =~ s/(\s*<string>|<\/string>)//g;
			
			# Set the value in the gui
			$self->{configurl}->SetValue("$prm");
		}
		# Else if the current line contains sun.java2d.nodraw
		elsif($parameters[$counter] =~ /<key>sun\.java2d\.nodraw<\/key>/)
		{
			# Get the next line
			$prm = $parameters[$counter+1];
			
			# Remove <string></string>
			$prm =~ s/(\s*<string>|<\/string>)//g;
			# Remove <key></key>
			$parameters[$counter] =~ s/(\s*<key>|<\/key>)//g;
			
			# Set the value in the gui
			$self->{prms}->AppendText("-D$parameters[$counter]=$prm\n");
		}
		# Else if the current line contains VMOptions.i386
		elsif($parameters[$counter] =~ /VMOptions\.i386/)
		{
			# Get the next line
			my $prm_string = $parameters[$counter+1];
			
			# Remove <string></string>
			$prm_string =~ s/(\s*<string>|<\/string>)//g;
			
			# Split the java parameters by whitespace
			my @prms = split /\ /, $prm_string;
			
			# For each value in the array
			foreach my $prm_item (@prms)
			{
				# If $prm is -Xmx then
				if ($prm_item =~ /^-Xmx/)
				{
					# Add $prm to a new variable we can play with
					my $xmx = $prm_item;
					# Remove all letters and dashes
					$xmx =~ s/[a-z\-]//ig;
					# Set the value in the gui
					$self->{Xmx}->SetValue($xmx);
				}
				# Else if $prm is -Xms then
				elsif($prm_item =~ /^-Xms/)
				{
					# Add $prm to a new variable we can play with
					my $xms = $prm_item;
					# Remove all letters and dashes
					$xms =~ s/[a-z\-]//ig;
					# Set the value in the gui
					$self->{Xms}->SetValue($xms);
				}
				# Else if $prm contains jagexappletviewer then
				elsif($prm_item =~ /jagexappletviewer/i)
				{
					# Do nothing
				}
				# Else if $prm is -Xss then
				elsif($prm_item =~ /^-Xss/)
				{
					# Add $prm to a new variable we can play with
					my $xss = $prm_item;
					# Remove all letters and dashes
					$xss =~ s/[a-z\-]//ig;
					# Set the value in the gui
					$self->{Xss}->SetValue($xss);
				}
				else
				{
					# Set the value in the gui
					$self->{prms}->AppendText("$prm_item\n");
				}
				
			}
			
		}

		# Increase counter by 1
		$counter += 1;
	}
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub delete_maincache
{
	my ($self, $event) = @_;
	
	# Make a variable to get the output
	my $output;
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Make variables for homedrive and windir
		my $HOMEDRIVE = $ENV{"HOMEDRIVE"};
		my $WINDIR = $ENV{"WINDIR"};
		
		# Delete the cache
		remove_dir($self, "$HOME\\jagexcache\\runescape\\LIVE", 1);
		remove_dir($self, "$HOME\\jagexcache1\\runescape\\LIVE", 1);
		remove_dir($self, "$HOME\\.jagex_cache_32", 1);
		remove_dir($self, "$HOMEDRIVE\\.jagex_cache_32", 1);
		remove_dir($self, "$ENV{WINDIR}\\.jagex_cache_32", 1);
		
		## Old code, kept incase test fails
		#$output = `del /F /S /Q "$HOME\\jagexcache\\runescape\\LIVE" 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		#$output = `del /F /S /Q "$HOME\\jagexcache1\\runescape\\LIVE" 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		#$output = `del /F /S /Q "$HOME\\.jagex_cache_32" 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		#$output = `del /F /S /Q "$HOMEDRIVE\\.jagex_cache_32" 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		#$output = `del /F /S /Q "$ENV{WINDIR}\\.jagex_cache_32" 2>&1`;
		#$self->{terminal_output}->AppendText("$output"."Operation Finished\n");
		
	}
	# Else we are on UNIX
	else
	{
		# Delete the cache
		remove_dir($self, "$HOME/jagexcache/runescape/LIVE", 1);
		remove_dir($self, "$HOME/.jagex_cache_32", 1);
		
		#$output = `rm -r -v $HOME/jagexcache/runescape/LIVE 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		#$output = `rm -r -v $HOME/.jagex_cache_32 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		
		# If we are on darwin/MacOSX
		if ($OS =~ /darwin/)
		{
			# The cache can appear on another location so we delete that too
			remove_dir($self, "$HOME/Library/Caches/jagexcache/runescape/LIVE", 1);
			
			#$output = `rm -r -v $HOME/Library/Caches/jagexcache/runescape/LIVE 2>&1`;
			#$self->{terminal_output}->AppendText("$output");
		}
	}
	
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub delete_betacache
{
	my ($self, $event) = @_;
	
	# Make a variable to get the output
	my $output;
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Make variables for homedrive and windir
		my $HOMEDRIVE = $ENV{"HOMEDRIVE"};
		my $WINDIR = $ENV{"WINDIR"};
		
		# Replace / with \
		$WINDIR =~ s/\//\\/g;
		
		# Delete the cache
		remove_dir($self, "$HOME\\jagexcache\\runescape\\LIVE_BETA", 1);
		remove_dir($self, "$HOME\\jagexcache1\\runescape\\LIVE_BETA", 1);
		
		#$output = `del /F /S /Q "$HOME\\jagexcache\\runescape\\LIVE_BETA" 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		#$output = `del /F /S /Q "$HOME\\jagexcache1\\runescape\\LIVE_BETA" 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
	}
	# Else we are on UNIX
	else
	{
		# Delete the cache
		remove_dir($self, "$HOME/jagexcache/runescape/LIVE_BETA", 1);
		
		#$output = `rm -r -v $HOME/jagexcache/runescape/LIVE_BETA 2>&1`;
		#$self->{terminal_output}->AppendText("$output");
		
		# If we are on darwin/MacOSX
		if ($OS =~ /darwin/)
		{
			# The cache can appear on another location so we delete that too
			remove_dir($self, "$HOME/Library/Caches/jagexcache/runescape/LIVE_BETA", 1);
			
			#$output = `rm -r -v $HOME/Library/Caches/jagexcache/runescape/LIVE_BETA 2>&1`;
			#$self->{terminal_output}->AppendText("$output");
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub set_tooltips
{
	my ($self) = @_;
	
	# Display a messagebox to tell about the setting
	#Wx::MessageBox("What's minimum heap?", "", wxOK,$self);
	
	# Set tooltips with info about the settings
	$self->{Xms}->SetToolTip("The minimum heap allocation is the minimum\namount of RAM Java is allowed to allocate for it's own use.\nIf the field is empty, the setting will be ignored.");
	$self->{Xmx}->SetToolTip("The maximum heap allocation is the maximum\namount of ram Java is allowed to allocate for it's own use.\nIt is recommended to have this set to 512mb (up to 1024mb)\nbut not above 50% of your available RAM to fix black/white screen issues and client crashes(self closing).");
	$self->{Xss}->SetToolTip("The stack is a restricted data structure where only a small number of operations are performed.\nIf the stack is too small it might result in an Error_Game_Crash message.\nHowever a corrupt(or lack of access to) jagexcache can cause an identical issue!");
	$self->{classpath}->SetToolTip("The classpath is the name and location of the .jar file\nwhich is the actual client, the classpath is ALWAYS jagexappletviewer.jar");
	$self->{configurl}->SetToolTip("The config url is where the client loads it's external settings,\nit's also the config url that decides which world you will\nbe logged into when you first login to the game.\nBy default this is the world closest to your location, however if you replace \"www\" with world7\nit would make you always use world7 as your default world.");
	$self->{prms}->SetToolTip("The Misc Settings is a special field where you can enter advanced\njava parameters, it is mostly used to fix new issues or add non standard client settings.\nIn short you can alter the java execution here and tweak\nthe client to work best on your computer.\n\nFor a full list of settings you can add here just google for \"Java HotSpot VM Options\"");
	$self->{soundsystem}->SetToolTip("In some cases Java will be unable to play sounds properly on\nunix(randomly disappearing sound effects), forcing java to\nplay sounds through alsa(recommended for linux) or\npulseaudio(recommended for other unixes) will fix these\nsound issues.");
	$self->{prmFile}->SetToolTip("Here you can assign a custom parameter file to the script, this\nis nice to do if you do not want to change or mess up your\ndefault parameter file, or you want to create a custom one for\na certain situation.\nNOTE: If the new file do not exist, it will use the previous file as a template!");
	$self->{customjava}->SetToolTip("If you set preferred java to custom-java, you will be\nable to use this to tell the script to use a custom java\nbinary/executable. This will let you run the game\nthrough oracle java or openjdk at will or let you run the game\nthrough 32bit java on 64bit platforms");
	$self->{configfilepath}->SetToolTip("A copy/paste-able location of the currently used parameter file.\nThis is provided incase you need it for something.");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub preferredjava_changed
{
	# Get the pointers
	my ($self, $event) = @_;
	
	# If preferredjava is set to custom-java
	if ($self->{preferredjava}->GetCurrentSelection =~ 3)
	{
		# Enable the filepicker
		$self->{customjava}->Enable(1);
	}
	# Else
	else
	{
		# Make sure the filepicker is disabled
		$self->{customjava}->Enable(0);
		
		# Set the filepicker value to nothing
		$self->{customjava}->SetPath('');
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub saveconf_clicked
{
	# Get the pointers
	my ($self, $event) = @_;
	
	# Get the values from the gui
	my $prmfile_setting = $self->{prmFile}->GetValue;
	my $soundsystem_setting = $self->{soundsystem}->GetSelection;
	my $preferredjava_setting = $self->{preferredjava}->GetSelection;
	my $customjava_setting = $self->{customjava}->GetPath;
	my $winemode_setting = $self->{winemode}->GetValue;
	my $primusmode_setting = $self->{primusmode}->GetValue;
	my $old_win32java = rsu::files::IO::readconf("win32java.exe", "default-java", "settings.conf", "$clientdir");
	my $old_unixjava = rsu::files::IO::readconf("preferredjava", "default-java", "settings.conf", "$clientdir");
	
	# Prepare a message that will be shown once all settings are saved
	my $savemessage = "Configurations Saved!";
	
	## Write prmfile setting
	# Start writing the settings.conf
	rsu::files::IO::WriteFile("prmfile=$prmfile_setting", ">", "$clientdir/share/settings.conf");
	
	## Write preferredjava setting
	# If preferredjava is set to custom-java
	if ($preferredjava_setting =~ /3/)
	{
		# If we are not on windows
		if ($OS =~ /MSWin32/)
		{
			# Add the custom path to the settings.conf
			rsu::files::IO::WriteFile("preferredjava=$old_unixjava", ">>", "$clientdir/share/settings.conf");
			rsu::files::IO::WriteFile("win32java.exe=$customjava_setting", ">>", "$clientdir/share/settings.conf");
		}
		# Else
		else
		{
			# Add the custom path to the settings.conf
			rsu::files::IO::WriteFile("preferredjava=$customjava_setting", ">>", "$clientdir/share/settings.conf");
			rsu::files::IO::WriteFile("win32java.exe=$old_win32java", ">>", "$clientdir/share/settings.conf");
		}
	}
	# Else if preferredjava is set to 7-openjdk
	elsif($preferredjava_setting =~ /1/)
	{
		# Write the 7-openjdk option to settings.conf
		rsu::files::IO::WriteFile("preferredjava=7-openjdk", ">>", "$clientdir/share/settings.conf");
		rsu::files::IO::WriteFile("win32java.exe=$old_win32java", ">>", "$clientdir/share/settings.conf");
	}
	# Else if preferredjava is set to 6-openjdk
	elsif($preferredjava_setting =~ /2/)
	{
		# Write the 6-openjdk option to settings.conf
		rsu::files::IO::WriteFile("preferredjava=6-openjdk", ">>", "$clientdir/share/settings.conf");
		rsu::files::IO::WriteFile("win32java.exe=$old_win32java", ">>", "$clientdir/share/settings.conf");
	}
	# Else
	else
	{
		# Write the default-java option to settings.conf
		rsu::files::IO::WriteFile("preferredjava=default-java", ">>", "$clientdir/share/settings.conf");
		rsu::files::IO::WriteFile("win32java.exe=default-java", ">>", "$clientdir/share/settings.conf");
	}
	
	## Write sound settings
	# If pulseaudio is selected as sound system
	if ($soundsystem_setting =~ /1/)
	{
		# Write forcepulseaudio=true to settings.conf
		rsu::files::IO::WriteFile("forcepulseaudio=true", ">>", "$clientdir/share/settings.conf");
		rsu::files::IO::WriteFile("forcealsa=false", ">>", "$clientdir/share/settings.conf");
	}
	# Else if alsa is selected as sound system
	elsif($soundsystem_setting =~ /2/)
	{
		# Write forcealsa=true to settings.conf
		rsu::files::IO::WriteFile("forcepulseaudio=false", ">>", "$clientdir/share/settings.conf");
		rsu::files::IO::WriteFile("forcealsa=true", ">>", "$clientdir/share/settings.conf");
	}
	# Else if alsa+pulse is selected as soundsystem
	elsif($soundsystem_setting =~ /3/)
	{
		# Write forcepulseaudio=true and forcealsa=true to settings.conf
		rsu::files::IO::WriteFile("forcepulseaudio=true", ">>", "$clientdir/share/settings.conf");
		rsu::files::IO::WriteFile("forcealsa=true", ">>", "$clientdir/share/settings.conf");
	}
	# Else
	else
	{
		# Write forcealsa=false and forcepulseaudio=false to settings.conf
		rsu::files::IO::WriteFile("forcepulseaudio=false", ">>", "$clientdir/share/settings.conf");
		rsu::files::IO::WriteFile("forcealsa=false", ">>", "$clientdir/share/settings.conf");
	}
	
	
	## Write compabilitymode/winemode setting
	# If winemode is checked/enabled
	if ($winemode_setting =~ /1/)
	{
		# Write compabilitymode=true to settings.conf
		rsu::files::IO::WriteFile("compabilitymode=true", ">>", "$clientdir/share/settings.conf");
	}
	# Else
	else
	{
		# Write compabilitymode=false to settings.conf
		rsu::files::IO::WriteFile("compabilitymode=false", ">>", "$clientdir/share/settings.conf");
	}
	
	## Write primusmode setting
	# If primusmode is checked/enabled
	if ($primusmode_setting =~ /1/)
	{
		# Write useprimusrun=true to settings.conf
		rsu::files::IO::WriteFile("useprimusrun=true", ">>", "$clientdir/share/settings.conf");
		
		$savemessage = "$savemessage\n\nWarning!: Do not disable your Nvidia Card with\n\"bbswitch\" while runescape runs through primusrun!";
	}
	# Else
	else
	{
		# Write useprimusrun=false to settings.conf
		rsu::files::IO::WriteFile("useprimusrun=false", ">>", "$clientdir/share/settings.conf");
	}
	
	# Display a messagebox to notify that the function is done
	Wx::MessageBox("$savemessage", "Configurations Saved!", wxOK,$self);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub tab_box1_changepage
{
	my ($self, $event) = @_;
	
	# Set $prmfile to the one typed into the script settings
	$prmfile = $self->{prmFile}->GetValue;
	
	loadsettings($self);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub remove_dir
{
	# Get pointers
	my ($self, $location, $giveoutput) = @_;
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Delete all files in $location and pipe all output to the OUTPUT handle
		open  (OUTPUT, "del /F /S /Q \"$location\" 2>&1 |");
	}
	# Else we are on unix
	else
	{
		# Remove all files in $location and pipe all output to the OUTPUT handle
		open  (OUTPUT, "rm -r -v \"$location\" 2>&1 |");
	}
	
	# While OUTPUT still contains somethin
	while (<OUTPUT>)
	{
		# If user asked to give output
		if ($giveoutput =~ /1/)
		{
			# Append output to the terminal_output widget
			$self->{terminal_output}->AppendText("$_");
		}
	}
	# Close the handle
	close(OUTPUT);
	
	# If user asked to give output
	if ($giveoutput =~ /1/)
	{
		# Append output to the terminal_output widget
		$self->{terminal_output}->AppendText("Operation finished\n");
	}
}

#
#---------------------------------------- *** ----------------------------------------
#



package RS_Config_Editor;
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

#
#---------------------------------------- *** ----------------------------------------
#


package main;

my $app = RS_Config_Editor->new;
$app->MainLoop;


# Write a file from scratch(deletes previous content)
sub WriteFile
{
	# Get the passed variables
	my ($content, $writemode, $outfile) = @_;
	
	# Open the outfile for Writing/Rewrite
	open (my $FILE, "$writemode$outfile");
	
	# Remove any whitespaces
	$content =~ s/(\n|\r|\r\n|\n\r)\s*/\n/g;

	# Write the content passed to the function to the file
	print $FILE "$content";
}

#
#---------------------------------------- *** ----------------------------------------
#

# Read contents from a file and put it into a pointer
sub ReadFile 
{
	# Gets passed data from the function call
	my ($filename) = @_;

	# Makes an array to keep the inputdata
	my @inputdata;

	# Opens the passed file, if error it dies with the message "Can't open filename"
	open (my $FILE, "$filename") || return "error reading file";
	
	# While there is something in the file
	while(<$FILE>)
	{
		# Skip comments
		next if /^\s*#/;
		
		# Push data into the inputdata array
		push(@inputdata, $_)
	}

	# Close the file
	close($FILE);

	# Return the pointer to the datafile inputdata
	return(\@inputdata);
}

#
#---------------------------------------- *** ----------------------------------------
#


sub readconf
{
	# Get the passed data from function call
	my ($key, $default, $conf_file) = @_;
	
	# Get the content from the settings file
	my $confcontent = ReadFile("$clientdir/share/$conf_file");
	
	# If no file is found or error reading the file
	if ($confcontent =~ /error reading file/)
	{
		# Then return default value
		return $default;
	}
	
	# Split the conf file content by newline
	my @settings = split /(\n|\r\n|\r)/, "@$confcontent";
	
	# Make a container for the value of the key we are looking for
	my $value = '';
	
	# Make a counter for the foreach loop
	my $counter = 0;
	
	# For each index in the  @settings array
	foreach(@settings)
	{
		# If the line starts with the $key
		if ($settings[$counter] =~ /$key/)
		{
			# Split the line by =
			my @keyvalue = split /=/, $_;
			
			# Put the value into the one we are returning
			$value = $keyvalue[1];
		}
		
		# Increase the counter by 1
		$counter += 1;
	}
	
	# If we still got no value
	if ($value eq '')
	{
		# Set value to default
		$value = $default;
	}
	
	# Return the value of the key we were looking for
	return $value;
}

#
#---------------------------------------- *** ----------------------------------------
#


1;
