#!/usr/local/bin/perl
use strict;
#use warnings;

my ($line,@line,$line_sq);
my $numArgs = $#ARGV + 1;
if ($numArgs != 2) {
  print "perl program.pl <fna_file> <Database>\n";
  CONTINUE_999:
  exit;
}
my $fna = $ARGV[0];
my ($pf_fna,$sf_fna)=split(/\./,$fna);
my $db16s = $ARGV[1];

my $INPDB = "/home/shared/VIJAY/INPDB";
my $TOOLS = "/home/shared/VIJAY/TOOLS";

my $ncbi16s="$INPDB/16SMicrobial_lpsnmyco_dri.fna";
my $myco16s="$INPDB/lpsn_myco_uqid.fna";
my $rpob = "$INPDB/ena_rpob_98pid.fna";
my $rdp16s="$INPDB/cultured_ABF_98piduniq.fna";
my $ntogrb="$INPDB/ntog_rpoB_ena_100pid.fna";
my $db;
if ($db16s =~ m/rdp16s/){print "*** USING RDP 16S ONLY TO COMPARE ***\n";$db=$rdp16s;}
  elsif ($db16s =~ m/rpob/){print "*** USING ena rpoB database ONLY TO COMPARE ***\n";$db=$rpob;}
  elsif ($db16s =~ m/ntogrb/){print "*** USING NTOG rpoB database ONLY TO COMPARE ***\n";$db=$ntogrb;}
  elsif ($db16s =~ m/ncbi16s/){print "*** USING NCBI16S database ONLY TO COMPARE ***\n";$db=$ncbi16s;}
  elsif ($db16s =~ m/myco16s/){print "*** USING LPSN Mycobacteria database ONLY TO COMPARE ***\n";$db=$myco16s;}
else {print "==== DATABASE CODE NOT RECOGNIZED ====\n"; goto CONTINUE_999;}

my $sqmp="$TOOLS/RDPTools/SequenceMatch.jar";
my $seqmatch="java -jar $sqmp seqmatch -k 20 $db $pf_fna.fna > $pf_fna\_seqmatch.txt"; 
print "$seqmatch\n";system ($seqmatch);

#exit;

my $sqm="$pf_fna\_seqmatch.txt";my ($pf_sqm,$sf_sqm)=split(/\./,$sqm);
my @key=read_f2a($sqm);

my $myco16s_tit="$INPDB/lpsn_myco_uqid.tit";
my $ncbi16s_tit="$INPDB/16SMicrobial_lpsnmyco_dr.tit";
my $rpob_tit = "$INPDB/ena_rpob_98pid.tit";
my $rdp16s_tit="$INPDB/cultured_ABF_98piduniq.tit";
my $ntogrb_tit="$INPDB/ntog_rpoB_ena_100pid.tit";

my $tit;
if ($db16s =~ m/rdp16s/){print "*** USING NCBI 16S ONLY TO COMPARE ***\n";$tit=$rdp16s_tit;}
  elsif ($db16s =~ m/rpob/){print "*** USING rpoB ONLY TO COMPARE ***\n";$tit=$rpob_tit;}
  elsif ($db16s =~ m/myco16s/){print "*** USING rpoB ONLY TO COMPARE ***\n";$tit=$myco16s_tit;}
  elsif ($db16s =~ m/ntogrb/){print "*** USING rpoB ONLY TO COMPARE ***\n";$tit=$ntogrb_tit;}
  elsif ($db16s =~ m/ncbi16s/){print "*** USING NCBI 16S ONLY TO COMPARE ***\n";$tit=$ncbi16s_tit;}
else {print "==== DATABASE TITLES FILE  NOT RECOGNIZED ====\n"; goto CONTINUE_999;}

my %fh_seq=ff2hash($tit);
my $wf = "$pf_sqm\_new.txt";
open (WF,">$wf") || die "cannot open \"$wf\": $!";
print WF "\n";
print WF "$key[0]\n";
my $rcol0;
for (my $i=1; $i<=$#key; $i++){
  #print "$key[$i]\t";
  my @col=split(/\t/,$key[$i]);
  if ($i==1) {$rcol0=$col[0]}
  #print "$rcol0\t$col[0]\n";
  if ($i>1) {
     if ($rcol0 ne $col[0]){
       print WF "\n";
       $rcol0=$col[0]
     }
  }
  splice @col, 3, 0, 'not_calculated';
  splice @col, 6, 1;
  my $col=join("\t",@col);
  #print "$col[1]\n";
  print WF "$col\t";
  my $des=$fh_seq{$col[1]};$des =~ s/=/\t/;
  #print "$des\n";
  print WF "$des\n";

}

print "=========== COMPLEATED ===============";
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
    #chomp($rec);
    #print "$rec";
    $rec =~ m/>([\S\d]*?) (.*)/;  
    my $id=$1; my $des=$2;
    $fhsq{$id}=$des;
    #print "$id\n$des\n";
  }
  return(%fhsq);
}
#=================================================================
