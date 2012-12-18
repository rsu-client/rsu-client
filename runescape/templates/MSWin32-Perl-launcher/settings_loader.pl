#!/usr/bin/perl -w

# Use FindBin module to get script directory
use FindBin;

# Load the required Wx modules
use Wx::Perl::Packager;
use Wx qw[:everything];
use Wx::XRC;

# Make sure the settings script knows its loaded through par
@ARGV = qw(--usedpar=true);

# Load the runescape script inside this loader 
#(if this loader is packaged with PAR::Packer this 
#will let the perl script run inside the compressed perl)
require "$FindBin::RealBin/modules/settings";

# Exit the script when done
exit
