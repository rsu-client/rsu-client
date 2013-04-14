package rsu::files::IO;

# Write a file from scratch(deletes previous content)
sub WriteFile
{
	# Get the passed variables
	my ($content, $writemode, $outfile) = @_;
	
	# Open the outfile for Writing/Rewrite
	open (my $FILE, "$writemode$outfile");

	# Write the content passed to the function to the file
	print $FILE "$content\n";
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

	# Opens the passed file, if error it returns language=0 which equals english
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
	my ($key, $default, $conf_file, $dir) = @_;
	
	# Require the sysdload module
	require updater::download::sysdload;
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Make a variable to hold the basedir
	my $basedir = rsu::files::clientdir::getclientdir()."/share/configs";
	
	# If a directory is passed and it is not empty or a url
	if (defined $dir && $dir ne '')
	{
		# Use the passed directory as the basedir
		$basedir = $dir;
	}
	
	# Make a variable to contain the conf contents
	my $confcontent;
	
	# If $basedir is a url then
	if ($basedir =~ /^(http|https):\/\//)
	{
		# Read the conf from url
		$confcontent = updater::download::sysdload::readurl($basedir."/$conf_file");
	}
	# Else if dir is string://
	elsif($basedir =~ /^string:\/\//)
	{
		# Use the $conf_file as $confcontent
		$confcontent = $conf_file;
	}
	# Else
	else
	{
		# Get the content from the settings file
		$confcontent = rsu::files::IO::ReadFile($basedir."/$conf_file");
		
		# If no file is found or error reading the file
		if ($confcontent =~ /error reading file/)
		{
			# Print debug info
			print STDERR "Error reading $conf_file, using default value: $default\n";
			
			# Then return default value
			return $default;
		}
		# Else
		else
		{
			# Pass the array reference to a string
			$confcontent = "@$confcontent";
		}
	}
	
	# Split the conf file content by newline
	my @settings = split /(\n|\r\n|\r)/, "$confcontent";
	
	# Make a container for the value of the key we are looking for
	my $value = '';
	
	# Make a counter for the foreach loop
	my $counter = 0;
	
	# For each index in the  @settings array
	foreach(@settings)
	{
		# If the line starts with the $key
		if ($settings[$counter] =~ /($key)=/)
		{
			# If $default is not undef which is used by API calls
			if ($default !~ /^undef$/)
			{
				# Print debug info
				print "Reading value from \"$key\"\n";
			}
			
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
		# Print debug info
		print STDERR "Did not find $key in $conf_file\n";
		
		# Set value to default
		$value = $default;
	}
	
	# If $default is not undef which is used by API calls
	if ($default !~ /^undef$/)
	{
		# Print debug info
		print "Setting script data $key to $value\n";
	}
	
	# Return the value of the key we were looking for
	return $value;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub getcontent
{
	# Get the passed data
	my ($cwd, $file) = @_;
	
	# Require the sysdload module
	require updater::download::sysdload;
	
	# Make a variable to hold the content
	my $content;
	
	# If this is a url then
	if ($cwd =~ /^(http|https):\/\//)
	{
		# Read the content from remote file
		$content = updater::download::sysdload::readurl($cwd."/$file");
	}
	# Else
	else
	{
		# Get the content of the file
		$content = rsu::files::IO::ReadFile($cwd."/$file");
		
		# If no file is found or error reading the file
		if ($content =~ /error reading file/)
		{
			# Print debug info
			print STDERR "Error reading $file, file not found";
			
			# Empty the content variable
			$content = "\n";
		}
		# Else
		else
		{
			# Convert the array reference to a string
			$content = "@$content";
			# Fix all lines starting with space
			$content =~ s/(\n|\n\r|\r)\s+/\n/g;
		}
	}
	
	# Return the content
	return "$content";
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
