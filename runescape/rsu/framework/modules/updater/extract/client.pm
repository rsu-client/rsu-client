package updater::extract::client;

# Use the File::Copy module
use File::Copy "cp";

# Get the current OS
my $OS = "$^O";

# Use the File::Path module so we get a crossplatform mkpath and rmdir implementation
use File::Path qw(make_path remove_tree);

# Require the clientdir module
require rsu::files::clientdir;

# Get the clientdir
my $clientdir = rsu::files::clientdir::getclientdir();

sub msiextract
{
	# Get the passed data
	my ($placejar, $extractjawt) = @_;
	
	# Make the location to place the jar file
	make_path("$clientdir/$placejar");
	
	# If we are not on Windows
	if ($OS !~ /MSWin32/)
	{
		# Run the p7zip extraction method
		updater::extract::client::p7zip_msi($placejar, $extractjawt);
	}
	# Else we are on windows
	else
	{
		# Replace / with \ in the $clientdir variable
		$clientdir =~ s/\//\\/g;
		
		# Extract the .msi using msiexec
		system "msiexec /a \"$clientdir\\.download\\runescape.msi\" /qn TARGETDIR=\"$clientdir\\.download\\extracted_files\"";
		
		# Copy the jagexappletviewer.jar to $placejar
		cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/jagexappletviewer.jar", "$clientdir/$placejar/");
		
		# If we are told to extract jawt too then
		if (defined $extractjawt && $extractjawt =~ /true/i)
		{
			# Make the path to place the jawt dll files
			make_path("$clientdir/rsu/3rdParty/Win32/jawt");
			
			# Copy the jawt dll files to the 3RD
			cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/jawt.dll", "$clientdir/rsu/3rdParty/Win32/jawt/");
			cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/awt.dll", "$clientdir/rsu/3rdParty/Win32/jawt/");
			cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/msvcr100.dll", "$clientdir/rsu/3rdParty/Win32/jawt/");
		}
		
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub dmgextract
{
	# Get the passed data
	my ($placejar) = @_;
	
	# Make the location to place the jar file
	make_path("$clientdir/$placejar");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub p7zip_msi
{
	# Get the passed data
	my ($placejar, $extractjawt) = @_;
	
	# Extract the msi using p7zip
	system "cd \"$clientdir/.download/\" && 7z e -oextracted_files -y runescape.msi";
	
	# Open the directory
	opendir(my $msi_dir, "$clientdir/.download/extracted_files");
	
	# While there are still stuff we have not gone through in the folder
	while (readdir $msi_dir)
	{
		# Go to next file if the current file is not one we are looking for
		next if $_ !~ /^(JagexAppletViewerJarFile|AWTDLLFile|JAWTDLLFile|MSVCR100DLLFile)\..+/i;
		
		# Place $_ into a variable so we dont lose it
		my $file = $_;
		
		# If current file is the appletviewer then
		if ($file =~ /^JagexAppletViewerJarFile/i)
		{
			# Copy the jagexappletviewer.jar to $placejar
			cp("$clientdir/.download/extracted_files/$file", "$clientdir/$placejar/jagexappletviewer.jar");
		}
		# Else if current file is a jawt file or dependency and $extractjawt is defined and true then
		elsif($file =~ /^(AWTDLLFile|JAWTDLLFile|MSVCR100DLLFile)/i && defined $extractjawt && $extractjawt =~ /true/i)
		{
			# Create the path for the 3rdParty/Win32 folder
			make_path("$clientdir/rsu/3rdParty/Win32");
			
			# Make a variable to contain the destfile
			my $destfile = $file;
			
			# Replace DLLFile with .dll
			$destfile =~ s/DLLFile.+/\.dll/i;
			
			# Turn into lowercase
			$destfile = lc($destfile);
			
			# Copy the jawt or jawt dependency to the 3rdParty/Win32 folder
			cp("$clientdir/.download/extracted_files/$file", "$clientdir/rsu/3rdParty/Win32/$destfile");
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub p7zip_dmg
{
	# Get the passed data
	my ($placejar) = @_;
	
	# Extract the msi using p7zip
	system "cd \"$clientdir/.download/\" && 7z e -oextracted_files -y runescape.dmg *.hfs && 7z e -oextracted_files -y extracted_files/*.hfs";
	
	# Copy the jagexappletviewer to the location requested
	cp("$clientdir/.download/extracted_files/jagexappletviewer.jar", "$clientdir/$placejar/jagexappletviewer.jar");
}

#
#---------------------------------------- *** ----------------------------------------
#



1; 
