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
	
	if ("$OS" =~ /linux/)
	{
		# Transfer clientdir to a variable we can use
		my $clientdir = $rsu_data->clientdir;
		
		# List all modules
		my $addons = `ls "$clientdir/modules/addons/" | grep -v "framework"`;
		
		# Split up the list into an array
		my @addons = split (/\n/, $addons);
		my $addon;
		
		# Read the addon list
		my $addonconfig = rsu_IO::ReadFile($clientdir."/share/addons.conf");
		
		# If file does not exist
		if ($addonconfig =~ /error reading file/)
		{
			# Tell what we are doing
			print "No addons.conf found, i will generate one with\nall addons disabled!\n\n";
			
			# Loop through the list of addons and generate the file
			foreach $addon (@addons)
			{
				# Add modules to config
				rsu_IO::WriteFile("$addon=disable\n", ">>", $clientdir."/share/addons.conf");
			}
		}
		else
		{
			# Tell what we are doing
			print "addons.conf found!\nParsing addon list.\n\n";
			
			foreach $addon (@addons)
			{
				# Get the status of the addon
				my $addonstatus = rsu_IO::readconf("$addon", "undef", "addons.conf", $rsu_data);
				
				# If addon is enabled
				if ($addonstatus =~ /enable/i)
				{
					# Tell what we are doing
					print "Starting the moduleloader.pl for $addon\n";
					
					# Execute module
					system "perl -w \"$clientdir/modules/addons/$addon/moduleloader.pl\""
				}
				# Else if addonstatus is undef (undefined)
				elsif($addonstatus =~ /undef/)
				{
					# Add addon to addons.conf but disable it
					rsu_IO::WriteFile("$addon=disable\n", ">>", $clientdir."/share/addons.conf");
				}
				
				
			}
			
			# Print an empty line for tidyness
			print "\n";
		}
		
		
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

