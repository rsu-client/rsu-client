#!/usr/bin/perl -w

# Use FindBin module to get script directory
use FindBin;

# If no arguments are passed
if ("@ARGV" =~ //)
{
	# Make sure the cmd window gets hidden on windows
	use Win32::GUI();
	my $cmdwindow = Win32::GUI::GetPerlWindow();
	Win32::GUI::Hide($cmdwindow);
}

# Load the runescape script inside this loader 
#(if this loader is packaged with PAR::Packer this 
#will let the perl script run inside the compressed perl)
require "$FindBin::RealBin/runescape";

# Exit the script when done
exit
