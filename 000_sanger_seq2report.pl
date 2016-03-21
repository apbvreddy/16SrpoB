#!/usr/local/bin/perl
use strict;
use warnings;

my $numArgs = $#ARGV + 1;
if ($numArgs != 2) {
  CONTINUE_999:
  print "perl program.pl <SangerSeq:16s/rpoB_fna_file> <DataBase>\n";
  print "================= CHOOSE ONE OF THE FOLLOWING DATABASES =================================\n";
  print "myco16s = Compared with rpoB extracted from European Nucleotide Archive Database\n";
  print "ntogrb = Compared with rpoB extracted from NT and Other_Genomic Database\n";
  print "rpob = Compared with rpoB extracted from European Nucleotide Archive Database\n";
  print "ncbi16s = Compared with NCBI 16S database\n";
  print "rdp16s = Compared with Ribosomal Database Program 16S database\n";
  print "________________________________________________________________________________________\n";
  exit;
}
my $f16s = $ARGV[0];
my $db16s = $ARGV[1];
#my $msa = $ARGV[2]; 
my $msa = 'clo';
my ($pf_f16s,$sf_f16s)=split(/\./,$f16s);
my $SHARED="/home/shared/VIJAY/TOOLS";
my $INPDB="/home/shared/VIJAY/INPDB";
my $CPD=`find ~/ -name "16SrpoB"`;	#Program Directory
chomp($CPD);
print "$CPD\n\n";
my %repo=('rdp16s','16S','ncbi16s','16S','myco16s','16S','rpob','rpoB','ntogrb','rpoB');
my %colo=('16S','green3','rpoB','blue');
my $mf2sf = "perl $SHARED/f2f_multi_rec_seq_to_one_rec_seq.pl";
my $ccw = "perl $SHARED/combine_two_files_column_wise.pl";
my $sf2mf = "perl $SHARED/f2f_one_seq_rec_to_multiple_seq_rec.pl";
my $ff2sidn = "perl $CPD/split_fastaf2_SampleIDnamed_files.pl";

my $ncbi16s="$INPDB/16SMicrobial_lpsnmyco_dr";
my $myco16s="$INPDB/lpsn_myco_uqid";
my $rpob = "$INPDB/ena_rpob_98pid";
my $rdp16s="$INPDB/cultured_ABF_98piduniq";
my $ntogrb="$INPDB/ntog_rpoB_ena_100pid";
my $db;
if ($db16s =~ m/rdp16s/){print "*** USING RDP 16S ONLY TO COMPARE ***\n";$db=$rdp16s;}
elsif ($db16s =~ m/rpob/){print "*** USING ena rpoB database ONLY TO COMPARE ***\n";$db=$rpob;}
elsif ($db16s =~ m/ntogrb/){print "*** USING NTOG rpoB database ONLY TO COMPARE ***\n";$db=$ntogrb;}
elsif ($db16s =~ m/ncbi16s/){print "*** USING NCBI16S database ONLY TO COMPARE ***\n";$db=$ncbi16s;}
elsif ($db16s =~ m/myco16s/){print "*** USING LPSN Mycobacteria database ONLY TO COMPARE ***\n";$db=$myco16s;}
else {goto CONTINUE_999;}

my $pf_if=$pf_f16s;
my $in_file=$pf_f16s."_seqmatch_new.txt";
my @d16sids;

#goto CONTINUE_99;
my $com002="perl $CPD/006_reformat_SeqMatch_output.pl $f16s $db16s";
print "$com002\n";system ($com002);

#CONTINUE_99:
open (RF,$in_file) || die "cannot open \"$in_file\": $!";
while (my $line=<RF>){
  chomp($line);
  #print "$line\n";
  #if (!$line){print "Empty Record\n";exit;}
  if (!$line){print "Empty Record\n";$line=<RF>;	#reads Titles
    @d16sids=create_ids_file();
  }
}
close(RF);

print "@d16sids\n";
my $d16sids=join("\n",@d16sids);
open (WF,">$pf_if\_uniqids.txt") || die "cannot open \"$pf_if\_uniqids.txt\": $!";
print WF "$d16sids\n";
close(WF);

#	To extract sequences from main RDB 16s database
extract_from_blastdb($db,"$pf_if\_uniqids");
my $com02="cat $f16s $pf_if\_uniqids.fna | cut -d' ' -f1 | sed 's/lcl|//' > $pf_if\_cd16s.fna";
print "$com02\n";system($com02);

create_blastdb("$pf_if\_cd16s");
my $com03="grep '>' $pf_f16s.fna | sed 's/>//' > $pf_f16s\_ids.txt";
print "$com03\n";system($com03);

