#!/usr/local/bin/perl
use strict;
use warnings;

my $numArgs = $#ARGV + 1;
if ($numArgs != 1) {
  print "perl program.pl <fnau/fau>\n";
  exit;
}
my $fnauf = $ARGV[0];
open (MFF,$fnauf) || die "cannot open \"$fnauf\": $!";
while (my $line1=<MFF>){
   if (substr($line1,0,1) eq '>'){
      my $fasta_file = $line1; chomp($fasta_file); $fasta_file =~ s/>//g;$fasta_file.="_SampleID.fnau";
      open (FF,">$fasta_file") || die "cannot open \"$fasta_file\": $!";
      print FF "$line1";
      my $line2=<MFF>;
      print FF "$line2";
      close(FF);
   }
}
close(MFF);
exit;
