#!/usr/local/bin/perl
use strict;
#use warnings;

my ($line,@line,$line_sq);
my $numArgs = $#ARGV + 1;
if ($numArgs != 1) {
  print "perl program.pl <ids_bl6 file>\n";
  exit;
}
my $idbl6 = $ARGV[0];
my @key=read_f2a($idbl6);
#open (WF,">$wf") || die "cannot open \"$wf\": $!";
my %id_range=();
for (my $i=0; $i<=$#key; $i++){
  #print "$key[$i]\t";
  my @col=split(/ /,$key[$i]);
  my $id=$col[0];
  if (!$id_range{$id}){
      $id_range{$id}=$col[1]
    }else{
    my @k1=split(/-/,$id_range{$id});
    my @k2=split(/-/,$col[1]);
    #print "@k1\t@k2";
    my ($s,$e);
    if ($k1[0] <= $k2[0]) {$s=$k1[0];} else {$s=$k2[0];}
    if ($k1[1] >= $k2[1]) {$e=$k1[1];} else {$e=$k2[1];}
    $id_range{$id}="$s"."-"."$e";
  }
  #print "$id $id_range{$id}\n";
}
foreach my $key (keys %id_range){
  print "$key $id_range{$key}\n";
}


#close(WF)
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
#=================================================================
