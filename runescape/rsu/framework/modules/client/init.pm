package client::init;
# Include(if not already included) the core modules for the RSU client
	require client::appletviewer::jagex;
	require rsu::files::IO;
	require client::settings::language;
	require client::settings::prms;
	require client::modes::verbose;
	require rsu::java::jre;
	require rsu::java::opengl;
	require rsu::mains;
	require rsu::files::clientdir;
	require client::env;
	require rsu::files::dirs;
	require rsu::files::grep;

	# End of core modules, add custom modules below this line

	require rsu::nvidia::optimus;
1; 
