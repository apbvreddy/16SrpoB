#!/usr/local/bin/perl
use strict;
#use warnings;

my ($line,@line,$line_sq);
my $numArgs = $#ARGV + 1;
if ($numArgs != 2) {
  print "perl program.pl <IDTit file> <ids.bl6 file>\n";
  exit;
}
my $idtit = $ARGV[0];
my ($pf_idtit,$sf_idtit)=split(/\./,$idtit);
my $idbl6 = $ARGV[1];
my @key=read_f2a($idtit);
my %fh_seq=ff2hash($idbl6);
my $wf = "$pf_idtit.txt";$wf=~s/1.txt/.txt/;
open (WF,">$wf") || die "cannot open \"$wf\": $!";
print WF "$key[0]\n";
for (my $i=1; $i<=$#key; $i++){
  #print "$key[$i]\t";
  my @col=split(/_/,$key[$i]);
  my $id=$col[0];
  print WF "$key[$i]_$fh_seq{$id}\n";
  CONTINUE_01:
}
exit;
#====================================================
#READ FILE TO AN ARRAY
#my @key=read_f2a($rf);
sub read_f2a
{
  my $rf = $_[0];
  open (RF,$rf) || die "cannot open \"$rf\": $!";
  my @rec=<RF>;
  close(RF);
  chomp(@rec);
  return (@rec);
}
#====================================================
#READ NCBI-NT FASTA WITH SINGLE SEQUENCE RECARD FILE TO AN HASH
#my %fh_seq=ff2hash($ff);
sub ff2hash
{
  my $rf = $_[0];
  my %fhsq=();
  open (RF,"$rf") || die "cannot open \"$rf\": $!";
  while (my $rec=<RF>){
    #print "$rec";
    my @rec = split(/\t/,$rec);  
    #$fhsq{$rec[1]}=$rec[2];
    $fhsq{$rec[1]}="$rec[4] $rec[3]";$fhsq{$rec[1]}=~s/ /\//;
    #print "$rec[1]\t$rec[2]\n";
  }
  return(%fhsq);
}
#=================================================================
