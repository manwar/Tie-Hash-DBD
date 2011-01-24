#!/pro/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config bundling nopermute);
my $check = 0;
my $opt_v = 0;
GetOptions (
    "c|check"		=> \$check,
    "v|verbose:1"	=> \$opt_v,
    ) or die "usage: $0 [--check]\n";

my $version;
open my $pm, "<", "lib/Tie/Hash/DBD.pm" or die "Cannot read Tie::DBD";
while (<$pm>) {
    m/^our .VERSION\s*=\s*"?([-0-9._]+)"?\s*;\s*$/ or next;
    $version = $1;
    last;
    }
close $pm;

my @yml;
while (<DATA>) {
    s/VERSION/$version/o;
    push @yml, $_;
    }

if ($check) {
    print STDERR "Check required and recommended module versions ...\n";
    BEGIN { $V::NO_EXIT = $V::NO_EXIT = 1 } require V;
    my %vsn = map { m/^\s*([\w:]+):\s+([0-9.]+)$/ ? ($1, $2) : () } @yml;
    delete @vsn{qw( perl version )};
    for (sort keys %vsn) {
	$vsn{$_} eq "0" and next;
	my $v = V::get_version ($_);
	$v eq $vsn{$_} and next;
	printf STDERR "%-35s %-6s => %s\n", $_, $vsn{$_}, $v;
	}

    print STDERR "Checking generated YAML ...\n";
    use YAML::Syck;
    use Test::YAML::Meta::Version;
    my $h;
    my $yml = join "", @yml;
    eval { $h = Load ($yml) };
    $@ and die "$@\n";
    $opt_v and print Dump $h;
    my $t = Test::YAML::Meta::Version->new (yaml => $h);
    $t->parse () and die join "\n", $t->errors, "";

    use Parse::CPAN::Meta;
    eval { Parse::CPAN::Meta::Load ($yml) };
    $@ and die "$@\n";

    my $req_vsn = $h->{requires}{perl};
    print "Checking if $req_vsn is still OK as minimal version for examples\n";
    use Test::MinimumVersion;
    # All other minimum version checks done in xt
    all_minimum_version_ok ($req_vsn, { paths =>
	[ "t", "examples", "lib.pm", "Makefile.PL" ]});
    }
elsif ($opt_v) {
    print @yml;
    }
else {
    my @my = glob <*/META.yml>;
    @my == 1 && open my $my, ">", $my[0] or die "Cannot update META.yml\n";
    print $my @yml;
    close $my;
    chmod 0644, glob <*/META.yml>;
    }

__END__
--- #YAML:1.0
name:                    Tie::Hash::DBD
version:                 VERSION
abstract:                Tie plain hashes to DBI interface
license:                 perl
author:              
    - H.Merijn Brand <h.m.brand@xs4all.nl>
generated_by:            Author
distribution_type:       module
provides:
    Tie::Hash::DBD:
        file:            lib/Tie/Hash/DBD.pm
        version:         VERSION
    Tie::Array::DBD:
        file:            lib/Tie/Array/DBD.pm
        version:         VERSION
requires:     
    perl:                5.008
    Carp:                0
    DBI:                 1.613
    Storable:            0
configure_requires:
    ExtUtils::MakeMaker: 0
test_requires:
    Test::Harness:       0
    Test::More:          0.90
    Time::HiRes:         0
recommends:     
    perl:                5.012003
    DBI:                 1.616
    DBD::SQLite:         1.31
    Test::More:          0.96
resources:
    license:             http://dev.perl.org/licenses/
    repository:          http://repo.or.cz/w/Tie-Hash-DBD.git
meta-spec:
    version:             1.4
    url:                 http://module-build.sourceforge.net/META-spec-v1.4.html
