#!/usr/local/bin/perl
use strict;
#use warnings;

#system("clear");
my $numArgs = $#ARGV + 1;
if ($numArgs != 2) {
print "perl program.pl <ph_file_with_ids> <ID,IDTits_2ctext_file>\n";
  exit;
}
my @fnaf=read_f2a($ARGV[0]);
my @idTits=read_f2a($ARGV[1]);
my %idTits=();
for (my $i=0;$i<=$#idTits;$i++){
  my @dum=split(/,/,$idTits[$i]);
  $idTits{$dum[0]}=$dum[1];
  #print "$dum[0]\t$dum[1]\n";
}
my @idTits_keys;
foreach my $key (keys %idTits){
  push(@idTits_keys,"$key:");
}

#print "@idTits_keys\n";

for (my $i=0;$i<=$#fnaf;$i++){
 #print "$fnaf[$i]\n";
 for (my $j=0;$j<=$#idTits_keys;$j++){
  if ($fnaf[$i] =~ m/$idTits_keys[$j]/g){
    #print "$fnaf[$i]\t$idTits_keys[$j]\t";
    $idTits_keys[$j] =~ s/://g;
    #print "$idTits_keys[$j]\t";
    #print "$idTits{$idTits_keys[$j]}\n";
    $fnaf[$i] =~ s/$idTits_keys[$j]/$idTits{$idTits_keys[$j]}/;
    goto CONTINUE_1;
  }
 }
 CONTINUE_1:
 print "$fnaf[$i]\n";
}
exit;

####################################################################################
#==================================================================================
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
#====================================================
