package MooseX::Types::UKPostcode;
use MooseX::Types -declare => [
    qw/ UKPostcode UKPostcodeLax UKPostcodeValid
        /

        #        PartialUKPostcode PartialUKPostcodeLax PartialUKPostcodeValid
        #        /
];

use MooseX::Types::Moose qw/Object ArrayRef Str/;

use Geo::UK::Postcode;
use Geo::UK::Postcode::Regex;

our $VERSION = '0.01';

subtype UKPostcodeLax,    #
    as Object,            #
    where { $_->isa('Geo::UK::Postcode') },    #
    message {"Must be a postcode string or Geo::UK::Postcode object"};

subtype UKPostcode,                            #
    as UKPostcodeLax,                          #
    where { $_->strict },                      #
    message {"Must be a strict postcode string or Geo::UK::Postcode object"};

subtype UKPostcodeValid,                       #
    as UKPostcode,                             #
    where { $_->valid },                       #
    message {"Must be a valid postcode string or Geo::UK::Postcode object"};

coerce UKPostcodeLax,   from Str, via { Geo::UK::Postcode->new($_) };
coerce UKPostcode,      from Str, via { Geo::UK::Postcode->new($_) };
coerce UKPostcodeValid, from Str, via { Geo::UK::Postcode->new($_) };

1;