#	Extracting 16s equivalent sequence region
my $com1="$mf2sf $f16s $f16s"."u";
print "$com1\n";system($com1);
#	Spliting the fnau multiple sequences to idnamed fnau files	
my $com2="$ff2sidn $f16s"."u";
print "$com2\n";system($com2);
open (RF,"$pf_f16s\_ids.txt") || die "cannot open \"$pf_f16s\_ids.txt\": $!";
while (my $line=<RF>){
  chomp($line);print "$line\n";
#	fnau to fna with 100nt per recard
  my $com2="$sf2mf $line"."_SampleID.fnau 100";
  print "$com2\n";system($com2);
  `tail -20 $line\_ids.txt > $line\_ids20.txt`;
  `sed 's/^/grep -m1 /' $line\_ids20.txt | sed 's/\$/ $in_file/' > $line\_info.sh`;
  `chmod 0755 $line\_info.sh`;
  `./$line\_info.sh > $line\_info.txt`;
  `head -1 $line\_ids.txt | sed 's/\$/_SampleID/' > $line\_IDTit1.txt`;
  `cut -f2,7 $line\_info.txt | sed 's/#.*//' | sed 's/\\s/_/g' | sed 's/[:(;.)]//g' >> $line\_IDTit1.txt`;
  extract_from_blastdb("$pf_if\_cd16s","$line\_ids");
  `sed 's/lcl|//' $line\_ids.fna > $line\_ids.fna1`;
  `mv $line\_ids.fna1 $line\_ids.fna`;

  #Local search to identify matching sequence region
  `$SHARED/usearch8 -search_local $line\_SampleID.fna -strand plus -db $line\_ids.fna -fulldp -evalue 0.01 -blast6out $line\_ids.bl6 -maxaccepts 99`;
  my $com012 = "cut -f2,9-10 $line\_ids.bl6 | sed 's/\t/ /' | sed 's/\t/-/' > $line\_ids_bl6_imf.txt";
  print "$com012\n";system($com012);

  my $com012b="perl $CPD/004_remove_duplicates_from_bl6ids.pl $line\_ids_bl6_imf.txt > $line\_ids_bl6.txt";
  print "$com012b\n";system($com012b);

  extract_from_blastdb("$pf_if\_cd16s","$line\_ids_bl6");
  `sed 's/lcl|//' $line\_ids_bl6.fna | cut -d':' -f1 > $line\_ids_bl6.fna1`;
  `mv $line\_ids_bl6.fna1 $line\_ids_bl6.fna`;
  #Global search to identify exact mismatches over the alaignment length
  `$SHARED/usearch8 -search_global $line\_SampleID.fnau -strand plus -db $line\_ids_bl6.fna -id 0.65 -blast6out $line\_ids.bl6`;

  my $com011="perl $CPD/007_to_assaigne_blast_global_pid.pl $line\_IDTit1.txt $line\_ids.bl6";
  print "$com011\n";system($com011);

  msa2tree("$line\_ids_bl6",$msa);

  `cut -d'_' -f1 $line\_IDTit.txt > $line\_IDTit_ids.txt`;
  `$ccw $line\_IDTit_ids.txt $line\_IDTit.txt > $line\_IDTit_2c.txt`;
  `perl $CPD/003b_substitute_IDs2IDTits.pl $line\_ids_bl6.ph $line\_IDTit_2c.txt | sed 's/:-/:/' > $line\_ids_new.ph`;

=pod
}
close(RF);
msa2tree("$pf_if\_cd16s","mus");
#CONTINUE_99:
open (RF,"$pf_f16s\_ids.txt") || die "cannot open \"$pf_f16s\_ids.txt\": $!";
while (my $line=<RF>){
  chomp($line);print "$line\n";
=cut

#	To create R_plotting script
  my $report = $repo{$db16s};my $color=$colo{$report};
  my $com008="sed 's/\$1/$line/g' $CPD/tree_and_seq_pdf.r | sed 's/\$2/$report/g' | sed 's/COLOR/$color/' > $line\_tree_and_seq_pdf.r";
  print "$com008\n";system ($com008);

  my $com008b="chmod 0755 $line\_tree_and_seq_pdf.r";
  print "$com008b\n";system ($com008b);

  my $com008c="./$line\_tree_and_seq_pdf.r";
  print "$com008c\n";system ($com008c);
  my $line1=$line;$line1=~s/_/-/g; `mv $line.pdf $line1.pdf`;
  my $com008d = "sed 's/SAMPLE/$line1/' $CPD/title_tree_and_seq_pdf.tex | sed 's/REPORT/$report/g' > $line\_title_tree_and_seq_pdf.tex";
  print "$com008d\n";system ($com008d);
  `chmod 0755 $line\_title_tree_and_seq_pdf.tex`; 
  my $com008e = "pdflatex $line\_title_tree_and_seq_pdf.tex";
  print "$com008e\n";system ($com008e); 

#exit;

}
close(RF);
my $sname=$in_file; $sname =~ s/_samples_.*//;
`mkdir PDF_REPORTS`;
`mv *pdf.pdf PDF_REPORTS/`;
#CONTINUE_99:
`mkdir PROCESSOR_EXPENSIVE_FILES`;
`mv $in_file $sname PROCESSOR_EXPENSIVE_FILES/`;
`mv $f16s PROCESSOR_EXPENSIVE_FILES/`;
`mkdir IMF`;
`mv *.* IMF/`;
`tar -zcf IMF.tgz IMF`;
`rm -rf IMF`;
print " ********************** Compleated Successfully  ************************************\n";
exit;

