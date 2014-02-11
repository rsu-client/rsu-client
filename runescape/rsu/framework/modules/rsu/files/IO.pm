package rsu::files::IO;

# Use the Config::IniFiles module for proper config file handling
use Config::IniFiles;

# Write a file from scratch(deletes previous content)
sub WriteFile
{
	# Get the passed variables
	my ($content, $writemode, $outfile) = @_;
	
	# Open the outfile for Writing/Rewrite
	open (my $FILE, "$writemode$outfile");

	# Write the content passed to the function to the file
	print $FILE "$content\n";
	
	close ($FILE);
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
	
	# Move the conf content to a scalar reference
	my $configdata = << "config";
$confcontent
config

	# Create a IniFile object
	my $cfg = Config::IniFiles->new( -file => \$configdata, -default => "_", -fallback => "_", -allowempty => 1, -allowedcommentchars => "#" );
	
	# If $default is not undef which is used by API calls
	if ($default !~ /^undef$/)
	{
		# Print debug info
		print "Reading value from \"$key\"\n";
	}
	
	# Read the value from the key
	my $value = $cfg->val("_", $key, $default);
	
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

sub writeconf
{
	# Get the passed data
	my ($section, $key, $value, $conf_file, $dir) = @_;
	
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
	
	# Tell user what we are doing
	print "Setting $key to $value in $basedir/$conf_file\n";
	
	# Write the config settings
	rsu::files::IO::iniWrite("$basedir/$conf_file", "$section", "$key", "$value");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub iniRead
{
	# Get the passed data
	my ($filename, $section, $key, $default) = @_;
	
	# Make sure the file exists by writing nothing to it
	rsu::files::IO::WriteFile("",">>","$filename");
	
	# Create a IniFile object
	my $cfg = Config::IniFiles->new( -file => "$filename", -default => "_", -fallback => "_", -allowempty => 1, -allowedcommentchars => "#" );
	
	# Read the value and return it
	my $value = $cfg->val($section,$key,$default);
	
	# Return the value
	return $value;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub iniWrite
{
	# Get the passed data
	my ($filename, $section, $key, $value) = @_;
	
	# Make sure the file exists by writing nothing to it
	rsu::files::IO::WriteFile("",">>","$filename");
	
	# Create a IniFile object
	my $cfg = Config::IniFiles->new( -file => "$filename", -default => "_", -fallback => "_", -allowempty => 1, -allowedcommentchars => "#" );
	
	# Change the value in $key to $value
	$cfg->newval("$section", "$key", "$value");
	
	# Write the changes to the file
	$cfg->RewriteConfig();
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
