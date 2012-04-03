#!/usr/bin/perl

use strict;
use warnings;

use Socket;
use PerlIO::gzip;

my $router = $ARGV[0] || '129.250.2.24';

# Data seems to be filtered by Class-C
my $router_id = unpack("N",inet_aton($router) & inet_aton("255.255.255.0"));

open(my $db, "<:gzip", "hip_ip4_city_lat_lng.csv.gz") or die $!;
while (defined(my $line = <$db>)) {
  my ($id, $city, $lat, $long) = split /,/, $line;
  if ($router_id eq $id) {
    print "$id = $lat,$long\n";
    exit;
  } 
}

