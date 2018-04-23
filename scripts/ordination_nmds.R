ordination_nmds <- function(freq_data, meta_table) {
  
  # perform NDMS using 'bray-curtis' distance
  sol <- metaMDS(freq_data, distance = "bray", k = 2, trymax = 50)
  
  # keep the first two dimensions
  NMDS <- data.frame(NMDS1=sol$point[,1], NMDS2=sol$point[,2])
  
  # bind the columns from the meta_table to NMDS table
  for(i in 1:dim(meta_table)[2]) {
    NMDS <- cbind(NMDS, as.factor(meta_table[,i]))
    colnames(NMDS)[dim(NMDS)[2]] = colnames(meta_table)[i]
  }
  
  return(NMDS)
}