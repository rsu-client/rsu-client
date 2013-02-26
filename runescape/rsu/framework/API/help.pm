package help;
# Get the current working directory
use Cwd;
my $cwd = getcwd;

# Change directory to the API
chdir("$cwd/rsu/framework/API");
# Update the $cwd
$cwd  = getcwd;

# Tell the user what API calls are available
print "The RSU-API contains the following API calls:\n\n";

listapi($cwd);

sub listapi
{
	# Get the apidir
	my ($apidir) = @_;
	
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



1; 
