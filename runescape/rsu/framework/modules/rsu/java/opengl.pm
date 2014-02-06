# This module deals with making sure that opengl works with java on linux
# NOTE: no support for nvidia optimus yet! but it is being worked on!
package rsu::java::opengl;

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

1;
