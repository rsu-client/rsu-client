# This is the modules loader, include load lines in this file
# The modules can be ordered in any order even if they depend 
# on a module which have not been loaded yet
package modules;
	# Include(if not already included) the core modules for the RSU client
	require rsu_check_for_jagexappletviewer;
	require rsu_IO;
	require rsu_language_support;
	require rsu_prm_filehandler;
	require rsu_verbose;
	require rsu_java;
	require rsu_javalib_opengl;
	require rsu_mains;
	
	# End of core modules, add custom modules below this line
	
	
	# End of custom modules #
1;


# List of data that you get access to if you pass the variable $rsu_data
# to your functions (need to be passed to your function from the runescape script first)
#
# $rsu_data = data container
# $rsu_data->version = scriptversion
# $rsu_data->cwd = current directory
# $rsu_data->clientdir = client directory
# $rsu_data->OS = Operating System
# $rsu_data->args = arguments passed to the runescape script
# $rsu_data->verboseprms = verbose arguments passed to the runescape script (otherwise empty)

## Settings stored in the $rsu_data mutator
# $rsu_data->compabilitymode = returns 1 or true if enabled (otherwise returns 0 or false)
# $rsu_data->forcepulseaudio = returns 1 or true if enabled (otherwise returns 0 or false)
# $rsu_data->forcealsa = returns 1 or true if enabled (otherwise returns 0 or false)
# $rsu_data->preferredjava = returns the users java setting for the client (linux, mac and other unixes only)
# $rsu_data->prmfile = name of the currently used prmfile
# $rsu_data->fallbackprms = the fallback parameters used if the prmfile is not found
