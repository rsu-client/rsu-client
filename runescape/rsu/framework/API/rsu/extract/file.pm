package rsu::extract::file;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

# If parameters are missing or help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API call to extract a .zip or .tar/.tar.gz file
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0] ARCHIVE [\"directory\"
	
DEFAULTS:
	ARCHIVE = \$clientdir/.download/ARCHIVE
	directory = \$clientdir
	
NOTES:
	The ARCHIVE can either be just an archive name,
	folder/archivename or /path/to/archivename
	The archivename must contain the full extension (ex: archive.zip)

	The directory parameter is the location
	you want the archive to be extracted to.
	The directory can just be the foldername in which case
	it will result in \$clientdir/foldername
	
	The output location will be created before extraction.

Examples:
	$ARGV[0] archviedfile.zip
	result: extracts the contents of \$clientdir/.download/archivedfile.zip to \$clientdir
	
	$ARGV[0] folder/archviedfile.zip
	result: extracts the contents of \$clientdir/folder/archivedfile.zip to \$clientdir
	
	$ARGV[0] archivedfile.tar.gz \"/tmp\"
	result: extracts the contents of \$clientdir/.download/archivedfile.tar.gz to /tmp
	
	$ARGV[0] C:\\archivedfile.tar \"tmp\"
	result: extracts the contents of C:\\archivedfile.tar to \$clientdir/tmp
	
	$ARGV[0] /tmp/archivedfile.tar \"tmp\"
	result: extracts the contents of /tmp/archivedfile.tar to \$clientdir/tmp
	
Remarks:
	Returns nothing

Purpose:
	Simplify the task of extracting .zip, .tar or .tar.gz archives
"

}
else
{
	# Use the File::Path module so we get a crossplatform mkpath and rmdir implementation
	use File::Path qw(make_path);
	
	# Require the archive module
	require rsu::extract::archive;
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Make a variable containing the archivename
	my $archive;
	
	# If the first parameter is a full path then
	if ($ARGV[1] =~ /^(\$|\%|[a-z]:|\/)/i)
	{
		# Use the full parameter as the archive
		$archive = $ARGV[1];
	}
	# Else if the first parameter is not a full path but does contain / or \ then
	elsif($ARGV[1] !~ /^(\$|\%|[a-z]:|\/)/i && $ARGV[1] =~ /(.\/.+|.\\.+)/i)
	{
		# Use $clientdir as the base location and add the parameter at the end
		$archive = "$clientdir/$ARGV[1]";
	}
	# Else
	else
	{
		# Use the default location
		$archive = "$clientdir/.download/$ARGV[1]";
	}
	
	# Make a variable to contain the outdir
	my $outdir = $clientdir;
	
	# If a 2nd parameter is passed
	if (defined $ARGV[2])
	{
		# If the parameter starts with a full path or variable
		if ($ARGV[2] =~ /^(\$|\%|[a-z]:|\/)/i)
		{
			# Use parameter as location
			$outdir = $ARGV[2];
		}
		# Else
		else
		{
			# Use the parameter as foldername
			$outdir = "$clientdir/$ARGV[2]";
		}
	}
	
	# Make the outdir
	make_path("$outdir");
	
	# Extract the archive to $outdir
	rsu::extract::archive::extract($archive, $outdir)
}


1; 
