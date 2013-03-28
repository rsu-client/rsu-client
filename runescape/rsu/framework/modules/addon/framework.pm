package addon::framework;

# Use LWP::Simple so that people can read text from the web
use LWP::Simple;

# Load some default API modules
require rsu::files::clientdir;
require updater::download::file;
require rsu::extract::archive;
require rsu::files::IO;


# Framework functions #
#######################

sub execr
{
	# Get the passed data
	my ($cmd, $params) = @_;
	
	# Make a variable for output
	my $output;
	
	# If parameters are passed
	if (defined $params && $params ne '')
	{
		# Run the command with parameters
		$output = `$cmd $params`;
	}
	# Else
	else
	{
		# Run the command
		$output = `$cmd`;
	}
	
	# Return the output
	return $output;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub run
{
	# Get the passed data
	my ($cmd, $params) = @_;
	
	# Get the current OS
	my $OS = "$^O";
	
	# If parameters are passed
	if (defined $params && $params ne '')
	{
		# Run the command with parameters
		system "$cmd $params &" if $OS !~ /MSWin32/;
		system(1,"$cmd $params") if $OS =~ /MSWin32/;
	}
	# Else
	else
	{
		# Run the command
		system "$cmd &" if $OS !~ /MSWin32/;
		system(1,"$cmd") if $OS =~ /MSWin32/;
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub runwait
{
	# Get the passed data
	my ($cmd, $params) = @_;
	
	# If parameters are passed
	if (defined $params && $params ne '')
	{
		# Run the command with parameters
		system "$cmd $params";
	}
	# Else
	else
	{
		# Run the command
		system "$cmd";
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub java
{
	# Get the passed data
	my ($params) = @_;
	
	# Require the jre module
	require rsu::java::jre;
	
	# Make a variable for output
	my $output;
	
	# Make a varable to contain the java binary
	my $javabin;

	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Locate the java.exe on windows
		$javabin = rsu::java::jre::win32_find_java("default-java");
	}
	# Else
	else
	{
		# Get the absolute PATH to the binary
		$javabin = rsu::java::jre::findjavabin("default-java");
		
		# If the absolute path is the system java from $PATH
		if ($javabin =~ /^java$/)
		{
			# Probe for the binary
			$javabin = rsu::java::jre::unix_find_default_java_binary($javabin);
			
			# Check if clientmode is available
			$javabin = rsu::java::jre::check_client_mode($javabin);
		}
		# Else
		else
		{
			# Check if clientmode is available
			$javabin = rsu::java::jre::check_client_mode($javabin);
		}	
	}
	
	# If parameters are passed
	if (defined $params && $params ne '')
	{
		# Run the command with parameters
		$output = `$javabin $params`;
	}
	# Else
	else
	{
		# Run the command
		$output = `$javabin`;
	}
	
	# Return the output
	return $output;
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
