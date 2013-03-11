package addon::platform::launch;

# If parameters are help is passed
if ("@ARGV" =~ /\s+help(|\s+)/i)
{
	# Tell user how to use this call
	print "API to launch or list platform specific addons
Syntaxes:
	$ARGV[0] help
	$ARGV[0] addon_name
	$ARGV[0] list

Examples:
	$ARGV[0] list
	result: a string containing the name of every
		platform specific adddon splitted by a comma.
	
	$ARGV[0] player_lookup
	result: launches the platform specific addon named player_lookup.
	
Remarks:
	Returns nothing.

Purpose:
	Simplify the task of launching a platform specific addon
";
}
# Else if list is passed
elsif($ARGV[1] =~ /^list$/)
{
	# Require the dirs module
	require rsu::files::dirs;
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Get the location of the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Get the current OS
	my $OS = "$^O";
	
	# Get a list of the addons
	my @addons = rsu::files::dirs::list("$clientdir/addons/$OS");
	
	# Change the delimiter to comma
	@addons = join(",", @addons);
	
	# Show the addons list
	print "@addons\n";
}
else
{
	# Use the Cwd module so we can get the current working directory
	use Cwd;
	
	# Get the cwd
	my $cwd = getcwd;
	
	# Require the clientdir module
	require rsu::files::clientdir;
	
	# Get the location of the clientdir
	my $clientdir = rsu::files::clientdir::getclientdir();
	
	# Get the current OS
	my $OS = "$^O";
	
	# Add the universal addons directory to the include path
	unshift @INC, "$clientdir/addons/$OS";
	
	# Change cwd to the addons own directory so we do not confuse it
	chdir("$clientdir/addons/$OS/$ARGV[1]");
	
	# Load the moduleloader for the addon
	eval "use $ARGV[1]::moduleloader"; warn if $@;
	
	# Change directory back to cwd
	chdir("$cwd");
}

1;
