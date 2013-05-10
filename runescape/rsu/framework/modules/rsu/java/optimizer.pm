package rsu::java::optimizer;

sub run
{
	# Get the passed data
	my ($javabin, $params) = @_;
	
	# Tell the user what we are doing
	print "Adding optimization parameters to Java.\nParameters that will be added are:\n-XX:+AggressiveOpts -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+TieredCompilation -XX:ReservedCodeCacheSize=256m -XX:+UseAdaptiveGCBoundary -XX:SurvivorRatio=16 -XX:+UseParallelGC\nNOTE: If any of these are added to the prm file the parameter from the prm file will be used instead!\n\n";
	
	# Optimize the Java execution
	$javabin = "$javabin -XX:+AggressiveOpts" if $params !~ /-XX:+AggressiveOpts/;
	$javabin = "$javabin -XX:+UnlockExperimentalVMOptions" if $params !~ /-XX:+UnlockExperimentalVMOptions/;
	$javabin = "$javabin -XX:+DisableExplicitGC" if $params !~ /-XX:+DisableExplicitGC/;
	$javabin = "$javabin -XX:+TieredCompilation" if $params !~ /-XX:+TieredCompilation/;
	$javabin = "$javabin -XX:ReservedCodeCacheSize=256m" if $params !~ /-XX:ReservedCodeCacheSize=/;
	$javabin = "$javabin -XX:+UseAdaptiveGCBoundary" if $params !~ /-XX:+UseAdaptiveGCBoundary/;
	$javabin = "$javabin -XX:SurvivorRatio=16" if $params !~ /-XX:SurvivorRatio=/;
	$javabin = "$javabin -XX:+UseParallelGC" if $params !~ /-XX:+UseParallelGC/;
	
	# Return the new javabin call
	return $javabin;
}

#
#---------------------------------------- *** ----------------------------------------
#

1; 
