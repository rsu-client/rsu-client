package test;

require rsu::files::grep;
$ARGV[1] =~ s/\\n/\n/g;
my @results = rsu::files::grep::strgrep($ARGV[1], $ARGV[2]);

# Change delimiter/separator to :
@greps = join(':',@greps);

1;
