annotate.Cosmic = function(x, ...){
library(gridExtra)
library(rtracklayer)
library(stringr)
library(SomaticCancerAlterations)
library(GenomicRanges)
library(ggbio)
library(data.table)
library(plyr)
options(warn = -1)


var.info = cbind(variants[,13], variants[,1:5], variants[,10:11])
var.sub = cbind(variants[,1:2], (variants[,2]+1))
colnames(var.sub) = c("chr", "start", "end")
var.sub.gr  = makeGRangesFromDataFrame(var.sub)
ch = import.chain("hg19ToHg38.over.chain")
var.sub.gr.new = liftOver(var.sub.gr, ch)
var.sub.gr.new  = as.data.frame(var.sub.gr.new) # variants converted.... don't forget to check for discrepancy
var = var.sub.gr.new[,3:5]  
colnames(var) = c("chr_name", "start", "end")

oldtnew = cbind(var.sub[1:2], var[,2])
colnames(oldtnew) = c("chrom", "hg19_loc", "hg38_loc")
oldtnew2 = cbind(var.info, oldtnew[,3])
colnames(oldtnew2) = c("Geneid", "Chrom", "hg19_loc", "ref", "Variant", "Allele.Call", "Type", "Allele.Source", "hg38_loc")

# annotate using Cosmic Drivers
can = read.delim("Cosmic.grch38.parsed.CANCERonly.txt", header = F)
#pass = read.delim("Cosmic.grch38.parsed.PASSENGER.OTHERonly.txt", header = F)
#pass.loc = as.data.frame(str_match(pass$V9, "^(.*):(.*)-(.*)$")[,-1])
#pass.new = cbind(pass, pass.loc)
can.loc = as.data.frame(str_match(can$V9, "^(.*):(.*)-(.*)$")[,-1])
can.new = cbind(can, can.loc)
dimen = data.frame(dim(var))
rows = dimen[1,]
fo = matrix(0, nrow = rows, ncol = 10)
i = 1
for (i in 1:rows){
  id = match(var[i,2], can.new[,12], nomatch = 0)
  if(id >0){
    info = data.frame(cbind(var[i,], can.new[id,1:10]))
    dat = cbind(as.character(info[,1]), as.character(info[,2]), as.character(info[,3]), as.character(info[,4]),as.character(info[,5]), as.character(info[,6]), 
                as.character(info[,7]), as.character(info[,8]), as.character(info[,9]), as.character(info[,10]))
    fo[i,] = dat
   
  }else{            
  
  }
  
}
COSMIC= unique(data.frame(subset(fo, fo[,1]  > 0)))
colnames(COSMIC) = c("chrom", "start", "end", "geneid","cdslength", "tissue", "cancertype", "cosmicid", "cds_mutsyn", "varianttype")
return(COSMIC)


}



