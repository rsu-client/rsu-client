package rsu::files::dirs;

sub list
{
	# Get the passed data
	my ($dir) = @_;
	
	# Open the directory
	opendir(my $dir_content, $dir);
	
	# Make an array to contain the files inside
	my @list;
	
	# While there are still contents in the directory
	while (readdir $dir_content)
	{
		# Skip . and ..
		next if $_ =~ /^(\.|)\.$/;
		
		# Add file to array
		push @list, $_;
	}
	
	# Return the array
	return @list;
}

#
#---------------------------------------- *** ----------------------------------------
#

# Recursive list, returns full paths!
sub rlist
{
	# Get the passed data
	my ($dir) = @_;
	
	# Open the directory
	opendir(my $dir_content, $dir);
	
	# Make an array to contain the files inside
	my @list;
	
	# While there are still contents in the directory
	while (readdir $dir_content)
	{
		# Go to next if current file is . .. .DS_Store or .directory
		next if $_ =~ /^(\.|\.\.|\.DS_Store|\.directory)/i;
		
		# Make a variable to contain the filename
		my $filename = $_;
		
		# If the current object does not start with a . and is a directory
		if (-d "$dir/$filename")
		{
			# Get all the recursive files
			my @recursive = rsu::files::dirs::rlist("$dir/$filename");
			
			# Merge the arrays
			@list = (@list, @recursive);
			
			# Go to next loop
			next;
		}
		
		# Add file to array
		push @list, "$dir/$_";
	}
	
	# Return the array
	return @list;
}

1; 
