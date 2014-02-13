# This modules deals with finding the java binary to run the client
package rsu::java::jre;

	sub findjavabin
	{
		# Get the data container
		my ($preferredjava) = @_;
		
		# Get the current OS
		my $OS = "$^O";
		
		# If we are not run through an API call
		if ($ARGV[0] !~ /^(get|set)\..+/)
		{
			# Print debug info
			print "I will now check what platform you are using\nand use the correct java path for that platform\n\n";
		}
		
		# Define the variable for javabin
		my $javabin;
		
		# Define a variable to contain a boolean(true/false) to see if openjdk exists
		my $openjdk;
		
		# If we are on mac osx (AKA Darwin)
		if ($OS =~ /darwin/)
		{
			# If we are not run through an API call
			if ($ARGV[0] !~ /^(get|set)\..+/)
			{
				# Print debug info
				print "You are running darwin/MacOSX.\nI will use Apple Java6 if it exists\notherwise we will use the Java from PATH\n";
			}
			
			# javabin is /usr/bin/java
			$javabin = "/usr/bin/java";
			
			# Check the version of java installed in the Frameworks in OSX (this is where apple dumps its java)
			my $applejavaexist = `/System/Library/Frameworks/JavaVM.framework/Commands/java -version 2>&1 | grep "java version"`;
			
			# If Apple Java is version 1.6.0_* then
			if ($applejavaexist =~ /1\.6\.0_*/)
			{
				# Use the Apple Java as javabin (and avoid java7 until apple actually removes java6)
				$javabin = "/System/Library/Frameworks/JavaVM.framework/Commands/java";
			}
		}
		# Else if we are on linux
		elsif($OS =~ /linux/)
		{
			# If we are not run through an API call
			if ($ARGV[0] !~ /^(get|set)\..+/)
			{
				# Print debug info
				print "You are running ".$OS.", I will probe for OpenJDK6 or newer\nand use the newest version if possible.\n\n";
			}
			
			# run "find /usr/lib/jvm/ -name java" to see if we can find openjdk by using grep
			$openjdk = `find -L /usr/lib/jvm/ -name "java" |grep -P "$preferredjava(|-amd64|-i386|-\$\(uname -i\))/bin"`;
			
			# if $openjdk is found (hurray!)
			if ($openjdk =~ /java-\d{1,1}-openjdk(|-\$\(uname -p\)|-i386|-amd64)/)
			{
				# If we are not run through an API call
				if ($ARGV[0] !~ /^(get|set)\..+/)
				{
					# Print debug info
					print "Found OpenJDK files, now checking for the newest installed one.\n";
				}
				
				# Split the string by newline incase openjdk-7 was found
				my @openjdkbin = split /\n/, $openjdk;
				
				# If we are not run through an API call
				if ($ARGV[0] !~ /^(get|set)\..+/)
				{
					# Print debug info
					print "Checking which OpenJDK versions are installed...\n\n";
				}
				
				# Run a check to see if we detected openjdk7
				my $detectedopenjdk7 = grep { $openjdkbin[$_] =~ /java-\d{1,1}-openjdk-(\$\(uname -p\)|i386|amd64)/ } 0..$#openjdkbin;
				
				# If openjdk7 was not found
				#if ($openjdkbin[$index] !~ /java-\d{1,1}-openjdk-(\$\(uname -p\)|i386|amd64)/)
				if($detectedopenjdk7 =~ /0/)
				{
					# If we are not run through an API call
					if ($ARGV[0] !~ /^(get|set)\..+/)
					{
						# Print debug info
						print "OpenJDK6 detected!, I will use this to run the client!\n";
					}
					
					# we will use openjdk6 to launch it (openjdk does not have sfx problems like sun-java)
					$javabin = "$openjdkbin[0] ";
				}
				else
				{
					# If we are not run through an API call
					if ($ARGV[0] !~ /^(get|set)\..+/)
					{
						# Print debug info
						print "OpenJDK7 detected!, I will use this to run the client!\n";
					}
					
					# Find the index of OpenJDK7
					my @openjdk7index = grep { $openjdkbin[$_] =~ /java-\d{1,1}-openjdk-(\$\(uname -p\)|i386|amd64)/ } 0..$#openjdkbin;
					
					# We will use openjdk7 to launch it (openjdk does not have sfx problems like sun-java)
					$javabin = "$openjdkbin[$openjdk7index[0]] ";
				}
			}		
			else
			{
				# If we are not run through an API call
				if ($ARGV[0] !~ /^(get|set)\..+/)
				{
					# Print debug info
					print "I did not find any version of OpenJDK in /usr/lib/jvm\nI will instead use the default java in \$PATH\n";
				}
				
				# if openjdk is not found then we will use default java (lets pray it is in the $PATH)
				$javabin = "java";
			}
		}
		# Else we are running bsd or solaris (both should have java in their $PATH)
		else
		{
			# If we are not run through an API call
			if ($ARGV[0] !~ /^(get|set)\..+/)
			{
				# Print debug info
				print "You are running ".$OS.", I will use the default java on your system\n\n";
			}
			
			# We just use the one from $PATH
			$javabin = "java";
		}
		
		# Run a symlink check to make sure we got the binary
		$javabin = rsu::java::jre::symlinkcheck($javabin);
		
		# Return to call with the java executable
		return $javabin;
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#

	sub check_client_mode
	{
		# Gets passed data from the function call
		my ($java_binary) = @_;
		
		# Execute java -help and see if this java have the -client parameter available
		my $results = `$java_binary -help 2>&1`;
		
		# If the -client parameter is an option
		if ($results =~ /-client/)
		{
			# Tell java to execute in client mode
			$java_binary = "$java_binary -client";
		}
		
		# Return the results
		return "$java_binary";
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#

	sub unix_find_default_java_binary
	{
		# Get passed data
		my ($javabin, $settingsdir, $conffile) = @_;
		
		# Get the current OS
		my $OS = "$^O";
		
		# Require the clientdir module to get the client directory
		require rsu::files::clientdir;
		
		# Make a variable to contain the clientdir
		my $dir;
		
		# If a different clientdir is passed
		if (defined $settingsdir)
		{
			# Pass the value over to $clientdir
			$dir = $settingsdir;
		}
		# Else
		else
		{
			# Get the clientdir/share/configs folder
			$dir = rsu::files::clientdir::getclientdir()."/share/configs";
		}
		
		# Make a variable to contain the settingsfile name
		my $settingsfile = "settings.conf";
		
		# If a different settingsfile is specified
		if (defined $conffile)
		{
			# Pass the value to $settingsfile
			$settingsfile = $conffile;
		}
		
		# Make a variable for the location of the java in path
		my $whereisjava;
		
		# If our os is linux or freebsd
		if ($OS =~ /(linux|freebsd)/)
		{
			# Ask where the java executable is
			$whereisjava = `whereis java | sed "s/java:\\ //" | sed "s/\\ .*//"`;
		}
		# Else if we are on solaris
		elsif($OS =~ /(solaris)/)
		{
			# Return the default symlink location (since solaris have the libjli.so linked properly)
			return "/usr/bin/java";
		}
		
		# Run a symlink check to make sure we got the binary
		$whereisjava = rsu::java::jre::symlinkcheck($whereisjava);
		
		# Do a final check to see if the java binary is found...
		# If $whereisjava do not end with /bin/java then
		if ($whereisjava !~ /\/bin\/java$/)
		{
			# Run a function which will tell the user what to do in order to fix this issue
			$whereisjava = rsu::java::jre::unix_default_java_is_a_script($javabin, $dir, $conffile);
		}
		
		# Return the true default java binary
		return "$whereisjava";
	}

	#
	#---------------------------------------- *** ----------------------------------------
	#

	sub unix_default_java_is_a_script
	{	
		# This function depends on rsu_IO.pm
		require rsu::files::IO;
		
		# Get passed data
		my ($javabin, $settingsdir, $conffile) = @_;
		
		# Use the Cwd module to get the current working directory
		use Cwd;
		
		# Pass the current directory to a variable for use in a message
		my $cwd = getcwd;
		
		# Require the clientdir module to get the client directory
		require rsu::files::clientdir;
		
		# Make a variable to contain the clientdir
		my $clientdir;
		
		# If a different clientdir is passed
		if (defined $settingsdir)
		{
			# Pass the value over to $clientdir
			$clientdir = $settingsdir;
		}
		# Else
		else
		{
			# Get the clientdir/share/configs folder
			$clientdir = rsu::files::clientdir::getclientdir()."/share/configs";
		}
		
		# Make a variable to contain the settingsfile name
		my $settingsfile = "settings.conf";
		
		# If a different settingsfile is specified
		if (defined $conffile)
		{
			# Pass the value to $settingsfile
			$settingsfile = $conffile;
		}
		
		# Define any large messages we will need in the script
		# Message if java in $PATH is not a binary
		my $java_not_bin = << "java_not_binary_message";
It looks like your default java is not a binary file!
This script requires direct use of the java BINARY file
in order to make sure all the java library files gets loaded properly.
Please edit $clientdir/settings.conf
and add the path to the java BINARY as the value for preferredjava.

You can use the command (You can find this text inside /tmp/java_notice.txt):
sudo find / -name "libjli.so" | sed "s/\\/lib\\/\\(i386\\|amd64\\)\\/jli\\/libjli.so/\\/bin\\/java/g"

In order to get a list of possible paths you can use as the preferredjava value.
Also please look at $cwd/share/settings.conf.example
for examples on the setting values.

Please press ENTER/RETURN to continue running the script 
after you added the path to the binary into the 
$cwd/share/settings.conf file.

java_not_binary_message
		
		# Make a variable to contain the new java path
		my $newjavapath;
		
		# if we are inside an interactive shell then
		if (-t STDOUT)
		{
			# Write the java notice to a file
			rsu::files::IO::WriteFile($java_not_bin, ">", "/tmp/java_notice.txt");
			
			# Display the message
			print $java_not_bin;
			
			# Wait for user to press ENTER/RETURN
			my $continue = <STDIN>;
			
			# remove the notice
			system "rm /tmp/java_notice.txt";
			
			# Read the preferred java in the config file, if nothing is found then say JAVA NOT SET
			$newjavapath = rsu::files::IO::readconf("preferredjava", "JAVA NOT SET", $settingsfile, $clientdir);		
		}
		else
		{
			# Write the java notice to a file
			rsu::files::IO::WriteFile($java_not_bin, ">", "/tmp/java_notice.txt");
			
			# run script in xterm so we can get input from user and with right permissions
			system "xterm -e \"cat /tmp/java_notice.txt && read i\"";
			
			# remove the notice
			system "rm /tmp/java_notice.txt";
			
			# Read the preferred java in the config file, if nothing is found then say JAVA NOT SET
			$newjavapath = rsu::files::IO::readconf("preferredjava", "JAVA NOT SET", $settingsfile, $clientdir);
		}
		
		# If java is still not set
		if ($newjavapath =~ /JAVA NOT SET/)
		{
			# Tell user whats wrong and then exit
			print STDERR "You did not set the path to java in the preferredjava setting\ninside $clientdir/$settingsfile\nThe client will not work for you without this setting... EXITING!\n";
			exit
		}
		
		# return the new javapath
		return "$newjavapath";
	}

#
#---------------------------------------- *** ----------------------------------------
#

sub win32_find_java
{
	# Require the grep module
	require rsu::files::grep;
	
	# Gets passed data from the function call
	my ($win32java_setting) = @_;
	
	# Make an array for the current version
	my $currentversion = "6";
	
	# If the win32java setting is default-java
	if ($win32java_setting =~ /default-java/)
	{
		# Run a registry query and grep for the current java version (example: 1.6)
		$currentversion = `reg query \"hklm\\Software\\JavaSoft\\Java Runtime Environment\" /v CurrentVersion`;
		
		# Run a string grep query
		my @currentversion = rsu::files::grep::strgrep($currentversion, "CurrentVersion");
		
		# Convert array to string
		$currentversion = "@currentversion";
		
		# Remove all tabs, whitespace and newlines and the 1. and also remove REG_SZ and everything before that from the last array entry
		$currentversion =~ s/(.+REG_SZ|\n\r|\r|\n|\s+|\t+|1\.)//g;
	}
	else
	{
		# Prepare the win32java setting so that we only get the number we want
		$win32java_setting =~ s/(\d{1,1}\.|\.\d{1,2}_\d{1,2})//g;
		
		# Set the currentversion_array content to be the same as the win32java setting
		$currentversion = $win32java_setting;
	}
	
	# Make the string Java#FamilyVersion
	my $javafamily = "Java$currentversion"."FamilyVersion";
	
	# Use the current version to run a new registry query and grep for Java#FamilyVersion (replace # with number)
	my $javafamilyversion = `reg query \"hklm\\Software\\JavaSoft\\Java Runtime Environment\" /v $javafamily`;
	
	# Run a string grep query
	my @javafamilyversion = rsu::files::grep::strgrep($javafamilyversion, $javafamily);
	
	# Convert array to string
	$javafamilyversion = "@javafamilyversion";
	
	# Remove all tabs, whitespace and newlines and also remove REG_SZ and everything before that from the last array entry
	$javafamilyversion =~ s/(.+REG_SZ|\n\r|\r|\n|\s|\t|\s+)//g;
	
	# Use the javafamilyversion to run a new registry querty and grep for JavaHome which contains the location of the java installation
	my $javahome = `reg query \"hklm\\Software\\JavaSoft\\Java Runtime Environment\\$javafamilyversion\" /v JavaHome`;
	
	# Run a string grep query
	my @javahome = rsu::files::grep::strgrep($javahome, "JavaHome");
	
	# Convert array to string
	$javahome = "@javahome";
	
	# Split the result by REG_SZ and add everything to an array
	my @javahome_array = split(/REG_SZ/i, $javahome);
	# Remove all tabs, whitespace and newlines and also remove REG_SZ and everything before that from the last array entry
	$javahome_array[-1] =~ s/(.+REG_SZ|\n\r|\r|\n|\t+|\s{2,10})//g;
	
	# Put together the path to the java.exe
	my $javabin_result = "$javahome_array[-1]\\bin\\java.exe";
	
	# Return the result
	return $javabin_result;
}

#
#---------------------------------------- *** ----------------------------------------
#

sub symlinkcheck
{
	# Get the passed data
	my ($javabin) = @_;
	
	# Remove the newline at the end of the string
	chomp($javabin);
	# Backup solution incase chomp fails
	$javabin =~ s/\s+$//;
	
	# If we are not run through an API call
	if ($ARGV[0] !~ /^(get|set)\..+/)
	{
		# Print debug info and tell user what we are doing
		print "Locating the binary that $javabin is symlinked to.\n";
	}
	
	# Make a variable to contain the symlink
	my $javasymlink = $javabin;
	
	# Follow symlinks til we locate the binary
	while(-l $javabin)
	{
		# Read the symlink and get the path it is linking to
		$javabin = readlink $javabin;
		
		# If the symlink points to a relative location
		if ($javabin =~ /^\.\./)
		{
			# Fix it so that its a path we can use
			my $javafix = $javasymlink;
			
			# Make the relative path an absolute path
			$javafix =~ s/java$/$javabin/;
			
			# Transfer the path to the $javabin variable
			$javabin = $javafix;
		}
		
		# If we are not run through an API call
		if ($ARGV[0] !~ /^(get|set)\..+/)
		{
			# Tell where the symlink is pointing to
			print "$javasymlink -> $javabin\n";
		}
		
		# Update the $javasymlink
		$javasymlink = $javabin;
	}
	
	# If we are not run through an API call
	if ($ARGV[0] !~ /^(get|set)\..+/)
	{
		# Tell that we located the java binary
		print "Java binary located: $javabin\n\n";
	}
	
	# Return the actual binary
	return $javabin;
}

#
#---------------------------------------- *** ----------------------------------------
#
	

1;
