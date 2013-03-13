package updater::extract::query_bin;
	
# Include Config module for checking system values
use Config;

# Require the files grep module
require rsu::files::grep;

# Require the files copy module
require rsu::files::copy;

# Require the clientdir module
require rsu::files::clientdir;
	
# Get the clientdir
my $clientdir = rsu::files::clientdir::getclientdir();

# Get the current OS
my $OS = "$^O";

sub update
{
	# Get the passed data
	my ($install) = @_;
	
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
			if ((-e "$clientdir/rsu/bin/rsu-query-$OS-$arch") || (defined $install && $install eq '1'))
			{
				# Fetch the binary and install it
				updater::extract::query_bin::fetch("rsu-query-$OS-$arch");
			}
		}
		# Else if we are on MacOSX
		elsif($OS =~ /darwin/)
		{
			# If the file exists or $install is 1 then
			if ((-e "$clientdir/rsu/bin/rsu-query-$OS") || (defined $install && $install eq '1'))
			{
				# Fetch the binary and install it
				updater::extract::query_bin::fetch("rsu-query-$OS");
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
	my ($name) = @_;
	
	# Download the archive file containing the new binary
	system("\"$clientdir/rsu/rsu-query\" rsu.download.file https://github.com/HikariKnight/rsu-launcher/archive/$name-latest.zip \"$clientdir/.download\"");
				
	# Extract the archive
	system("\"$clientdir/rsu/rsu-query\" rsu.extract.file $name-latest.zip \"$clientdir/.download/extracted_binary\"");
	#rsu::extract::archive::extract("$clientdir/.download/$name-latest.tar.gz", "$clientdir/.download/extracted_binary");
				
	# Locate the binary
	my @binary = rsu::files::grep::rdirgrep("$clientdir/.download/extracted_binary", "\/$name\$");
				
	# Copy the binary
	rsu::files::copy::print_cp($binary[0],"$clientdir/rsu/bin/$name");
}

#
#---------------------------------------- *** ----------------------------------------
#



1; 
