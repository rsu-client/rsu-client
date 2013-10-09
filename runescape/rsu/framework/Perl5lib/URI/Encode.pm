package URI::Encode;

#######################
# LOAD MODULES
#######################
use strict;
use warnings FATAL => 'all';

use 5.008001;
use Encode qw();
use Carp qw(croak carp);

#######################
# VERSION
#######################
our $VERSION = '0.09';

#######################
# EXPORT
#######################
use base qw(Exporter);
our (@EXPORT_OK);

@EXPORT_OK = qw(uri_encode uri_decode);

#######################
# SETTINGS
#######################

# Reserved characters
my $reserved_re
  = qr{([^a-zA-Z0-9\-\_\.\~\!\*\'\(\)\;\:\@\&\=\+\$\,\/\?\#\[\]\%])}x;

# Un-reserved characters
my $unreserved_re = qr{([^a-zA-Z0-9\Q-_.~\E\%])}x;

# Encoded character set
my $encoded_chars = qr{%([a-fA-F0-9]{2})}x;

#######################
# CONSTRUCTOR
#######################
sub new {
    my ( $class, @in ) = @_;

    # Check Input
    my $defaults = {

        #   this module, unlike URI::Escape,
        #   does not encode reserved characters
        encode_reserved => 0,

        #   Allow Double encoding?
        #   defaults to YES
        double_encode => 1,
    };

    my $input = {};
    if   ( ref $in[0] eq 'HASH' ) { $input = $in[0]; }
    else                          { $input = {@in}; }

    # Set options
    my $options = {

        # Defaults
        %{$defaults},

        # Input
        %{$input},

        # Encoding Map
        enc_map => { ( map { chr($_) => sprintf( "%%%02X", $_ ) } ( 0 ... 255 ) ) },

        # Decoding Map
        dec_map => { ( map { sprintf( "%02X", $_ ) => chr($_) } ( 0 ... 255 ) ), },
    };

    # Return
    my $self = bless $options, $class;
  return $self;
} ## end sub new

#######################
# ENCODE
#######################
sub encode {
    my ( $self, $data, $options ) = @_;

    # Check for data
    # Allow to be '0'
  return unless defined $data;

    my $enc_res       = $self->{encode_reserved};
    my $double_encode = $self->{double_encode};

    if ( defined $options ) {
        if ( ref $options eq 'HASH' ) {
            $enc_res = $options->{encode_reserved} if exists $options->{encode_reserved};
            $double_encode = $options->{double_encode}
              if exists $options->{double_encode};
        } ## end if ( ref $options eq 'HASH')
        else {
            $enc_res = $options;
        }
    } ## end if ( defined $options )

    # UTF-8 encode
    $data = Encode::encode( 'utf-8-strict', $data );

    # Encode a literal '%'
    if ($double_encode) { $data =~ s{(\%)}{$self->_get_encoded_char($1)}gex; }
    else { $data =~ s{(\%)}{$self->_encode_literal_percent($1, $')}gex; }

    # Percent Encode
    if ($enc_res) {
        $data =~ s{$unreserved_re}{$self->_get_encoded_char($1)}gex;
    }
    else {
        $data =~ s{$reserved_re}{$self->_get_encoded_char($1)}gex;
    }

    # Done
  return $data;
} ## end sub encode

#######################
# DECODE
#######################
sub decode {
    my ( $self, $data ) = @_;

    # Check for data
    # Allow to be '0'
  return unless defined $data;

    # Percent Decode
    $data =~ s{$encoded_chars}{ $self->_get_decoded_char($1) }gex;

  return $data;
} ## end sub decode

#######################
# EXPORTED FUNCTIONS
#######################

# Encoder
sub uri_encode { return __PACKAGE__->new()->encode(@_); }

# Decoder
sub uri_decode { return __PACKAGE__->new()->decode(@_); }

#######################
# INTERNAL
#######################


sub _get_encoded_char {
    my ( $self, $char ) = @_;
  return $self->{enc_map}->{$char} if exists $self->{enc_map}->{$char};
  return $char;
} ## end sub _get_encoded_char


sub _encode_literal_percent {
    my ( $self, $char, $post ) = @_;
  return $self->_get_encoded_char($char) if not defined $post;
    if ( $post =~ m{^([a-fA-F0-9]{2})}x ) {
      return $self->_get_encoded_char($char) unless exists $self->{dec_map}->{$1};
      return $char;
    } ## end if ( $post =~ m{^([a-fA-F0-9]{2})}x)
  return $self->_get_encoded_char($char);
} ## end sub _encode_literal_percent


sub _get_decoded_char {
    my ( $self, $char ) = @_;
  return $self->{dec_map}->{ uc($char) }
      if exists $self->{dec_map}->{ uc($char) };
  return $char;
} ## end sub _get_decoded_char

#######################
1;

__END__

#######################
# POD SECTION
#######################
=pod

=head1 NAME

URI::Encode - Simple percent Encoding/Decoding

=head1 SYNOPSIS

    # OOP Interface
    use URI::Encode;
    my $uri     = URI::Encode->new( { encode_reserved => 0 } );
    my $encoded = $uri->encode($data);
    my $decoded = $uri->decode($encoded);

    # Functional
    use URI::Encode qw(uri_encode uri_decode);
    my $encoded = uri_encode($data);
    my $decoded = uri_decode($encoded);


=head1 DESCRIPTION

This modules provides simple URI (Percent) encoding/decoding

The main purpose of this module (at least for me) was to provide an
easy method to encode strings (mainly URLs) into a format which can be
pasted into a plain text emails, and that those links are 'click-able'
by the person reading that email. This can be accomplished by NOT
encoding the reserved characters.

This module can also be useful when using L<HTTP::Tiny> to ensure the
URLs are properly escaped.

If you are looking for speed and want to encode reserved characters,
use L<URI::Escape::XS>

See L<this
script|https://github.com/mithun/perl-uri-encode/raw/master/.author/benchmark.pl>
for a comparison on encoding results and performance.

=head1 METHODS

=head2 new()

Creates a new object, no arguments are required

	my $encoder = URI::Encode->new(\%options);

The following options can be passed to the constructor

=over

=item encode_reserved

	my $encoder = URI::Encode->new({encode_reserved => 0});

If true, L</"Reserved Characters"> are also encoded. Defaults to false.

=item double_encode

	my $encoder = URI::Encode->new({double_encode => 1});

If false, characters that are already percent-encoded will not be
encoded again. Defaults to true.

    my $encoder = URI::Encode->new({double_encode => 0});
    print $encoder->encode('http://perl.com/foo%20bar'); # prints http://perl.com/foo%20bar

=back

=head2 C<encode($url, \%options)>

This method encodes the URL provided. The C<$url> provided is first
converted into UTF-8 before percent encoding. Options set in the
constructor, or defaults, can be overrided by passing them as the
(optional) second argument. Options passed must be a hashref.

    $uri->encode("http://perl.com/foo bar");
    $uri->encode( "http://perl.com/foo bar", { encode_reserved => 1 } );

=head2 C<decode($url)>

This method decodes a 'percent' encoded URL. If you had encoded the URL
using this module (or any other method), chances are that the URL was
converted to UTF-8 before 'percent' encoding. Be sure to check the
format and convert back if required.

	$uri->decode("http%3A%2F%2Fperl.com%2Ffoo%20bar");

=head1 EXPORTED FUNCTIONS

The following functions are exported upon request. This provides a
non-OOP interface

=over

=item C<uri_encode($url, \%options)>

=item C<uri_decode($url)>

=back

=head1 CHARACTER CLASSES

=head2 Reserved Characters

The following characters are considered as reserved (L<RFC
3986|http://tools.ietf.org/html/rfc3986>). They will be encoded only if
requested.

	 ! * ' ( ) ; : @ & = + $ , / ? # [ ]

=head2 Unreserved Characters

The following characters are considered as Unreserved. They will not be
encoded

	a-z
	A-Z
	0-9
	- _ . ~

=head1 DEPENDENCIES

L<Encode>

=head1 ACKNOWLEDGEMENTS

Gisle Aas for L<URI::Escape>

David Nicol for L<Tie::UrlEncoder>

=head1 SEE ALSO

L<RFC 3986|http://tools.ietf.org/html/rfc3986>

L<URI::Escape>

L<URI::Escape::XS>

L<URI::Escape::JavaScript>

L<Tie::UrlEncoder>

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-uri-encode@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=URI-Encode>

=head1 AUTHOR

Mithun Ayachit C<mithun@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Mithun Ayachit. All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

=cut