package rsu::files::copy;

# Use the File::Copy module
use File::Copy qw(cp);

# Use the File::Path module
use File::Path qw(make_path);

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
	print "\"$from\" -> \"$to\"\n";
	
	# Copy file $from $to
	cp("$from", "$to");
}

1; 
