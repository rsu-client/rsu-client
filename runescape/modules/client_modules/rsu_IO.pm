package rsu_IO;

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
		my ($key, $default, $conf_file, $rsu_data) = @_;
		
		# Get the content from the settings file
		my $confcontent = ReadFile($rsu_data->clientdir."/share/$conf_file");
		
		# If no file is found or error reading the file
		if ($confcontent =~ /error reading file/)
		{
			# Print debug info
			print "Error reading $conf_file, using default value: $default\n";
			
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
				# Print debug info
				print "Reading value from \"$key\"\n";
				
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
			print "Did not find $key in $conf_file\n";
			
			# Set value to default
			$value = $default;
		}
		
		
		# Print debug info
		print "Setting script data $key to $value\n";
		
		# Return the value of the key we were looking for
		return $value;
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#
1;
