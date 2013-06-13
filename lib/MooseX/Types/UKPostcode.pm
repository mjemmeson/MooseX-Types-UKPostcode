package MooseX::Types::UKPostcode;

# VERSION

# ABSTRACT: Moose types for Geo::UK::Postcode objects

=head1 NAME

MooseX::Types::UKPostcode

=head1 SYNOPSIS

    package MyClass;
    use Moose;
    use MooseX::Types::UKPostcode qw/ UKPostcode PartialUKPostcode /;
    use namespace::autoclean;
    
    has postcode => ( isa => UKPostcode, required => 1, is => 'ro' );
    has outcode  => ( isa => PartialUKPostcode, required => 1, is => 'ro' );

=head1 DESCRIPTION

Moose types for using L<Geo::UK::Postcode> objects as attributes, with the
associated validation and coercion from strings.

Various levels of 'strictness' are available - 'lax' which just expects
something that looks like a British postcode, 'strict' (the default) which
checks there are no invalid characters, and 'valid' which must have a
real outcode.

Partial postcodes are supported - these are either an outcode (area and
district), e.g. 'SE1' or 'AB10', or an outcode and postcode sector (area,
district and sector), e.g. 'SE1 0' or 'AB10 1'.

For more details on parsing, validity, outcodes, etc, please see
L<Geo::UK::Postcode>.

=head1 TYPES

=head2 UKPostcode

=head2 UKPostcodeLax

=head2 UKPostcodeValid

=head2 PartialUKPostcode

=head2 PartialUKPostcodeLax

=head2 PartialUKPostcodeValid

=head1 TODO

Just validation, no objects

=head1 SEE ALSO

=over

=item *

L<Geo::UK::Postcode>

=back

=cut

use MooseX::Types -declare => [
    qw/ UKPostcode UKPostcodeLax UKPostcodeValid
        PartialUKPostcode PartialUKPostcodeLax PartialUKPostcodeValid
        /
];

use MooseX::Types::Moose qw/Object ArrayRef Str/;

use Geo::UK::Postcode;
use Geo::UK::Postcode::Regex;

subtype PartialUKPostcodeLax,    #
    as Object,                   #
    where { $_->isa('Geo::UK::Postcode') },    #
    message {"Must be a postcode string or Geo::UK::Postcode object"};

subtype PartialUKPostcode,                     #
    as PartialUKPostcodeLax,                   #
    where { $_->strict },                      #
    message {"Must be a strict postcode string or Geo::UK::Postcode object"};

subtype PartialUKPostcodeValid,                #
    as PartialUKPostcode,                      #
    where { $_->valid },                       #
    message {"Must be a valid postcode string or Geo::UK::Postcode object"};

coerce PartialUKPostcodeLax,   from Str, via { Geo::UK::Postcode->new($_) };
coerce PartialUKPostcode,      from Str, via { Geo::UK::Postcode->new($_) };
coerce PartialUKPostcodeValid, from Str, via { Geo::UK::Postcode->new($_) };

subtype UKPostcodeLax,                         #
    as PartialUKPostcodeLax,                   #
    where { !$_->partial },                    #
    message {"Must be a postcode string or Geo::UK::Postcode object"};

subtype UKPostcode,                            #
    as UKPostcodeLax,                          #
    where { $_->strict },      #
    message {"Must be a strict postcode string or Geo::UK::Postcode object"};

subtype UKPostcodeValid,                       #
    as UKPostcode,                             #
    where { $_->valid },       #
    message {"Must be a valid postcode string or Geo::UK::Postcode object"};

coerce UKPostcodeLax,   from Str, via { Geo::UK::Postcode->new($_) };
coerce UKPostcode,      from Str, via { Geo::UK::Postcode->new($_) };
coerce UKPostcodeValid, from Str, via { Geo::UK::Postcode->new($_) };

1;

