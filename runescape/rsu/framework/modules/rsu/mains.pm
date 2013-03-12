package rsu::mains;

# All functions in this module requires these modules
require rsu::java::jre;
require client::settings::prms;
require rsu::files::clientdir;

sub unix_main
{
	# This function requires rsu_primusrun (for use on linux optimus pcs with bumblebee+primus installed)
	require rsu::nvidia::optimus;
	
	# Get the data container
	my $rsu_data = shift;
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Get the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Check if user have a preferred java on unix
	# If user want to use default-java then
	if (($rsu_data->preferredjava =~ /default-java/))
	{
		# Use default java
		$rsu_data->javabin = "java";
		
		# If we are not on mac (mac does not have opengl issues with java7)
		if ($rsu_data->OS !~ /darwin/)
		{
			# Search for the location of the true default java binary (not the symlink)
			$rsu_data->javabin = rsu::java::jre::unix_find_default_java_binary($rsu_data->javabin, "$clientdir/share/configs", "settings.conf");
		}
		# Else we are on mac
		else
		{
			# Probe for Java6 and use that instead of Java7 (if Java6 exists)
			$rsu_data->javabin = rsu::java::jre::findjavabin($rsu_data->preferredjava);
		}		
	}
	# Else if user have set a custom path to a java binary (most likely sun/oracle java)
	elsif (($rsu_data->preferredjava =~ /^\//))
	{
		# Use the user set java binary
		$rsu_data->javabin = $rsu_data->preferredjava;
	}
	
	# Else just check what java to use
	else
	{
		# Find the java executable
		$rsu_data->javabin = rsu::java::jre::findjavabin($rsu_data->preferredjava);
	}
	
	
	# Get the language setting
	my $params = client::settings::prms::parseprmfile($rsu_data->prmfile);
	
	# Make a variable to contain the java library path
	my $javalibpath;
	
	# If we are not on MacOSX
	if ($rsu_data->OS !~ /darwin/)
	{
		# Locate the java JRE lib folder so we can add it to the library PATH
		$javalibpath = rsu::java::opengl::unix_findlibrarypath($rsu_data->javabin);
	}
	
	# Check if java can be run in client mode and make sure we use the client mode if available
	# as the client mode gives a HUGE boost in performance compared to the default server mode.
	$rsu_data->javabin = rsu::java::jre::check_client_mode($rsu_data->javabin);
	
	# Pass the java binary to a variable so we can use it in commands
	my $javabin = $rsu_data->javabin;
	
	# If user enabled alsa sounds and OS is linux
	if ($rsu_data->forcealsa =~ /(1|true)/i && $rsu_data->OS =~ /linux/)
	{
		# Run the java -version command and check if it is openjdk or java (both uses different alsa fixes)
		$rsu_data->javaversion = `$javabin -version 2>&1`;
		
		# Pass the result to a new variable
		my $javaused_result = $rsu_data->javaversion;
		
		# If java used is sun/oracle java
		if ($javaused_result =~ /Java\(TM\) SE/i)
		{
			# Make a variable for aoss
			my $aoss = "aoss";
			
			# Check /usr/bin for aoss32
			my $aosstest = `ls /usr/bin | grep aoss32`;
			
			# Check if $javabin contains the -client parameter and aoss32 was found
			if($rsu_data->javabin =~ /-client/ && $aosstest =~ /aoss32/)
			{
				# Use aoss32 instead of aoss
				$aoss = "aoss32";
			}
			
			# Wrap java inside aoss (alsa wrapper)
			$rsu_data->javabin = "$aoss ".$rsu_data->javabin;
		}
		# Else we are using openjdk
		else
		{
			# Tell OpenJDK to use alsa (aoss does not work as OpenJDK is usually set to use pulseaudio over alsa)
			$rsu_data->javabin = $rsu_data->javabin." -Djavax.sound.sampled.Clip=com.sun.media.sound.DirectAudioDeviceProvider -Djavax.sound.sampled.Port=com.sun.media.sound.PortMixerProvider -Djavax.sound.sampled.SourceDataLine=com.sun.media.sound.DirectAudioDeviceProvider -Djavax.sound.sampled.TargetDataLine=com.sun.media.sound.DirectAudioDeviceProvider";
		}
		# Set forcepulseaudio to false so that java dont get wrapped in pulse and alsa (chaotic results)
		$rsu_data->forcepulseaudio = 0;
	}	
	# Else if user requested to force use pulseaudio
	elsif ($rsu_data->forcepulseaudio =~ /(1|true)/i && $rsu_data->OS !~ /darwin/)
	{
		# Print debug info
		print "Forcing java to use pulseaudio by wrapping it inside \"padsp\"!\n";
		
		# Then edit $javabin into "padsp $javabin"
		$rsu_data->javabin = "padsp ".$rsu_data->javabin;
	}
	
	# Display java version we are using
	print "Launching client using this java version: \n";
	
	# Display the java version
	system $rsu_data->javabin." -version 2>&1 && echo";
	
	# Make a variable to contain the MacOSX integration (app icon and name)
	my $osxprms = "";
	
	# If we are on macosx/darwin then
	if ($rsu_data->OS =~ /darwin/)
	{
		# Print debug info
		print "Adding application name and icon to the dock.\n";
		
		# Add the dock icon and dock name to the variable, so that it will be used in the java execution
		$osxprms = "-Xdock:name=\"RuneScape Unix Client\" -Xdock:icon=\"".$rsu_data->cwd."/share/img/runescape.icns\"";
	}
	# Else if we are on linux and the useprimusrun setting is enabled
	elsif($rsu_data->useprimusrun =~ /(true|1)/i && $rsu_data->OS =~ /linux/)
	{
		# Run the enableprimus function and see if primusrun is available on the system
		my $primusrun_bin = rsu::nvidia::optimus::enableprimus($rsu_data);
		
		# Tell user what we are doing
		print "Fixing possible OpenGL issues by adding the environment variable\n$javalibpath\n";
		
		if ($primusrun_bin !~ /^$/)
		{
			# Tell user what we are doing
			print "Adding $primusrun_bin to the launch command\n";
		}
		
		
		# Add the primusrun binary and the javalibpath to the javabin
		$rsu_data->javabin = "$javalibpath $primusrun_bin ".$rsu_data->javabin;
	}
	# Else
	else
	{
		# Tell user what we are doing
		print "Fixing possible OpenGL issues by adding the environment variable\n$javalibpath\n";
				
		# Add the library path to the java binary command
		$rsu_data->javabin = "$javalibpath ".$rsu_data->javabin;
	}
	
	
	# Print debug info
	print "\nLaunching the RuneScape Client using this command:\ncd ".$rsu_data->clientdir."/bin && ".$rsu_data->javabin." $osxprms ".$rsu_data->verboseprms." -cp  $params /share/img\n\nExecuting the RuneScape Client!\nYou are now in the hands of Jagex.\n\n######## End Of Script ########\n######## Jagex client output will appear below here ########\n\n";
	
	# Execute the runescape client(hopefully)
	rsu::mains::runjar("cd ".$rsu_data->clientdir."/bin && ".$rsu_data->javabin." $osxprms ".$rsu_data->verboseprms." -cp  $params /share/img 2>&1");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub windows_main
{
	# This function depends on rsu::files::IO.pm
	require rsu::files::IO;
	
	# Get the data container
	my $rsu_data = shift;
	
	# Get the win32javabin setting which will be used as a searchpath to find jawt.dll and java.exe
	my $win32javabin = rsu::files::IO::readconf("win32java.exe", "default-java", "settings.conf");
	
	# Make a variable containing the default path containing jawt.dll
	my $javalibspath = "%CD%\\win32\\jawt";
	
	# If the win32javabin setting is default-java, 6, 7, 1.6 or 1.7
	if ($win32javabin =~ /^(default-java|6|7|1\.6|1\.7)/)
	{
		# Probe for the default java used on the system
		$win32javabin = rsu::java::jre::win32_find_java($win32javabin);
		
		# Prepare the new native javalibs path
		$javalibspath = $win32javabin;
		
		# Remove \\java.exe from the string
		$javalibspath =~ s/\\java.exe//ig;
	}
	
	# Get the language setting
	my $params = client::settings::prms::parseprmfile($rsu_data->prmfile);
	
	# Display java version we are using
	print "Launching client using this java version: \n";
	
	# Display the java version
	system "\"$win32javabin\" -version 2>&1";
	
	# Adjust the parameters abit
	$params =~ s/jagexappletviewer\.jar/bin\/jagexappletviewer\.jar/;
	
	# Print debug info
	print "\nLaunching the RuneScape Client using this command:\nset PATH=$javalibspath;%PATH% && $win32javabin ".$rsu_data->verboseprms." -cp  $params /share\n\nExecuting the RuneScape Client!\nYou are now in the hands of Jagex.\n\n######## End Of Script ########\n######## Jagex client output will appear below here ########\n\n";
	
	# Execute the runescape client(hopefully) and then pipe the output to grep to remove the lines saying "Recieved command: _11" which i dont know why appears
	#system "set PATH=$javalibspath;%PATH% && \"$win32javabin\" ".$rsu_data->verboseprms." -cp  $params /share 2>&1";
	
	rsu::mains::runjar("set PATH=$javalibspath;%PATH% && \"$win32javabin\" ".$rsu_data->verboseprms." -cp  $params /share/img 2>&1");
}

#
#---------------------------------------- *** ----------------------------------------
#

sub checkcompabilitymode
{
	# Get the data container
	my $rsu_data = shift;
	
	# If compabilitymode is activated (either with $rsu_data->compabilitymode = 1 or with the --compabilitymode parameter)
	if (($rsu_data->args =~ /--compabilitymode/ && $rsu_data->OS !~ /MSWin32/) || ($rsu_data->compabilitymode =~ /(1|true)/i && $rsu_data->OS !~ /MSWin32/))
	{
		# Tell user we are executing the client in compabilitymode
		print "Compabilitymode requested, starting client through wine!\nThe client will use the java that is installed inside wine\n\n";
		
		# Parse the prm file
		my $params = client::settings::prms::parseprmfile($rsu_data->prmfile);
		
		# Launch client through wine
		system "cd \"".$rsu_data->cwd."/\" && wine cmd /c \"set PATH=%CD%\\\\win32\\\\jawt;%PATH% && cd Z:".$rsu_data->clientdir."/bin && java -cp $params /share/img && exit\"";
		
		# Once the client is closed we need to do some cleanup (bug when running commands through shell to wine cmd
		# Make a variable to contain the pids of cmd (from wine)
		my $zombies = `pidof cmd`;
		
		# Split up the list of pids
		my @zombie = split /\s/, $zombies;
		
		# Make a counter
		my $zombiecounter = 0;
		
		# For each pid in the array
		foreach(@zombie)
		{
			# kill the zombie process
			system "kill -9 $zombie[$zombiecounter]";
			
			# Increase counter by 1
			$zombiecounter += 1;
		}
				
		# Exit this script so we dont cause trouble
		exit
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub runjar
{
	# Get the passed data
	my ($command) = @_;
	
	# Start the client process
	open CLIENT, "$command |";
	
	# While client is running
	while(<CLIENT>)
	{
		# Print output if it is not the "Received command" output spam
		print $_ if $_ !~ /Received command/;
	}
}

1;
 
