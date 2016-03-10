#!/usr/local/bin/perl
use strict;
use warnings;

my $numArgs = $#ARGV + 1;
if ($numArgs != 1) {
  print "perl program.pl <2col_text_file[filename,fasta_header_prefix]> \n";
  exit;
}
my $in_file = $ARGV[0];
my ($pf_if,$sf_if) = split(/\./,$in_file);
open (INF, $in_file) || die "cannot open \"$in_file\": $!";
chomp(my @line=<INF>);
close(INF);
my $count=0;
if (-e "$pf_if\_samples.fna"){`rm -rf $pf_if\_samples.fna`;}
for (my $i=0;$i<=$#line;$i++){
  $count=$count+1;
  my ($k1,$k2) = split(/,/,$line[$i]);
  #print  "$k1\t$k2\n";
  my $pipe='>>';if ($i == 0) {$pipe='>';}
  my $com01="cat $k1 | sed 's/>/>$k2\_/' | cut -d' ' -f1 $pipe $pf_if\_samples.fna";
  print "$com01\n";system($com01);
}
exit

