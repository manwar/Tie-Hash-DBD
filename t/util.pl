#!/pro/bin/perl

use strict;
use warnings;

sub dsn
{
    my $type = shift;

    $type eq "SQLite"	and return "dbi:SQLite:dbname=db.3";
    $type eq "Pg"	and return "dbi:Pg:";
    $type eq "CSV"	and return "dbi:CSV:f_ext=.csv/r;csv_null=1";

    if ($type eq "Oracle") {
	my @id = split m{/} => ($ENV{ORACLE_USERID} || "/");
	$ENV{DBI_USER} ||= $id[0];
	$ENV{DBI_PASS} ||= $id[1];

	($ENV{ORACLE_SID} || $ENV{TWO_TASK}) &&
	-d ($ENV{ORACLE_HOME} || "/-..\x03") &&
	   $ENV{DBI_USER} && $ENV{DBI_PASS} or
	    plan skip_all => "Not a testable ORACLE env";
	return "dbi:Oracle:";
	}

    if ($type eq "mysql") {
	my $db = $ENV{MYSQLDB} || $ENV{LOGNAME} || scalar getpwuid $<;
	return "dbi:mysql:database=$db";
	}
    } # dsn

sub cleanup
{
    my $type = shift;

    $type eq "Pg"	and return;
    $type eq "Oracle"	and return;
    $type eq "mysql"	and return;

    if ($type eq "SQLite") {
	unlink $_ for glob "db.3*";
	return;
	}

    if ($type eq "CSV") {
	unlink $_ for glob "t_tie*.csv";
	return;
	}
    } # cleanup

1;
