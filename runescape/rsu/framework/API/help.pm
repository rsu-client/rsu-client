package help;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

# Get the current working directory
use Cwd;
my $cwd = getcwd;

# Make a variable to contain the true cwd
my $true_cwd = $cwd;

# Change directory to the API
chdir("$true_cwd/rsu/framework/API");
# Update the $cwd
$cwd  = getcwd;

# Tell the user what API calls are available
print "The RSU-API contains the following API calls for non-Perl languages(API bridge):\n";

# List the api calls
listapi($cwd);

# Tell the user about the perl modules
print "\nThe RSU-API contains the following Perl modules which perl scripts\ncan use direcly by requiring them:\n";

# Change directory to the API
chdir("$true_cwd/rsu/framework/modules");
# Update the $cwd
$cwd  = getcwd;

# List the raw perl modules
listmodules($cwd);

sub listapi
{
	# Get the apidir
	my ($apidir, $delimiter) = @_;

	# Open the API
	opendir(my $apilist, $apidir);
	
	# Transfer the apidir to a variable
	my $apicall = $apidir;
	
	# Convert the apidir to an apicall
	$apicall =~ s/^$cwd\///g;
	$apicall =~ s/\//\./g;

	# While there are files not mentioned
	while (readdir $apilist)
	{
		# Skip if current file starts with a .
		next if $_ =~ /^\./;
		
		# Add the current file to a variable
		my $file = $_;
		
		# If $file is a folder then
		if (-d "$apidir/$file")
		{
			# Run the listapi on that folder
			help::listapi("$apidir/$file");
		}
		# Else
		else
		{
			# Remove .pm from $file
			$file =~ s/\.pm$//;
			
			# If $apidir is the same as $cwd
			if ($apidir eq $cwd)
			{
				# Write the APIcall to STDOUT
				print "$file\n";
			}
			# Else
			else
			{
				# Write the APIcall to STDOUT
				print "$apicall.$file\n";
			}
		}
	}
	
	closedir($apilist);
}

#
#---------------------------------------- *** ----------------------------------------
#

sub listmodules
{
	# Get the apidir
	my ($moduledir) = @_;
	
	# Open the Modules folder
	opendir(my $modulelist, $moduledir);
	
	# Transfer the moduledir to a variable
	my $module = $moduledir;
	
	# Convert the moduledir to a Perl module call
	$module =~ s/^$cwd\///g;
	$module =~ s/\//::/g;

	# While there are files not mentioned
	while (readdir $modulelist)
	{
		# Skip if current file starts with a .
		next if $_ =~ /^\./;
		
		# Add the current file to a variable
		my $file = $_;
		
		# If $file is a folder then
		if (-d "$moduledir/$file")
		{
			# Run the listapi on that folder
			help::listmodules("$moduledir/$file");
		}
		# Else
		else
		{
			# Remove .pm from $file
			$file =~ s/\.pm$//;
			
			# If $apidir is the same as $cwd
			if ($moduledir eq $cwd)
			{
				# Write the APIcall to STDOUT
				print "$file\n";
			}
			# Else
			else
			{
				# Write the APIcall to STDOUT
				print "$module\:\:$file\n";
			}
		}
	}
	
	closedir($modulelist);
}

#
#---------------------------------------- *** ----------------------------------------
#



1; 
