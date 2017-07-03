# This module deals with making sure that opengl works with java on linux
# NOTE: no support for nvidia optimus yet! but it is being worked on!
package rsu::java::opengl;
#       Copyright (C) 2017 HikariKnight <rshikariknight@gmail.com>
#       and contributors found in the AUTHORS file.
#       Use of this script is governed by a GPL v2 license
#       that can be found in the LICENSE file.
#       Source code and contact info at https://github.com/HikariKnight/runescape

sub unix_findlibrarypath
{
	# Gets passed data from the function call
	my ($binary) = @_;
	
	# List up the shared library files used by the java binary (not the symlink!) and remove unneeded info
	my $lddresult = `ldd $binary | grep libjli.so`;
	#my $lddresult = `ldd $binary | grep libjli.so | sed s/libjli.so\\ =\\>// | sed s/\\(.*// | sed s/jli\\\\/libjli.so//`;
	
	# Finds the library path from the ldd output line, removing whitespaces before 
	# and after the path.
	$lddresult =~ s/\s*libjli\.so\s*=>\s+(.*)jli\/libjli\.so\s+\(\S+\)\s*$/$1/;
	
	# Add the libjli back in a different variable
	my $libjli = $lddresult."jli/";
	
	# Remove the TAB and whitespaces before the path
	#$lddresult =~ s/^(\t+\s+|\t+|\s+)//g;
	
	# Remove the newline from the output
	#$lddresult =~ s/\n//g;
	
	# Return the library path for java
	return "LD_LIBRARY_PATH=$lddresult:$libjli:\$LD_LIBRARY_PATH";
}

#
#---------------------------------------- *** ----------------------------------------
#

# Caironogl is an older version of libcairo.so.2 which does not conflict with libjaggl.so
sub add_caironogl
{
	# Get the passed data
	my ($javalibpath, $cwd) = @_;
	
	# Split the LD_LIBRARY_PATH so we can change it
	my @ldpath = split /=/, $javalibpath;
	
	# Add caironogl to the path
	$javalibpath = "$ldpath[0]=$cwd/rsu/3rdParty/linux/cairo-nogl/i386/:$cwd/rsu/3rdParty/linux/cairo-nogl/x86_64/:$ldpath[1]";
	
	# Return the new LD_LIBRARY_PATH
	return $javalibpath;
}

#
#---------------------------------------- *** ----------------------------------------
#

1;
