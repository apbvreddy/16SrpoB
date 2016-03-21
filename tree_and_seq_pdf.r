#!/usr/bin/Rscript
##########################################################################################################
#||||||||||||||||||||||||||||||| To make R graph of the Tree ||||||||||||||||||||||||||||||||||||
##########################################################################################################
library(ape)
library(extrafont)

MyTree <- read.tree("$1_ids_new.ph")
tit <- read.table(file="$1_IDTit.txt")
titc=tit[[1]];
#uknw=read.table(file="$1_Sample16S.fna")
uknw=read.table(file="$1_SampleID.fna")
sq=uknw[[1]]
#-------------------------------
#To change the order of IDTitles
#-------------------------------
for (i in 1:21){
  for (j in 1:21){
    if(grepl(MyTree$tip.label[i],titc[j])){
      ttit=titc[i];titc[i]=titc[j];titc[j]=ttit;
      #break;
    }
  }
}

pdf("$1.pdf",width=8.5,height=8.5)
#layout(matrix(1:2, 1, 2))

par(mar = c(0, 0, 0, 0),oma = c(0.5, 0.5, 0.5, 0.5),mfrow = c(3, 2))
m <- rbind(c(1,1),c(1,1),c(2,2))
layout(m)

#-----------
#Tree Plot-1
#-----------
par(mar=c(0.25,0.25,0.25,0.25))
plot(MyTree,type="phylo",cex=0.9,font=2,edge.color='COLOR',edge.width=1,edge.lty=1,adj=0)

for (i in 1:21){
  if(grepl("$1",MyTree$tip.label[i])) k=i;
}
tiplabels(MyTree$tip.label[k],k,adj=0,cex=0.9,font=2)
#title(main= "Tree with top 20 related $2 (GenbankID Species name Mismatches/Seq-length)",adj=0)

#PLOT-3
#---------------------
#Unknown 16S sequence
#---------------------

par(mar=c(0.5,0.5,2.0,0.5))
plot(1:23,1:23,type='n',bty ="n",axes=F,frame.plot=F, xaxt='n', ann=FALSE, yaxt='n')
text(1,22,labels=sq[1],adj=0,cex=1,font=2,col="COLOR")
for (i in 2:22){
  j=23-(i);
  text(1,j,labels=sq[i],adj=0,cex=0.9)
}

#===========================================================================
dev.off()
