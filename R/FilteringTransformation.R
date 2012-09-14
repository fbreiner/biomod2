# `FilteringTransformation` <-
# function(ProbData, CutOffdata)
# {
#     if(is.data.frame(ProbData)) {
#         N <- dim(ProbData)[2]
#         i <- 1
#         while(i <= N) {
#             if(sum(ProbData[,i])!=0) ProbData[ProbData[,i] < CutOffdata[i, 1],i] <- 0
#             i <- i + 1
#         }
#     }
#     else if(sum(ProbData) != 0) ProbData[ProbData < CutOffdata] <- 0
#     
#     return(ProbData)
# }
# 
# FilteringTransformation_v2 <-
# function(ProbData, CutOff){
#   ProbData[ProbData < CutOff] <- 0
#   return(ProbData)
# }

setGeneric("FilteringTransformation",
           function(data, threshold){
             standardGeneric("FilteringTransformation")
           })

setMethod('FilteringTransformation', signature(data='data.frame'), 
  function(data, threshold)
  {
    data <- data.matrix(data)
    data[t(t(data)<threshold)] <-0
    if(ncol(data)==1) data <- data[,1]
  	return(data)
  })

setMethod('FilteringTransformation', signature(data='matrix'), 
  function(data, threshold)
  {
    data <- as.data.frame(data)
    return(FilteringTransformation(data, threshold))
  })

setMethod('FilteringTransformation', signature(data='numeric'), 
  function(data, threshold)
  {
    data <- as.data.frame(data)
    return(FilteringTransformation(data, threshold))
  })

setMethod('FilteringTransformation', signature(data='RasterLayer'), 
  function(data, threshold)
  {
    return(reclassify(data,c(-Inf,threshold,0)))
  })

setMethod('FilteringTransformation', signature(data='RasterStack'), 
  function(data, threshold)
  {
    if(length(threshold) == 1){
      threshold <- rep(threshold, raster:::nlayers(data))
    }
    StkTmp <- raster:::stack()
    for(i in 1:raster:::nlayers(data)){
      StkTmp <- raster:::addLayer(StkTmp, FilteringTransformation(raster:::subset(data,i,drop=TRUE), threshold[i]))
    }
    return(StkTmp)
  })
          
setMethod('FilteringTransformation', signature(data='RasterBrick'), 
  function(data, threshold)
  {
    data <- raster:::stack(data)
    return(FilteringTransformation(data, threshold))
  })