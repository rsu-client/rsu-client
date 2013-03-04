package get::java::lib;

if ("@ARGV" =~ /\s+help(|\s+)/)
{
	print "API call to find the currently selected java's library folder
Syntaxes (parts with [ infront of them are optional):
	$ARGV[0] help
	$ARGV[0]
	$ARGV[0] [filename.conf [\"directory\"

Examples:
	$ARGV[0]
	result: a 1 line string with the absolute path to the java's library folder
	failure: returns the string \"undef\"
	
Remarks:
	Returns a 1 line string, however you might get a newline at the end
	from the STDOUT.

Purpose:
	Simplify the task of locating the java binary
"
}
# Else
else
{
	# Use Cwd so we can use abs_path
	use Cwd 'abs_path';
	
	# Require the files IO module
	require rsu::files::IO;

	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Require the jre module used to find java
	require rsu::java::jre;
	
	# Require the opengl module used to find the java library
	require rsu::java::opengl;
	
	# Get the current OS
	my $OS = "$^O";

	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();

	# Make a variable to contain the location
	my $location = "$clientdir/share";
	
	# Make a variable to contain the filename
	my $file = "settings.conf";
	
	# If a 2nd parameter is passed
	if ($ARGV[1] ne '')
	{
		# If the parameter starts with a full path or variable
		if ($ARGV[1] =~ /^(\$|\%|[a-z]:|\/)/i)
		{
			# Use parameter as location
			$location = $ARGV[1];
		}
		# Else if the parameter ends with .conf
		elsif($ARGV[1] =~ /\.conf$/)
		{
			# Use the parameter as file
			$file = $ARGV[1];
			
			# If the 3rd parameter is passed
			if ($ARGV[2] ne '')
			{
				# If the parameter starts with a full path or variable
				if ($ARGV[2] =~ /^(\$|\%|[a-z]:|\/)/i)
				{
					# Use parameter as location
					$location = $ARGV[2];
				}
				# Else
				else
				{
					# Use the parameter as foldername
					$location = "$clientdir/$ARGV[2]";
				}
			}
		}
		# Else
		else
		{
			# Use the parameter as foldername
			$location = "$clientdir/$ARGV[1]";
		}
	}
	
	# Make a varable to contain the java binary
	my $javabin;
	
	# Make a variable to contain the java library
	my $javalib;

	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Get the contents of the prmfile
		$javabin = rsu::files::IO::readconf("win32java.exe", "undef", $file, "$location");
		
		# If undef then
		if ($javabin =~ /^undef$/)
		{
			# Print undef to STDOUT
			print "undef\n";
			
			# Then exit
			exit;
		}
		
		# Locate the java.exe on windows
		$javalib = rsu::java::jre::win32_find_java($javabin);
		
		# Remove \java.exe from the library path
		$javalib =~ s/\\java\.exe//ig;
	}
	# Else
	else
	{
		# Get the contents of the prmfile
		$javabin = rsu::files::IO::readconf("preferredjava", "undef", $file, "$location");
		
		# If undef then
		if ($javabin =~ /^undef$/)
		{
			# Print undef to STDOUT
			print "undef\n";
			
			# Then exit
			exit;
		}
		
		# Get the absolute PATH to the binary
		$javabin = rsu::java::jre::findjavabin($javabin);
		
		# If the absolute path is the system java from $PATH
		if ($javabin =~ /^java$/)
		{
			# Probe for the binary
			$javabin = rsu::java::jre::unix_find_default_java_binary($javabin, $location, $file);
			
			# Get the path to the library
			$javalib = rsu::java::opengl::unix_findlibrarypath($javabin);
		}
		# Else
		else
		{
			# Get the path to the library
			$javalib = rsu::java::opengl::unix_findlibrarypath($javabin);
		}
		
		# Remove LD_LIBRARY_PATH= from the string
		$javalib =~ s/^LD_LIBRARY_PATH=//;
	}
	
	# If we are on windows
	if ($OS =~ /MSWin32/)
	{
		# Replace all / with \
		$javabin =~ s/\//\\/g;
	}
	
	# Print the javabin to STDOUT
	print abs_path($javalib)."\n";
}

1; 
 
