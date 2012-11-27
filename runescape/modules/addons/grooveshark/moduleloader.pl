#!/usr/bin/perl -w

# Be strict to avoid messy code
use strict;

# Name of module
my $modulename = "grooveshark";

# Use FindBin module to get script directory
use FindBin;

# Get script directory
my $cwd = $FindBin::RealBin;
# Get script filename
my $scriptname = $FindBin::Script;
# Detect the current OS
my $OS = "$^O";
	
# run the script
main();

sub main
{
	# Replace whitespaces with "\ "
	$cwd =~ s/\s{1}/\\\ /g;
	
	# Make a variable for the architecture
	my $arch;
	
	# If we are on linux
	if ($OS =~ /linux/)
	{
		# Get the architecture
		$arch = `uname -m`;
		
		# If we are on 64bit
		if ($arch =~ /(x86_64|amd64)/)
		{
			# Use x86_64 as architecture
			$arch = "-x86_64";
		}
		# Else
		else
		{
			# Use i386 as architecture
			$arch = "-i386";
		}
	}
	
	# Run module
	system "LD_LIBRARY_PATH=$cwd/../framework/lib-$OS$arch $cwd/$modulename-$OS$arch &";
}

#
#---------------------------------------- *** ----------------------------------------
#

