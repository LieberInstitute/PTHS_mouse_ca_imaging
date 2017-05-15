# 
library(EBImage)
library(jaffelab)
library(matlabr)
library(reshape2)
library(ggplot2)
library(R.matlab)
library(zoo)
source('get_cells.R')

########################
# load JHPCE matlab 2013a
# system('module load matlab')
load('rdas/pheno_test.rda')

i = 1
######################
# preprocessing script

for (i in seq_along(pd)){
  ########################
  # run the matlab scripts
  if(TRUE){
  code = c(paste0("filename='",pd$imgPath[i],"';"),
           '[img, fgmask, bgmask] = unlabeled_caimaging_video(filename);',
           paste0("saveImg = '",pd$imgMat[i],"';"),
           paste0("imwrite(img(:,:,1), '",pd$alignedImg[i],"')"),
              "for k = 2:size(img,3)",
           paste0("imwrite(img(:,:,k), '",pd$alignedImg[i],"', 'writemode', 'append');"),
           "end", "save(saveImg, 'bgmask','fgmask')")
  res = run_matlab_code(code)
  }
  ######################
  # read in matlab file
  fgmask = Image(t(readMat(pd$imgMat[i])$fgmask))
  bgmask = Image(t(readMat(pd$imgMat[i])$bgmask))
  img = readImage(pd$alignedImg[i]) #load in aligned image
  
  #############
  # find traces
  out = getCells(img,fgmask,bgmask)
  # drop traces in negatives b/c faces
  writeImage(out$fgmask,files = pd$maskImg[i])
  #F0 = rollmean(out$traces,50,align = 'center',fill  =NA)
  
  #############
  # plot traces
  # dat = data.frame(traces)
  # dat$time = seq(nrow(traces))/nrow(traces)*5
  # datLong = melt(dat,id.vars = 'time')
  # ggplot(data = datLong,aes(x = time,y = value,color = variable))+ geom_line()
 }