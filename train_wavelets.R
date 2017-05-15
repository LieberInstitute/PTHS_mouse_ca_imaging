# read in and train calcium imaging datasets
library(EBImage)
library(parallel)
library(wavelets)

meanMat =function(filename){
  x = suppressWarnings(readImage(filename))
  apply(x,3,mean)
}

dir = 'images/training_data/'
pd = data.frame(FileID = paste0(rep(c('T','F'),each =10),rep(seq(10),each =2)))
pd$FilePath = paste0(dir,pd$FileID,'.tif')
table(file.exists(pd$FilePath))
pd$Label = factor(rep(c('T','F'),each =10),levels = c('F','T'))


################
# read in traces
traces = data.frame(t(do.call('rbind',mclapply(pd$FilePath,meanMat,mc.cores = detectCores()))))
names(traces) = pd$FileID


sc = read.table('tables/synthetic_control.data',header =F, sep ='')

wtData <- NULL

for (i in 1:ncol(traces)) {
   a <- traces[,i]
   wt <- dwt(a, filter="la8", boundary="periodic")
   
   wtData <- rbind(wtData, unlist(c(wt@W,wt@V[[wt@level]])))
  }
wtData <- as.data.frame(wtData)
plot(seq(1,598),wtData[1,], type = 'n')

for(i in 1:ncol(traces)) lines(seq(1,598),wtData[i,], col = pd$Label[i]) 

pca = prcomp(wtData)
plot(pca$x, pch = 21, bg = as.numeric(factor(pd$Label)))

wtSc <- data.frame(cbind(Label = pd$Label, wtData))

library(party)
ct <- ctree(Label ~ ., data=wtSc,
             controls =ctree_control(minsplit=30, minbucket=10, maxdepth=5))

pClassId <- predict(ct)

table(pd$Label, pClassId)

plot(traces[,1])
plot(traces[,11])
plot(traces[,12])








