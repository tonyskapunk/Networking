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

#ipv4 to bin(32bits)
sub ip2bin {
  my $ip = shift;
  my $bin = dec2bin(ip2dec($ip));
  return $bin;
}

# binbit2dec (8bits)
sub binbit2dec {
  my $bin = shift;
  return unpack("C", pack("B8", $bin));
}

# bin2dec (32bits)
sub bin2dec {
  my $bin = shift;
  return ip2dec(bin2ipv4($bin));
}

# dec (32bit) to ipv4
sub dec2ip {
  my $dec = shift;
  my $bin = dec2bin($dec);
  my @ip = ();
  $bin =~ s/([01]{8})([01]{8})([01]{8})([01]{8})/\1 \2 \3 \4/;
  my @octets = split(/ /, $bin);
  foreach my $octet (@octets) {
    push(@ip, binbit2dec($octet));
  }
  return join(".", @ip);
}

# bin(32bit) to ipv4
sub bin2ipv4 {
  my $bin = shift;
  my @ip = ();
  $bin =~ s/([01]{8})([01]{8})([01]{8})([01]{8})/\1.\2.\3.\4/;
  my @octets = split(/\./, $bin);
  foreach my $octet (@octets) {
    push(@ip, binbit2dec($octet));
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

# Receives a valid subnet(ipv4/cidr) Returns a network IPv4.
sub networkAddrIpv4 {
  my $subnet = shift;
  my $network_ip = dec2ip(networkAddrDec($subnet));
  return $network_ip;
}

# Receives a valid subnet(ipv4/cidr) Returns a network Dec IP.
sub networkAddrDec {
  my $subnet = shift;
  my ($ip, $cidr) = split(/\//, $subnet);
  my $bitmask = cidr2BitMask($cidr);
  my $bin_ip = ip2bin($ip);
  $bitmask = "0b$bitmask";
  $bin_ip = "0b$bin_ip";
  my $network_bin = $bitmask & $bin_ip;
  $network_bin =~ s/^0b//;
  return bin2dec($network_bin);
}

# Receives a valid CIDR Returns the Range of IPs.
sub cidrRange {
  my $cidr = shift;
  my $range = ( 2 ** (32 - $cidr));
  return $range
}

# Receives a valid subnet(ipv4/cidr) Returns a broadcast IPv4.
sub broadcastAddrIpv4 {
  my $subnet = shift;
  my $broadcast_ip = dec2ip(broadcastAddrDec($subnet));
  return $broadcast_ip;
}

# Receives a valid subnet(ipv4/cidr) Returns a broadcast Dec IP.
sub broadcastAddrDec {
  my $subnet = shift;
  my ($ip, $cidr) = split(/\//, $subnet);
  my $network_dec = networkAddrDec($subnet);
  my $range = cidrRange($cidr);
  my $broadcast_dec = $network_dec + $range - 1;
  return $broadcast_dec
}

sub ipInSub {
  
}

# Receives a valid cidr Returns a network mask in ipv4.
sub cidr2Ipv4Mask {
  my $cidr = shift;
  my $bitmask = cidr2BitMask($cidr);
  my $netmask = bin2ipv4($bitmask);
  return $netmask;
}

# Receives a valid CIDR Returns a binary Network Mask(32bits) divided in 4
# octets.
sub cidr2BitMask {
  my $cidr = shift;
  my $zero = substr("0"x(32 - $cidr), 0);
  my $one = substr("1"x$cidr, 0);
  my $netmask = "$one$zero";
  return $netmask;
}

# 
sub cidr2ip {
  
}

sub main {
  my $ip = "10.100.255.91";
  my $cidr = $ARGV[0];
  my $subnet = $ip."/$cidr";
  if ( validSubnet($subnet) ) {
    printf "cidr2Ipv4Mask: %s\n", cidr2Ipv4Mask($cidr);
    printf "networkAddrDec: %s\n", networkAddrDec($subnet);
    printf "networkAddrIpv4: %s\n", networkAddrIpv4($subnet);
    printf "cidrRange: %s\n", cidrRange($cidr);
    printf "broadcastAddrDec: %s\n", broadcastAddrDec($subnet);
    printf "broadcastAddrIpv4: %s\n", broadcastAddrIpv4($subnet);
  }
  else {
    printf "fail!\n";
  }
}

main ();
