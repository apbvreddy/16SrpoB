####16SrpoB 
>16SrpoB is a package developed at USDA-VS for bacterial diognistics and classification. The toplevel perl script takes a given sequence of 16S or rpoB newly sequenced bacterial gene sequences to classify and phylogenetically by identifying the 20 most closely related characterized known sequences in the databases. 000_sanger_seq2report.pl is the top level script that calls remaining dependencies, tools and databases to perform thefunction and gives a USDA-VS certified report.
#####Needs following dependencies to be installed before running the software
######1. ncbi-blast-2.2.29+ needs to be installed
	>+ should be available from /usr/local/bin
######2. Following software should be available /home/shared/VIJAY/TOOLS folder (Ask for this folder)
	>+ 16S_logo.png
	>+ clustalo
	>+ clustalo-1.2.0-Ubuntu-x86_64
	>+ clustalw2
	>+ combine_two_files_column_wise.pl
	>+ f2f_multi_rec_seq_to_one_rec_seq.pl
	>+ f2f_one_seq_rec_to_multiple_seq_rec.pl
	>+ muscle3.8.31_i86linux64
	>+ RDPTools
	>+ rpoB_logo.png
	>+ usearch8
	>+ usearch8.0.1616_i86linux32
######3. Following Blast DataBases are needed at /home/shared/VIJAY/INPDB (Ask for databases)
	>+ 16SMicrobial_lpsnmyco_dr.fna
	>+ 16SMicrobial_lpsnmyco_dr.tit
	>+ 16SMicrobial_lpsnmyco_dr Blastdb
	>+ cultured_ABF_98piduniq.fna
	>+ cultured_ABF_98piduniq.tit
	>+ cultured_ABF_98piduniq Blastdb
	>+ ena_rpob_98pid.fna
	>+ ena_rpob_98pid.tit
	>+ ena_rpob_98pid Blastdb
	>+ lpsn_myco_uqid.fna
	>+ lpsn_myco_uqid.tit
	>+ lpsn_myco_uqid Blastdb
	>+ ntog_rpoB_ena_100pid.fna
	>+ ntog_rpoB_ena_100pid.tit
	>+ ntog_rpoB_ena_100pid Blastdb
