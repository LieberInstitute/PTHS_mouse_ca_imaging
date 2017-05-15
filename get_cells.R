# filter for sanity/testing
getCells = function(img,fgmask,bgmask) {
	require(EBImage)
  disp = function(x) EBImage::display(x,method = 'raster')
  
	## extract data from stack in nuclei
  imgMat = apply(img,3,as.numeric) # ca imaging video
  
  fgNum = as.numeric(fgmask)# for all forground regions
  fgIndexes = split(which(fgNum > 0), fgNum[fgNum > 0])
	fgMat = sapply(fgIndexes, function(i) {
	  colMeans(imgMat[i,]) 
	})
	
	# background subtract regions
	bgMat = colMeans(imgMat[which(as.numeric(bgmask) > 0),]) 
	fgMat = fgMat-matrix(rep(bgMat,ncol(fgMat)), nrow = nrow(fgMat))
	
	# find regions with non-negative regions
	keepInd = apply(fgMat,2,function(x) mean(x)>0)
	fgMat = fgMat[,keepInd]
	for(i in which(!keepInd)){
	  fgmask[fgmask==i] = 0
	}
	
	out = list(fgMat = fgMat, fgmask = fgmask)
	return(out)
}

