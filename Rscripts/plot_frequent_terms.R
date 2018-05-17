plot_frequent_terms <- function(freq_data, meta_table, grouping_column, range = "all", terms = 20) {

	# Check and parse the range parameter for the dates to be considered
	if(range != "all") {
          range <- t(as.data.frame(strsplit(range, "-")))
          range <- gsub(" ", "", range)
    
          dates1 <- t(as.data.frame(strsplit(meta_table$Date, "-")))[,1]
          dates1 <- gsub(" ", "", dates1)
          dates2 <- t(as.data.frame(strsplit(meta_table$Date, "-")))[,2]
          dates2 <- gsub(" ", "", dates2)
    
          if( (!range[,1] %in% dates1) | (!range[,2] %in% dates2) ) {
            stop("Date range given does not match data. Insert appropriate range")
          } else {
            meta_table <- meta_table[( ( dates1 >= range[,1] | dates2 >= range[,1]) & ( dates1 <= range[,2] | dates2 <= range[,2]) ) , ]
          }
        }
    
	# Check that frequency data and data from meta table describe the same samples/searches
        data <- freq_data[rownames(freq_data) %in% rownames(meta_table), ]
        data <- data[, colSums(data) > 0]
  
	if(dim(data)[1] != dim(meta_table)[1]) {
          meta_table <- meta_table[rownames(meta_table) %in% rownames(data), ]
        }
  
  	# Keep the top number of terms as specified from parameter 'terms'
	freq_terms <- data[, order(colSums(data), decreasing=TRUE)][,1:terms]
	freq_terms$Group <- meta_table[, grouping_column]
	freq_terms_melt <- melt(freq_terms, id="Group")
 
 	aggr_freq_terms <- aggregate( freq_terms_melt$value ~ freq_terms_melt$variable + freq_terms_melt$Group, freq_terms_melt , sum )
  
 	colnames(aggr_freq_terms) <- c("Terms", "Group", "Value") 
 	sort_freq_terms <- aggr_freq_terms[ order(aggr_freq_terms$Value, decreasing = TRUE),]
 
 	p<-ggplot(data=sort_freq_terms, aes(y=Value, x=reorder(Terms, Value), fill=Group))  +
     	geom_bar(stat="identity") + xlab("Terms") + ylab("Total Frequency (Normalised)")+
     	theme_minimal() + coord_flip() + theme(plot.title=element_text(face="bold", size=11)) + theme(axis.text.y = element_text(size = 9, colour = "black")) + theme(text = element_text(size=10))
	
	return(p)
}
