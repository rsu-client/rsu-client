package rsu::files::grep;

# Run grep in defined directory
sub dirgrep
{
	# Get the passed data
	my ($dir, $grepfor) = @_;
	
	# Require the dirs module so we can fetch dir contents
	require rsu::files::dirs;
	
	# Get the content of the directory
	my @content = rsu::files::dirs::list($dir);
	
	# Grep for something
	my @greps = rsu::files::grep::grep(\@content, $grepfor);
	
	# Return the grepped output
	return @greps;
}

#
#---------------------------------------- *** ----------------------------------------
#

# Recursive dirgrep (returns full paths!)
sub rdirgrep
{
	# Get the passed data
	my ($dir, $grepfor) = @_;
	
	# Require the dirs module so we can fetch dir contents
	require rsu::files::dirs;
	
	# Get the paths for all files recursively in the directory
	my @content = rsu::files::dirs::rlist($dir);
	
	# Grep for something
	my @greps = rsu::files::grep::grep(\@content, $grepfor);
	
	# Return the grepped output
	return @greps;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub strgrep
{
	# Get the passed data
	my ($string, $grepfor) = @_;
	
	# Split $string by newline
	my @list = split(/\n/, $string);
	
	# Run grep on the list
	my @result = rsu::files::grep::grep(\@list, $grepfor);
	
	# Return the result
	return @result;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub grep
{
	# Get the passed data
	my ($list, $grepfor) = @_;
	
	# Convert the array reference into an array (the array reference is $list)
	@list = @$list;
	
	# Run grep on list
	my @greps = grep(/$grepfor/i, @list);
	
	# Return grepped items
	return @greps;
}

1;
