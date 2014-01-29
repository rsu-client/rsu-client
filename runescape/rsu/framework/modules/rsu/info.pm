# This Perl module is ment to be used in order to fetch/read
# information about the RSU-Client like it's version number.
# More features will come soon
package rsu::info;

# All functions in this module requires these modules
require rsu::files::IO;
require rsu::files::grep;
require rsu::files::dirs;
require rsu::files::clientdir;

# Use the module for getting the current working directory
use Cwd;

# Get the cwd
my $cwd = getcwd;

# Get the resource directory for this script
my $resourcedir = "$cwd/rsu/framework/resources/rsu/info";

sub getVersion
{
	# Get the versioninfo
	my $version = rsu::files::IO::iniRead("$resourcedir/details.conf", "Info", "Version", "0.0");
	
	# Return the version
	return $version;
}

#
#---------------------------------------- *** ----------------------------------------
#

1;