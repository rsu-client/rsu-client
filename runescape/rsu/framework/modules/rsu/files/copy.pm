package rsu::files::copy;

# Use the File::Copy module
use File::Copy qw(cp mv);

# Use the recursive version of copy too
use File::Copy::Recursive qw(dircopy dirmove);

# Use the File::Path module
use File::Path qw(make_path);

# Get the platform we are on
my $OS = $^O;

sub print_cpr
{
	# Get the passed data
	my ($from,$to,$replace) = @_;
	
	# If the $from is not /
	if ($from !~ /^$/)
	{
		# If replacing content was requested
		if (defined $replace && $replace =~ /^(1|true)$/i)
		{
			# Tell user what we are doing
			print "Replacing content in:\n\"$to/\"\nWith content from:\n\"$from/\"\n";
			
			if ($OS !~ /darwin/)
			{
				# Enable Remove Target Directory Before Copy
				local $File::Copy::Recursive::RMTrgDir = 2;
				
				# Copy $from to $to
				dircopy($from, $to) or warn $!;
			}
			# Else
			else
			{
				# Make the path to where we copy the file
				make_path($to);
				
				# Copy using rsync
				system "rsync -r --delete \"$from/\"* \"$to\"";
			}
		}
		else
		{
			# Tell user what we are doing
			print "cp: \"$from/\" -> \"$to/\"\n";
			
			# Copy $from to $to
			dircopy($from, $to) or warn $!;
		}
	}
	
}

#
#---------------------------------------- *** ----------------------------------------
#

sub print_mvr
{
	# Get the passed data
	my ($from,$to,$replace) = @_;
	
	# If the $from is not /
	if ($from !~ /^$/)
	{
		# If replacing content was requested
		if (defined $replace && $replace =~ /^(1|true)$/i)
		{
			# Tell user what we are doing
			print "Replacing content in:\n\"$to/\"\nWith content from:\n\"$from/\"\n";
			
			# If we are not on mac osx
			if ($OS !~ /darwin/)
			{
				# Enable Remove Target Directory Before Copy
				local $File::Copy::Recursive::RMTrgDir = 2;
			
				# Copy $from to $to
				dirmove($from, $to) or warn $!;
			}
			# Else
			else
			{
				# Make the path to where we copy the file
				make_path($to);
				
				# Copy using rsync
				system "rsync -r --delete \"$from/\"* \"$to\"";
			}
		}
		else
		{
			# Tell user what we are doing
			print "mv: \"$from/\" -> \"$to/\"\n";
			
			# Copy $from to $to
			dirmove($from, $to) or warn $!;
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub print_cp
{
	# Get the passed data
	my ($from,$to) = @_;
	
	# Make a variable that we will remove the filename from
	my $dir = $to;
	
	# Split the path by /
	my @filename = split /\//, $dir;
	
	# Remove the filename from the $dir
	$dir =~ s/\/$filename[-1]$//;
	
	# Make the path to where we copy the file
	make_path($dir);
	
	# Tell user what we are doing
	print "cp: \"$from\" -> \"$to\"\n";
	
	# Copy file $from $to
	cp("$from", "$to");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub print_mv
{
	# Get the passed data
	my ($from,$to) = @_;
	
	# Make a variable that we will remove the filename from
	my $dir = $to;
	
	# Split the path by /
	my @filename = split /\//, $dir;
	
	# Remove the filename from the $dir
	$dir =~ s/\/$filename[-1]$//;
	
	# Make the path to where we copy the file
	make_path($dir);
	
	# Tell user what we are doing
	print "mv: \"$from\" -> \"$to\"\n";
	
	# Copy file $from $to
	mv("$from", "$to");
}

1; 
