package rsu::java::optimizer;

sub run
{
	# Get the passed data
	my ($javabin, $params) = @_;
	
	# Optimize the Java execution
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