####################################################
#=============================================================================================
#       To cluster the 16S sequences and build tree
#msa2tree("$pf_cf1\_uqIDTits",$msa);
sub msa2tree{
  my ($pf_fnaf,$msa) = @_;
  my $muscle="$SHARED/muscle3.8.31_i86linux64";
  my $clustalo="$SHARED/clustalo-1.2.0-Ubuntu-x86_64";
  my $clustalw2="$SHARED/clustalw2";
  if ($msa eq 'clo'){
    #my $com012="$clustalo -i $pf_fnaf.fna -o $pf_fnaf.aln --full --guidetree-out=$pf_fnaf.ph --force --threads=40";	#Clustal Omega
    my $com012="$clustalo -i $pf_fnaf.fna -o $pf_fnaf.aln --full --force --threads=40"; #Clustal Omega
    print "Submitted to CLUSTAL OMEGA for multiple sequence alignment\n";
    print "$com012\n";system ($com012);
    my $com012b="$clustalw2 -infile=$pf_fnaf.aln -tree -quiet";
    print "$com012b\n";system ($com012b);
   } elsif ($msa eq 'clw2'){
    my $com012="$clustalw2 -infile=$pf_fnaf.fna -align -quiet";	#Clustalw2
    print "Submitted to CLUSTALW2 for multiple sequence alignment ... May take longer time\n";
    print "$com012\n";system ($com012);
   }else{
    print "Submitted to MUSCLE for multiple sequence alignment\n";
    my $com012="$muscle -in $pf_fnaf.fna -out $pf_fnaf\_mus.aln -clwstrict -quiet";	#Muscle
    print "$com012\n";system ($com012);
    my $com012b="$clustalw2 -infile=$pf_fnaf\_mus.aln -tree -quiet";
    print "$com012b\n";system ($com012b);
    my $com012c="mv $pf_fnaf\_mus.ph $pf_fnaf.ph";
    print "$com012c\n";system ($com012c);
  }
}
#===================================================
#	To create individual uniq hit IDs file from DB Sequence_Match output 
sub create_ids_file
{
  my @d16sids;
  CONTINUE_01:
  my $line=<RF>;
  chomp($line);
  #print "$line\n";
  #if (!$line){print "Empty Record\n";goto CONTINUE_01;}
  my (@col) = split(/\t/,$line);
  if (!$col[0]){goto CONTINUE_02;}
  my $wf="$col[0]_ids.txt";
  open (WF,">$wf") || die "cannot open \"$wf\": $!";
  print WF "$col[0]\n";print WF "$col[1]\n";
  push(@d16sids,$col[1]);
  while ($line=<RF>){
    chomp($line);
    #print "$line\n";
    if (!$line){
      #print "Empty Record\n";
      close(WF);goto CONTINUE_01;
    }
    my (@col) = split(/\t/,$line);
    print WF "$col[1]\n";
    push(@d16sids,$col[1]);
  }
  CONTINUE_02:
  print "TotalIDs = $#d16sids\n";
  my @filtered_16sids = do { my %seen; grep { !$seen{$_}++ } @d16sids};
  print "UniqIDs = $#filtered_16sids\n";
  return @filtered_16sids;
}
#===================================================
sub extract_from_blastdb
{
  my ($bldb,$pf_idsf)=@_;
  my $com01="blastdbcmd -db $bldb -entry_batch $pf_idsf.txt -out $pf_idsf.fna -outfmt %f";
  print "$com01\n";system($com01);
  return;
}
#===================================================
#create_blastdb(pf_fnaf);
sub create_blastdb
{
  my $pf_fnaf=$_[0];
  my $com01="makeblastdb -in $pf_fnaf.fna -dbtype nucl -title $pf_fnaf -out $pf_fnaf -parse_seqids -hash_index -logfile $pf_fnaf.log";
  print "$com01\n";system($com01);
  return;
}
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
