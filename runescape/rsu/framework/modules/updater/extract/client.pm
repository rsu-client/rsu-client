package updater::extract::client;

# Get the current OS
my $OS = "$^O";

# Use the File::Path module so we get a crossplatform mkpath and rmdir implementation
use File::Path qw(make_path remove_tree);

# Require the clientdir module
require rsu::files::clientdir;

# Get the clientdir
my $clientdir = rsu::files::clientdir::getclientdir();

# Require the files grep module
require rsu::files::grep;

# Use the files copy module
require rsu::files::copy;

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
		rsu::files::copy::print_cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/jagexappletviewer.jar", "$clientdir/$placejar/");
		
		# If we are told to extract jawt too then
		if (defined $extractjawt && $extractjawt =~ /true/i)
		{
			# Make the path to place the jawt dll files
			make_path("$clientdir/rsu/3rdParty/Win32/jawt");
			
			# Copy the jawt dll files to the 3RD
			rsu::files::copy::print_cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/jawt.dll", "$clientdir/rsu/3rdParty/Win32/jawt/");
			rsu::files::copy::print_cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/awt.dll", "$clientdir/rsu/3rdParty/Win32/jawt/");
			rsu::files::copy::print_cp("$clientdir/.download/extracted_files/jagexlauncher/jagexlauncher/bin/msvcr100.dll", "$clientdir/rsu/3rdParty/Win32/jawt/");
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
	
	# If we are not on MacOSX
	if ($OS !~ /darwin/)
	{
		# Run the p7zip extraction method
		updater::extract::client::p7zip_dmg($placejar);
	}
	# Else we are on MacOSX
	else
	{
		# Require the grep module
		require rsu::files::grep;
		
		# Mount the dmg file
		my $mountoutput = `hdiutil attach "$clientdir/.download/runescape.dmg"`;
		
		# Find the line containing the mountpoint
		my @mountinfo = rsu::files::grep::strgrep($mountoutput, "RuneScape");
		
		# Split the mountinfo by more than 1 whitespace
		@mountinfo = split /\s{2,}+/, "@mountinfo";
		
		# Locate the jagexappletviewer.jar (futureproof incase jagex decide to change the location)
		my @jarsearch = rsu::files::grep::rdirgrep($mountinfo[1], "jagexappletviewer.jar");
		
		# Copy the jagexappletviewer.jar to $placejar
		rsu::files::copy::print_cp($jarsearch[0], "$clientdir/$placejar");
		
		# Unmount the dmg file
		system "hdiutil detach $mountinfo[0]";
	}
	
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
	
	# Check for the files we are looking for
	my @files = rsu::files::grep::dirgrep("$clientdir/.download/extracted_files", "^(rslauncher|JagexAppletViewerJarFile|AWTDLLFile|JAWTDLLFile|MSVCR100DLLFile)\..+");
	
	# If rslauncher.cab is found
	if ("@files" =~ /rslauncher.cab/)
	{
		# Extract the rslauncher.cab using p7zip
		system "cd \"$clientdir/.download/extracted_files\" && 7z e -y rslauncher.cab";
		
		# Rerun the dirgrep without the check for rslauncher.cab
		@files = rsu::files::grep::dirgrep("$clientdir/.download/extracted_files", "^(JagexAppletViewerJarFile|AWTDLLFile|JAWTDLLFile|MSVCR100DLLFile)\..+");
	}
	
	# For each file found by grep
	foreach my $file (@files)
	{
		# Go to next file if the current file is not one we are looking for
		next if $file !~ /^(JagexAppletViewerJarFile|AWTDLLFile|JAWTDLLFile|MSVCR100DLLFile)\..+/i;
		
		# If current file is the appletviewer then
		if ($file =~ /^JagexAppletViewerJarFile/i)
		{
			# Copy the jagexappletviewer.jar to $placejar
			rsu::files::copy::print_cp("$clientdir/.download/extracted_files/$file", "$clientdir/$placejar/jagexappletviewer.jar");
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
			rsu::files::copy::print_cp("$clientdir/.download/extracted_files/$file", "$clientdir/rsu/3rdParty/Win32/$destfile");
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
	rsu::files::copy::print_cp("$clientdir/.download/extracted_files/jagexappletviewer.jar", "$clientdir/$placejar/jagexappletviewer.jar");
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
