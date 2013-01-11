#!/usr/bin/perl -w

# Use FindBin module to get script directory
use FindBin;

# Load the runescape script inside this loader 
#(if this loader is packaged with PAR::Packer this 
#will let the perl script run inside the compressed perl)
require "$FindBin::RealBin/update-runescape-client";

# Exit the script when done
exit
