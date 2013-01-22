#!/usr/bin/perl -w

# Use FindBin module to get script directory
use FindBin;

# Load the required Wx modules
use Wx::Perl::Packager;
use Wx qw[:everything];
use Wx::XRC;

# Use byte encoding so that localization is the same across different system languages
use Encode::Byte;

# If we are on windows
if ("$^O" =~ /MSWin32/)
{
	# Make sure the cmd window gets hidden on windows
	use Win32::GUI();
	my $cmdwindow = Win32::GUI::GetPerlWindow();
	Win32::GUI::Hide($cmdwindow);
	
	# Make sure the settings script knows its loaded through par (--usedpar=platform)
	@ARGV = qw(--usedpar=true);
	
	# Load the runescape script inside this loader 
	#(if this loader is packaged with PAR::Packer this 
	#will let the perl script run inside the compressed perl)
	require "$FindBin::RealBin/modules/settings";
}
# Else if we are on darwin 
elsif("$^O" =~ /darwin/)
{
	# Load the runescape script inside this loader 
	#(if this loader is packaged with PAR::Packer this 
	#will let the perl script run inside the compressed perl)
	require "$FindBin::RealBin/settings";
}

# Exit the script when done
exit;
