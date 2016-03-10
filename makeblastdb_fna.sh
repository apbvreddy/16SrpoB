makeblastdb -in $1.fna -dbtype nucl -title $1 -parse_seqids -hash_index -out $1 -logfile $1.log
