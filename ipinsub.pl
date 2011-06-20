#!/usr/bin/perl
# Author: Tony G. <tonysk8@gmx.net>

use strict;

# ipv4 to dec (32bits)
sub ip2dec {
  my $ip = shift;
  my @octets = split( /\./, $ip);
  my $dec = unpack ("N", pack("C4", @octets));
  return $dec
}

# dec2bin (32bits)
sub dec2bin {
  my $dec = shift;
  my $bin = unpack("B32", pack("N", $dec));
  return $bin;
}

# bin2dec (8bits)
sub bin2dec {
  my $bin = shift;
  return unpack("C", pack("B8", $bin));
}

# dec (32bit) to ipv4
sub dec2ip {
  my $dec = shift;
  my $bin = dec2bin($dec);
  my @ip = ();
  $bin =~ s/([01]{8})([01]{8})([01]{8})([01]{8})/\1 \2 \3 \4/;
  my @octets = split(/ /, $bin);
  foreach my $octet (@octets) {
    push(@ip, bin2dec($octet));
  }
  return join(".", @ip);
}

# validate ipv4 (no trailing 0s)
sub validIPv4 {
  my $ipv4 = shift;
  if ($ipv4 =~ /^(1?\d\d?|2[0-4]\d|25[0-5])(\.(1?\d\d?|2[0-4]\d|25[0-5])){3}$/ ) {
    return 1;
  }
  return 0;
}

# validate a ipv4 subnet/cidr
sub validSubnet {
  my $subnet = shift;
  unless ( $subnet =~ /^\d{1,3}(\.\d{1,3}){3}\/\d{1,2}/) {
    printf "%s -> wrong IP/CIDR format\n", $subnet;
    return 0;
  }
  my ($ip, $cidr) = split (/\//, $subnet);
  unless ( validIPv4($ip) ) {
    printf "%s -> wrong IP\n", $ip;
    return 0;
  }
  unless ( ($cidr >= 0) and ($cidr <= 32) ) {
    printf "%s -> wrong CIDR\n", $cidr;
    return 0;
  }
  return 1;
}

# Receives a valid cidr
# Returns a ipv4 netmask
sub mask {
}

# Receives a valid subnet(ipv4/cidr)
# Returns an array of decimal values with low, high and range.
sub ipRange {
  my $subnet = shift;
  my ($ip, $cidr) = split(/\//, $subnet);
  my $network_ip = networkAddr($subnet);
  my $broadcast_ip = broadcastAddr($subnet);
  my $low = ip2dec($network_ip);
  my $high = ip2dec($broadcast_ip);
  my $range = $high - $low;
  return ($low, $high, $range);
}

# Receives a valid subnet(ipv4/cidr) Returns a network IP.
sub networkAddr {
  my $subnet = shift;
  my ($ip, $cidr) = split(/\//, $subnet);
  my $dec = ip2dec($ip);
  my $zero = substr("0"x(32 - $cidr), 0);
  my $one = substr("1"x$cidr, 0);
  my $netmask = "$one$zero";
  #TODO (check cidr =1,32.
  my $range = 2 ** (32 - $cidr);
  if ( $range > 1 ){
    $range =- 2;
  }
  return $range
  
}

# Receives a valid subnet(ipv4/cidr) Returns a broadcast IP.
sub broadcastAddr {
  
}

sub ipInSub {
  
}

sub main {
  my $ip = "10.100.255.91";
  my $subnet = $ip."/32";

  if ( validSubnet($subnet) ) {
    printf "ftw!\n";
  }
  else {
    printf "fail!\n";
  }
}

main ();
