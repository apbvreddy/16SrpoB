#!/usr/local/bin/perl
use strict;
use warnings;

my $numArgs = $#ARGV + 1;
if ($numArgs ne 2) {
  print "perl program.pl <fnau/fau_file> <RecLength>\n";
  print "this program converts singe record sequence to multiple records\n";
  print "Make sure that name of inputfile has 'u' sufix\n";
  exit;
}
my $fnau = $ARGV[0];
my $rlen = $ARGV[1];
my ($pf_fnau,$sf_fnau)=split(/\./,$fnau);
my @key=read_f2a($ARGV[0]);
my $wf="$pf_fnau.fna";
open (WF,">$wf") || die "cannot open \"$wf\": $!";
for (my $i=0; $i <= $#key;$i++){
    if ($key[$i]=~m/>/){
      #print "$key[$i]\n";
      my $i2=$i+1;
      my $len=length($key[$i2]);
      #print "$key[$i2]\n$len\n\n";
      my $h100=$len/$rlen;my $t10=$len%$rlen;my $int=int($h100);my $pos=$int*$rlen;
      #print "$h100\t$int\t$t10\n";
      my @sqs= $key[$i2] =~ /.{$rlen}/g;
      #print "@sqs\n\n";
      print WF "$key[$i]\n";
      my $k=$#sqs+1;$sqs[$k]=substr($key[$i2],$pos,$t10);
      for (my $j=0; $j <= $k;$j++){
        print WF "$sqs[$j]\n";
        #print "$j\n$sqs[$j]\n";
      }
    }
}
close(RF);
exit;
######################################################
#=====================================================
#READ FILE TO AN ARRAY
#my @key=read_f2a($rf);
sub read_f2a
{
  my $rf = $_[0];
  open (RF,"$rf") || die "cannot open \"$rf\": $!";
  my @rec=<RF>;
  close(RF);
  chomp(@rec);
  return (@rec);
}
#======================================================
