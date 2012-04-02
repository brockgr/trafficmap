#!/usr/bin/perl

use strict;
use warnings;
#use threads;
#use threads::shared;
#use Thread::Queue;

use Net::DNS::Resolver;

my $router = $ARGV[0] || 'alink.net';
my @hostnames;

my $res = Net::DNS::Resolver->new;

if ($router =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/) { # is IP?
  my $reverse = join( '.', reverse( split /\./, $router )) . '.in-addr.arpa';
  if (my $packet = $res->query( $reverse, 'PTR' )) {
    for my $answer ($packet->answer) {
      push @hostnames, $answer->ptrdname;
    }
  }
  die "No reverse for $router" unless @hostnames;
} else {
  @hostnames = ($router);
}

while (@hostnames) {
  foreach my $host (@hostnames) {
    if (my $packet = $res->query($host, 'LOC')) {
      foreach my $answer ($packet->answer) {
        if ($answer->isa('Net::DNS::RR::LOC')) {
          my ($lat, $lon) = $answer->latlon;
          print "$router => $host\n";
          print "LL $lat,$lon\n";
          exit;
        }
      }
    } else {
      warn "No loc for $host";
    }
  }

  #Chop off subdomains - sometimes they have loc, but host doesn't
  # e.g. ae-62-62.csw1.Dallas1.Level3.net -> Dallas1.Level3.net 
  @hostnames = grep {$_} map { s/^[^.]+\.// && $_ } @hostnames;
}
