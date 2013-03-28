package platform::info;

# Use the Config module so we can get some info about this perl install
use Config;

# Get the current OS
my $OS = "$^O";

sub architecture
{
	# Get the architecture
	my $arch = $Config{archname};
	
	# If we are on windows
	if($OS =~ /MSWin32/)
	{
		# Get the architecture from the environment
		$arch = $ENV{"PROCESSOR_ARCHITECTURE"};
	}
	
	# If we are on 64bit
	if ($arch =~ /(x86_64|amd64)/i)
	{
		# Use x86_64 as architecture
		$arch = "x86_64";
	}
	# Else if we are on 32bit
	elsif($arch =~ /i\d{1,1}86/i)
	{
		# Use i386 as architecture
		$arch = "i386";
	}
	# Elsif we are not on 32 or 64bit and not on Windows then
	elsif($arch !~ /(\d{1,1}86|x86_64|amd64)/i && $OS !~ /MSWin32/)
	{
		# Get the architecture from uname -m
		$arch = `uname -m`;
		
		# Remove newlines
		$arch =~ s/(\n|\r)//g;
	}
	
	# Return the architecture
	return $arch;
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
