package rsu::extract::archive;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

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
	
    # Make a variable to check if extraction was successful
	my $error = 0;
    
	# Make a handler for the archive
	my $extract_handler = Archive::Extract->new( archive => $archive ) or $error = 1;
    
    # If the archive is invalid
    if ($error =~ /^1$/)
    {
        # Print to STDERR that extraction failed
		print STDERR "Extraction failed with error:\nArchive file is not a valid .tar.gz or .zip file!\n\n";
        
        # Return to call with error
        return "Archive is not a valid .tar.gz or .zip file";
    }
	
	# Extract the archive
	$extract_handler->extract( to => $outdir ) or $error = 1; #die $extract_handler->error;
	
	# If extraction failed then
	if ($error =~ /^0$/)
	{
		# Return null
		return "0";
	}
	# Else
	else
	{
		# Print to STDERR that extraction failed
		print STDERR "Extraction failed with error:\n".$extract_handler->error."\n\n";
		
		# Return with the error
		return $extract_handler->error;
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
