package client::init;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

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
	require rsu::files::copy;
	require rsu::files::dirs;
	require rsu::files::grep;
	require client::settings::cache;

	# End of core modules, add custom modules below this line

	require rsu::nvidia::optimus;
1; 
