package rsu::extract::archive;

sub extract
{
	# Get the passed data
	my ($archive, $outdir) = @_;
	
	# Use the File::Path module so we can make the $outdir
	use File::Path qw(make_path);
	
	# Make the outdir
	make_path($outdir);
	
	# Use the Archive::Extract module so we can handle .zip and .tar.gz files
	use Archive::Extract;
	
	# Make a handler for the archive
	my $extract_handler = Archive::Extract->new( archive => $archive );
	
	# Extract the archive
	$extract_handler->extract( to => $outdir ) or die $extract_handler->error;
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
