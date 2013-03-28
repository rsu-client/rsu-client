#!/usr/bin/perl
package XML::RSSLite;
use strict;
use vars qw($VERSION);

$VERSION = 0.15;

sub import{
  no strict 'refs';
  shift;
  my $pkg = scalar caller();
  *{"${pkg}::parseRSS"} = \&parseRSS;
  *{"${pkg}::parseXML"} = \&parseXML if grep($_ eq 'parseXML', @_);
}


sub parseRSS {
  my ($rr, $cref) = @_;

  die "$rr is not a hash reference"     unless ref($rr)   eq 'HASH';
  die "$cref is not a scalar reference" unless ref($cref) eq 'SCALAR';

  # Gotta have some content to parse
  return unless $$cref;

  preprocess($cref);
  {
    _parseRSS($rr, $cref), last if index(${$cref}, '<rss')+1;
    _parseRDF($rr, $cref), last if index(${$cref}, '<rdf:RDF')+1;
    _parseSN( $rr, $cref), last if index(${$cref}, '<scriptingnews')+1;
    _parseWL( $rr, $cref), last if index(${$cref}, '<weblog')+1;
    die "Content must be RSS|RDF|ScriptingNews|Weblog|reasonably close";
  }
  postprocess($rr);
}

sub preprocess {
  my $cref = shift;
  $$cref =~ y/\r\n/\n/s;
  $$cref =~ y{\n\t ~0-9\-+!@#$%^&*()_=a-zA-Z[]\\;':",./<>?}{ }cs;
  #XXX $$cref =~ s/&(?!0[a-zA-Z0-9]+|#\d+);/amp/gs;
  #XXX Do we wish to (re)allow escaped HTML?!
  $$cref =~ s{(?:<|&lt;)/?(?:b|i|h\d|p|center|quote|strong)(?:>|&gt;)}{}gsi;
}

sub _parseRSS {
  parseXML($_[0], $_[1], 'channel', 0); 
  $_[0]->{'items'} = $_[0]->{'item'};
}

sub _parseRDF {
  my ($rr, $cref) = @_;

  $rr->{'items'} = [];
  my $item; 

  parseXML($_[0], $_[1], 'rdf:RDF', 0); 

  # Alias RDF to RSS
  if( exists($rr->{'item'}) ){
    $rr->{'items'} = $rr->{'item'};
  }
  else{
    my $li = $_[0]->{'rdf:li'} || $_[0]->{'rdf:Seq'}->{'rdf:li'};
    foreach $item ( @{$li} ){
      my %ia;
      if (exists $item->{'dc:description'}) {
	$ia{'description'} = $item->{'dc:description'};
      }  
      if (exists $item->{'dc:title'}) {
	$ia{'title'} = $item->{'dc:title'};
      }  
      if (exists $item->{'dc:identifier'}) {
	$ia{'link'} = delete($item->{'dc:identifier'});
      }  
      
      push(@{$rr->{'items'}}, \%ia); 
    }
  }
}

sub _parseSN {
  my ($rr, $cref) = @_;
  
  $rr->{'items'} = ();
  my $item; 

  parseXML($rr, $cref, 'channel', 0); 
  
  # Alias SN to RSS terms
  foreach $item ( @{$_[0]->{'rdf:li'}} ){
    my %ia;
    if (exists $item->{'text'}) {
      $ia{'description'} = $item->{'text'};
    }  
    if (exists $item->{'linetext'}) {
      $ia{'title'} = $item->{'linetext'};
    }  
    if (exists $item->{'url'}) {
      $ia{'link'} = $item->{'url'};
    }  

    push(@{$rr->{'items'}}, \%ia); 
  }
}


sub _parseWL {
  my ($rr, $cref) = @_;

  $rr->{'items'} = ();
  my $item; 

  #XXX is this the right tag to parse for?
  parseXML($rr, $cref, 'channel', 0); 
  
  # Alias WL to RSS
  foreach $item ( @{$_[0]->{'rdf:li'}} ){
    my %ia;
    if (exists $item->{'url'}) {
      $ia{'link'} = delete($item->{'url'});
    }

    push(@{$rr->{'items'}}, \%ia); 
  }
}


sub postprocess {
  my $rr = shift;

  #XXX Not much to do, what about un-munging URL's in source, etc.?!
  return unless defined($rr->{'items'});
  $rr->{'items'} = [$rr->{'items'}] unless ref($rr->{'items'}) eq 'ARRAY';

  foreach my $i (@{$rr->{'items'}}) {
    $i->{description} = $i->{description}->{'<>'} if ref($i->{description});

    # Put stuff into the right name if necessary
    if( not $i->{'link'} ){
      if( defined($i->{'url'}) ){
	$i->{'link'} = delete($i->{'url'}); }
      # See if you can use misplaced url in title for empty links
      elsif( exists($i->{'title'}) ){
	# The next case would trap this, but try to short-circuit the gathering
	if ($i->{'title'} =~ /^(?:https?|ftp):/) {
	  $i->{'link'} = $i->{'title'};
	}
	elsif ($i->{'title'} =~ /"((?:https?|ftp).*?)"/) {
	  $i->{'link'} = $1;
	  $i->{'title'} =~ s/<.*?>//;
	}
	else {
	  next;
	}
      }
    }
    
    # Clean bogus whitespace
    $i->{'link'} =~ s/^\s+|\s+$//;

    # Make sure you've got an http/ftp link
    if( exists( $i->{'link'}) && $i->{'link'} !~ m{^(https?|ftp)://}i) {
      ## Rip link out of anchor tag
      if( ref($i->{'link'}) && $i->{'link'}->{a}->{href} ){
	$i->{'link'} = $i->{'link'}->{a}->{href} }
      ## Smells like a relative url
      elsif( $i->{'link'}  =~ m{^[#/]} and $rr->{'link'} =~ m{^https?://} ){
	if (substr($i->{'link'}, 0, 1) ne '/') {
	  $i->{'link'} = '/' . $i->{'link'};
	}
	$i->{'link'} = $rr->{'link'} . $i->{'link'};
      }
      else {
	next;
      }
    }
    
    #If we don't have a title, use the link
    unless( defined($i->{'title'}) ){
      $i->{'title'} = $i->{'link'};
    }
    
    if( exists($i->{'link'}) ){
#XXX      # Fix pre-process munging
#      $i->{'link'} =~ s/&amp;/&/gi;
      $i->{'link'} =~ s/ /%20/g;
    }
  }
}

sub parseXML{
  my($hash, $xml, $tag, $comments) = @_;
  my($begin, $end, @comments);
  local $_;

  #Kill comments
  while( ($begin =  index(${$xml}, '<!--')) > -1 &&
	${$xml} =~ m%<!--.*?--(>)%sg ){
    my $str = substr(${$xml}, $begin, pos(${$xml})-$begin, '');
    
    #Save them if requested
    do{ unshift @comments, [$begin, substr($str, 4, length($str)-7)] }
      if $comments;
  }

  _parseXML($hash, $xml, $tag);

#  #XXX Context of comment is lost!
#  #Expose comments if requested
#  do{ push(@$comments, $_->[1]) for @comments } if ref($comments) eq 'ARRAY';
  if( $comments ){
    #Restore comments if requested
    substr(${$xml}, $_->[0], 0, '<!--'.$_->[1].'-->') for @comments;

    #Expose comments if requested
    do{ push(@$comments, $_->[1]) for @comments } if ref($comments) eq 'ARRAY';
  }
}

sub _parseXML{
  my($hash, $xml, $tag, $index) = @_;
  my($begin, $end);

  #Find topTag and set pos to start matching from there
  ${$xml} =~ /<$tag(?:>|\s)/g;
  ($begin, $end) = (0, pos(${$xml})||0);

  #Match either <foo></foo> or <bar />, optional attributes, stash tag name
  while( ${$xml} =~ m%<([^\s>]+)(?:\s+[^>]*?)?(?:/|>.*?</\1)>%sg ){	 

    #Save the tag name, we'll need it
    $tag = $1 || $2;

    #Save the new beginning and end
    ($begin, $end) = ($end, pos(${$xml}));

    #Get the bit we just matched.
    my $str = substr(${$xml}, $begin, $end-$begin);
    
    #Extract the actual attributes and contents of the tag
   $str =~ m%<\Q$tag\E\s*([^>]*?)?>(.*?)</\Q$tag\E>%s ||
#XXX pointed out by hv
#    $str =~ s%^.*?<$tag\s*([^>]*?)?>(.*?)</$tag>%<$tag>$2</$tag>%s ||
      $str =~ m%<\Q$tag\E\s*([^>]*?)?\s*/>%;
    my($attr, $content) = ($1, $2);

    #Did we get attributes? clean them up and chuck them in a hash.
    if( $attr ){
      ($_, $attr) = ($attr, {});
      $attr->{$1} = $3 while m/([^\s=]+)\s*=\s*(['"]?)([^\2>]*?)(?:\2|$)/g;
    }

    my $inhash;
    #Recurse if contents has more tags, replace contents with reference we get
    if( $content && index($content, '<') > -1 ){
      _parseXML($inhash={}, \$str, $tag);
      #Was there any data in the contents? We should extract that...
      if( $str =~ />[^><]+</ ){
	#The odd RE above shortcircuits unnecessary entry

	#Clean whitespace between tags
	#$str =~ s%(?<=>)?\s*(?=<)%%g; #XXX ~same speed, wacko warning
	#$str =~ s%(>?)\s*<%$1<%g;
#XXX    #$str =~ s%(?:^|(?<=>))\s*(?:(?=<)|\z)%%g

	my $qr = qr{@{[join('|', keys %{$inhash})]}};
	$content =~ s%<($qr)\s*(?:[^>]*?)?(?:/|>.*?</\1)>%%sg;

	$inhash->{'<>'} = $content if $content =~ /\S/;
      }
    }

    if( ref($inhash) ){
      #We have attributes? Then we should merge them.
      if( ref($attr) ){
	for( keys %{$attr} ){
	  $inhash->{$_} = exists($inhash->{$_})   ?
	    (ref($inhash->{$_})  eq 'ARRAY'       ?
	     [@{$inhash->{$_}}, $attr->{$_}]   :
	     [  $inhash->{$_},  $attr->{$_}] ) : $attr->{$_};
	}
      }
    }
    elsif( ref($attr) ){
      $inhash = $attr;
    }
    else{
      #Otherwise save our content
      $inhash = $content;
    }
    
    $hash->{$tag} = exists($hash->{$tag}) ?
      (ref($hash->{$tag})  eq 'ARRAY'     ?
	[@{$hash->{$tag}}, $inhash]       :
	[  $hash->{$tag},  $inhash]  )    : $inhash;
  }
}

1;
