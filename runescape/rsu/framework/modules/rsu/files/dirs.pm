package rsu::files::dirs;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

sub list
{
	# Get the passed data
	my ($dir) = @_;
	
	# Make a variable to contain a value that tells us if we need to use fallback methods or not
	my $fallback = 0;
	
	# Check if functions we need are supported and put fallback to 1 if they are not supported
	eval "use 5.012"; $fallback = 1 if $@;
	
	# Make an array to contain the files inside
	my @list;
	
	# If the functions we need are not supported then
	if ($fallback eq '1')
	{
		# List the files in $dir
		my $dirlist = `ls "$dir"`;
		
		# Split the files by newline into an array
		my @dir = split /\n/, $dirlist;
		
		# For each value in the array
		foreach my $file (@dir)
		{
			# Skip . and anything that starts with a dot
			next if $file =~ /^\./;
			
			# Add file to array
			push @list, $file;
		}
	}
	else
	{
		# Open the directory
		opendir(my $dir_content, $dir);
		
		# While there are still contents in the directory
		while (readdir $dir_content)
		{
			# Skip . and anything that starts with a dot
			next if $_ =~ /^\./;
			
			# Add file to array
			push @list, $_;
		}
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
	
	# Make a variable to contain a value that tells us if we need to use fallback methods or not
	my $fallback = 0;
	
	# Check if functions we need are supported and put fallback to 1 if they are not supported
	eval "use 5.012"; $fallback = 1 if $@;
	
	# Make an array to contain the files inside
	my @list;
	
	# If the functions we need are not supported then
	if ($fallback eq '1')
	{
		# List the files in $dir
		my $dirlist = `ls "$dir"`;
		
		# Split the files by newline into an array
		my @dir = split /\n/, $dirlist;
		
		# For each value in the array
		foreach my $file (@dir)
		{
			# Skip . and anything that starts with a dot
			next if $file =~ /^\./;
			
			# If the current object does not start with a . and is a directory
			if (-d "$dir/$file")
			{
				# Get all the recursive files
				my @recursive = rsu::files::dirs::rlist("$dir/$file");
				
				# Merge the arrays
				@list = (@list, @recursive);
				
				# Go to next loop
				next;
			}
			
			# Add file to array
			push @list, "$dir/$file";
		}
	}
	else
	{
		# Open the directory
		opendir(my $dir_content, $dir);
		
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
	}
	
	# Return the array
	return @list;
}

1; 
