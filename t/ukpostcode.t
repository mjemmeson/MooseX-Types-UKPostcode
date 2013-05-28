# ukpostcode.t

use Test::Most;
use Test::Fatal;

use MooseX::Types::UKPostcode qw/ UKPostcode UKPostcodeLax UKPostcodeValid /;

use Geo::UK::Postcode;

my %strings = (
    strict => 'A1   1AA',    # invalid outcode
    lax    => 'Q1   1AA',    # invalid characters
    valid  => 'WC1H 9EB',    # valid postcode
);

my %pc =                     #
    map { $_ => Geo::UK::Postcode->new( $strings{$_} ) }    #
    keys %strings;

my %msg = (
    UKPostcode      => qr/Must be a strict postcode/,
    UKPostcodeLax   => qr/Must be a postcode/,
    UKPostcodeValid => qr/Must be a valid postcode/,
);

test_ukpostcode(
    'UKPostcodeLax',
    \&UKPostcodeLax,                                        #
    success => [qw/ lax strict valid /]
);

test_ukpostcode(
    'UKPostcode',
    \&UKPostcode,
    success => [qw/ strict valid /],
    fail    => [qw/ lax /]
);

test_ukpostcode(
    'UKPostcodeValid',
    \&UKPostcodeValid,
    success => [qw/ valid /],
    fail    => [qw/ lax strict /]
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

        ok( !$type->check( $pc{$test} ),
            "Geo::UK::Postcode ($test) is not ok" );

        like( $type->validate( $pc{$test} ),
            $msg{$name}, "validate error ok" );
    }
}

