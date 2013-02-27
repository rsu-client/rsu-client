package apiquery;

# Be strict to avoid messy code
use strict;

# Use FindBin module to get script directory
use FindBin;

# use Cwd to get current working directory
use Cwd;
our $cwd = getcwd;

# Use custom libs
use lib getcwd."/framework/API";
use lib getcwd."/framework/modules";

# Use the perl5lib (containing raw perl modules copied from cpan)
use lib getcwd."/framework/Perl5lib";

# Get script directory
our $scriptdir = $FindBin::RealBin;
# Get script filename
our $scriptname = $FindBin::Script;
# Detect the current OS
our $OS = "$^O";
	
# run the script
main();

sub main
{
	# Change dir to the parent directory
	chdir("$cwd/..");
	
	# Get the call for the api
	my $apicall = $ARGV[0];
	# Convert to perl module call
	$apicall =~ s/\./::/g;
	
	# Remove $ARGV[0]
	#s/$ARGV[0]//g for @ARGV;
	
	# Try to run the module and warn if execution failed
	eval "use $apicall"; warn if $@;
	
	# Exit script
	exit;
}

#
#---------------------------------------- *** ----------------------------------------
#
1;
