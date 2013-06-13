# ukpostcode.t

use Test::Most;
use Test::Fatal;

use MooseX::Types::UKPostcode qw/
    UKPostcode UKPostcodeLax UKPostcodeValid
    PartialUKPostcode PartialUKPostcodeLax PartialUKPostcodeValid
    /;

use Geo::UK::Postcode;

my %strings = (
    fail           => 'A',
    strict         => 'A1   1AA',    # invalid outcode
    lax            => 'Q1   1AA',    # invalid characters
    valid          => 'WC1H 9EB',    # valid postcode
    partial_strict => 'A1',          # invalid outcode
    partial_lax    => 'Q1',          # invalid characters
    partial_valid  => 'WC1H',        # valid outcode
);

my %pc = map {
    $_ => eval { Geo::UK::Postcode->new( $strings{$_} ) }
        || undef
    }
    keys %strings;

my %msg = (
    UKPostcode             => qr/Must be a strict postcode/,
    UKPostcodeLax          => qr/Must be a postcode/,
    UKPostcodeValid        => qr/Must be a valid postcode/,
    PartialUKPostcode      => qr/Must be a strict postcode/,
    PartialUKPostcodeLax   => qr/Must be a postcode/,
    PartialUKPostcodeValid => qr/Must be a valid postcode/,
);

test_ukpostcode(
    'UKPostcodeLax',
    \&UKPostcodeLax,    #
    success => [qw/ lax strict valid /],
    fail    => [qw/ fail partial_lax partial_strict partial_valid /]
);

test_ukpostcode(
    'UKPostcode',
    \&UKPostcode,
    success => [qw/ strict valid /],
    fail    => [qw/ fail lax partial_lax partial_strict partial_valid /]
);

test_ukpostcode(
    'UKPostcodeValid',
    \&UKPostcodeValid,
    success => [qw/ valid /],
    fail => [qw/ fail lax strict partial_lax partial_strict partial_valid /]
);

test_ukpostcode(
    'PartialUKPostcodeLax',
    \&PartialUKPostcodeLax,    #
    success =>
        [qw/ lax strict valid partial_lax partial_strict partial_valid /],
    fail => [qw/ fail /]
);

test_ukpostcode(
    'PartialUKPostcode',
    \&PartialUKPostcode,
    success => [qw/ strict valid partial_strict partial_valid /],
    fail    => [qw/ fail lax partial_lax /]
);

test_ukpostcode(
    'PartialUKPostcodeValid',
    \&PartialUKPostcodeValid,
    success => [qw/ valid partial_valid /],
    fail    => [qw/ fail lax strict partial_lax partial_strict /]
);

done_testing();

sub test_ukpostcode {
    my $name    = shift;
    my $type    = shift->();
    my %match   = @_;
    my @success = @{ $match{success} || [] };
    my @fail    = @{ $match{fail} || [] };

    note $name;

    foreach my $test (@success) {

        ok( $type->check( $pc{$test} ), "Geo::UK::Postcode ($test) is ok" );

        is_deeply( $type->coerce( $strings{$test} ),
            $pc{$test}, "String ($test) coerced ok" );

        ok( !$type->validate( $pc{$test} ), "validate $test ok" );
    }

    foreach my $test (@fail) {

        if ( my $pc = $pc{$test} ) {
            ok( !$type->check($pc), "Geo::UK::Postcode ($test) is not ok" );

            like( $type->validate($pc), $msg{$name}, "validate error ok" );

        } else {
            dies_ok { $type->coerce( $strings{$test} ) }
            "can't coerce ($test)";
        }
    }
}

