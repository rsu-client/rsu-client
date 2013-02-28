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

# Check if it is an addon that is called or an API
if ($ARGV[0] =~ /^addon\./)
{
	# Launch the addon in its own environment
	launch_addon();
}
# Else
else
{
	# Run the main function which is just calling the API
	main();
}

#
#---------------------------------------- *** ----------------------------------------
#

sub main
{
	# Change dir to the parent directory
	chdir("$cwd/..");
	
	# Get the call for the api
	my $apicall = $ARGV[0];
	# Convert to perl module call
	$apicall =~ s/\./::/g;
	
	# Try to run the module and warn if execution failed
	eval "use $apicall"; warn if $@;
	
	# Exit script
	exit;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub launch_addon
{
	# Change dir to the parent directory
	chdir("$cwd/..");
	
	# Get the call for the api
	my $addon = $ARGV[0];
	# Convert to perl module call
	$addon =~ s/addon\.//g;
	
	# Try to run the module and warn if execution failed
	eval "use ".$addon."::moduleloader"; warn if $@;
	
	# Change dir to the parent directory
	chdir("$cwd/..");
	
	# Exit script
	exit;
}

#
#---------------------------------------- *** ----------------------------------------
#


1;
