library(jaffelab)

dir = paste0(getwd(),'/images')

pd = data.frame(FileID = ss(list.files(path = dir, pattern = '.tif',recursive = T),'/'))
pd$imgPath = list.files(path = dir, pattern = '.tif',recursive = T,full.names = T)
pd$imgMat = paste0(getwd(),'/rdas/',pd$FileID,'_img.mat')
pd$imgRda = paste0(getwd(),'/rdas/',pd$FileID,'_img.rda')
pd$alignedImg = gsub('_img.mat','_aligned.tif',pd$imgMat)
pd$maskImg = gsub('_img.mat','_mask.tif',pd$imgMat)

save(pd,file = 'rdas/pheno_test.rda')
