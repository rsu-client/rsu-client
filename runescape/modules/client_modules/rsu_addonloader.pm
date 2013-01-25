package rsu_addonloader;

# This module requires rsu_IO.pm
require rsu_IO;

sub loadaddons
{
	# Get the data container
	my $rsu_data = shift;
	
	# Transfer rsu_data mutators to variables we can use
	my $OS = $rsu_data->OS;
	my $clientdir = $rsu_data->clientdir;
	
	print "Loading addons\n";
	
	# Open the addons directory
	opendir(my $addondirs, "$clientdir/modules/addons/");
	
	# While there is still content in the folder
	while (readdir $addondirs)
	{
		# If the current content is either named universal or the same as $OS
		if (($_ =~ /^universal$/ && -d "$clientdir/modules/addons/$_") || ($_ =~ /^$OS$/ && -d "$clientdir/modules/addons/$_"))
		{
			# Display addons from the detected addons directory
			load_enabled_addons($rsu_data, "$clientdir/modules/addons/$_");
		}
	}
	
	# Close the directory to free memory
	closedir($addondirs);
}

sub load_enabled_addons
{
	# Get the passed variables
	my ($rsu_data, $addondir) = @_;
	
	# Transfer rsu_data mutators to variables we can use
	my $OS = $rsu_data->OS;
	my $clientdir = $rsu_data->clientdir;
	my $cwd = $rsu_data->cwd;
	
	# Read the addon list
	my $addonconfig = rsu_IO::ReadFile($clientdir."/share/addons.conf");
	
	# If file does not exist
	if ($addonconfig =~ /error reading file/)
	{
		# Tell what we are doing
		print "No addons.conf found, i will generate one with\nall addons disabled!\n\n";
	}
	# Else
	else
	{
		# Tell what we are doing
		print "addons.conf found!\nParsing addon list.\n\n";
	}
	
	# Open the directory containing addons
	opendir(my $addons, $addondir);
	
	# While there is still content in the folder
	while (readdir $addons)
	{
		# Go to next if the current content is a relative directory (. or ..) or if the folder is named framework
		next if $_ =~ /^(\.|\.\.|framework)$/;
		
		# Move the current folder to a variable so we can reuse it several times (as $_ gets overwritten during this while loop)
		my $addon = $_;
		
		# If file does not exist
		if ($addonconfig =~ /error reading file/)
		{
			# Add modules to config
			rsu_IO::WriteFile("$addon=disable\n", ">>", $clientdir."/share/addons.conf");
		}
		else
		{			
			# Get the status of the addon
			my $addonstatus = rsu_IO::readconf("$addon", "undef", "addons.conf", $rsu_data);
			
			# If addon is enabled
			if ($addonstatus =~ /enable/i)
			{
				# Tell what we are doing
				print "Starting the moduleloader.pl for $addon\n";
				
				# If we are on windows
				if ($OS =~ /MSWin32/)
				{
					# If this is an windows only addon
					if ($addondir !~ /\/universal\//)
					{
						# Execute module
						system (1,"$cwd/rsu-launcher.exe --script=\"modules/addons/$OS/$addon/moduleloader.pl\"");
					}
					# Else this is an universal addon
					else
					{
						# Execute module
						system (1,"$cwd/rsu-launcher.exe --script=\"modules/addons/universal/$addon/moduleloader.pl\"");
					}
				}
				# Else we are on either darwin/mac or linux which both have perl
				else
				{
					# If this is an addon only for the current platform
					if ($addondir !~ /\/universal\//)
					{
						# Execute module
						system "perl -w \"$clientdir/modules/addons/$OS/$addon/moduleloader.pl\"";
					}
					# Else this is an universal addon
					else
					{
						# Execute module
						system "perl -w \"$clientdir/modules/addons/universal/$addon/moduleloader.pl\"";
					}
				}
				
			}
			# Else if addonstatus is undef (undefined)
			elsif($addonstatus =~ /undef/)
			{
				# Add addon to addons.conf but disable it
				rsu_IO::WriteFile("$addon=disable\n", ">>", $clientdir."/share/addons.conf");
			}
			
			# Print an empty line for tidyness
			print "\n";
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

