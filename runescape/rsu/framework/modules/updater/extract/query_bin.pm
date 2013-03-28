package updater::extract::query_bin;

# Use the Cwd module so we can get the current working directory
use Cwd;

# Get the cwd
my $cwd = getcwd;
	
# Include Config module for checking system values
use Config;

# Use the File::Path module so we can make and remove paths
use File::Path qw(make_path remove_tree);

# Require the files grep module
require rsu::files::grep;

# Require the files copy module
require rsu::files::copy;

# Require the clientdir module
require rsu::files::clientdir;

# Require the extract archive module
require rsu::extract::archive;

# Require the download file module
require updater::download::file;
	
# Get the clientdir
my $clientdir = rsu::files::clientdir::getclientdir();

# Get the current OS
my $OS = "$^O";

sub update
{
	# Get the passed data
	my ($nogui) = @_;
	
	# Make default action be update
	my $install = 0;
	
	# If no gui is requested
	if (defined $nogui && $nogui eq '1')
	{
		# Enable installation
		$install = 1;
	}
	
	# If we are not on windows
	if ($OS !~ /MSWin32/)
	{
		# Get the architecture
		my $arch = $Config{archname};
		
		# If we are not on windows or mac
		if ($OS !~ /(MSWin32|darwin)/)
		{
			# If we are on 64bit
			if ($arch =~ /(x86_64|amd64)/ && $OS =~ /linux/)
			{
				# Use x86_64 as architecture
				$arch = "x86_64";
			}
			# Else if we are on 32bit
			elsif($arch =~ /i\d{1,1}86/ && $OS =~ /linux/)
			{
				# Use i386 as architecture
				$arch = "i386";
			}
			# Else
			else
			{
				# Return to call
				return 0;
			}
			
			# If the file exists or $install is 1 then
			if ((-e "$clientdir/rsu/bin/rsu-query-$OS-$arch") || ($install eq '1'))
			{
				# Fetch the binary and install it
				updater::extract::query_bin::fetch("rsu-query-$OS-$arch", $install);
			}
		}
		# Else if we are on MacOSX
		elsif($OS =~ /darwin/)
		{
			# If the file exists or $install is 1 then
			if ((-e "$clientdir/rsu/bin/rsu-query-$OS") || ($install eq '1'))
			{
				# Fetch the binary and install it
				updater::extract::query_bin::fetch("rsu-query-$OS", $install);
			}
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetch
{
	# Get the passed data
	my ($name, $install) = @_;
	
	# Make a variable that says we will use the gui download
	my $nogui = '0';
	
	# If $install is passed and is 1
	if (defined $install && $install eq '1')
	{
		# Set $nogui to 1 so that we do not have to rely on a gui
		$nogui = $install;
		
		# Make the download directory
		make_path("$clientdir/.download");
		
		# Download the archive file containing the binary
		updater::download::file::from("https://github.com/HikariKnight/rsu-launcher/archive/$name-latest.tar.gz", "$clientdir/.download/$name-latest.tar.gz", $nogui);
	}
	else
	{
		# Download the archive file containing the new binary in a new process
		system("\"$cwd/rsu/rsu-query\" rsu.download.file https://github.com/HikariKnight/rsu-launcher/archive/$name-latest.tar.gz \"$clientdir/.download\"");
	}
				
	# Extract the archive
	rsu::extract::archive::extract("$clientdir/.download/$name-latest.tar.gz", "$clientdir/.download/extracted_binary");
	
	# Backup solution
	#system("\"$clientdir/rsu/rsu-query\" rsu.extract.file $name-latest.zip \"$clientdir/.download/extracted_binary\"");
				
	# Locate the binary
	my @binary;
	
	# If we are on MacOSX and the rsu-query-darwin is not installed from before then
	if ($OS =~ /darwin/ && !-e "$cwd/rsu/bin/rsu-query-$OS")
	{
		# Assign a hardcoded path as apple have messed up their perl installation (YAY!)
		$binary[0] = "$clientdir/.download/extracted_binary/rsu-launcher-rsu-query-darwin-latest/rsu-query-darwin";
	}
	# Else
	else
	{
		# Dynamically locate the binary
		@binary = rsu::files::grep::rdirgrep("$clientdir/.download/extracted_binary", "\/$name\$");
	}
				
	# Copy the binary
	rsu::files::copy::print_cp($binary[0],"$cwd/rsu/bin/$name");
	
	# Make the file executable
	system "chmod +x \"$cwd/rsu/bin/$name\"";
	
	# If $nogui = 1 then
	if ($nogui eq '1')
	{
		# Remove the download directory
		remove_tree("$clientdir/.download");
	}
	
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
