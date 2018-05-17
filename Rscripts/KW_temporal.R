KW_temporal <- function(freq_data, meta_table, condition, grouping_column, range = "all") {
	
      # Check and parse the range parameter for the dates to be considered
      if(range != "all") {
          range <- t(as.data.frame(strsplit(range, "-")))
          range <- gsub(" ", "", range)
    
          dates1 <- t(as.data.frame(strsplit(meta_table[, grouping_column], "-")))[,1]
          dates1 <- gsub(" ", "", dates1)
          dates2 <- t(as.data.frame(strsplit(meta_table[, grouping_column], "-")))[,2]
          dates2 <- gsub(" ", "", dates2)
    
          if( (!range[,1] %in% dates1) | (!range[,2] %in% dates2) ) {
            stop("Date range given does not match data. Insert appropriate range")
          } else {
            meta_table <- meta_table[( ( dates1 >= range[,1] | dates2 >= range[,1]) & ( dates1 <= range[,2] | dates2 <= range[,2]) ) , ]
          }
        }
  
        # Check that frequency data and data from meta table describe the same samples/searches
        meta_cond <- meta_table[apply(meta_table, 1, function(r) any(r %in% c(condition))),]
	groups <- as.factor(meta_cond[, grouping_column])
	
	data <- freq_data[rownames(freq_data) %in% rownames(meta_cond), ]
	data <- data[, colSums(data) > 0]
	
	if(dim(data)[1] != dim(meta_cond)[1]) {
	  meta_cond <- meta_cond[rownames(meta_cond) %in% rownames(data), ]
	  groups <- as.factor(meta_cond[, grouping_column])
	}

	# Perform Kruskal-Wallis test for each term for the given disease group
	kruskal.wallis.table <- data.frame()
	for (i in 1:dim(data)[2]) {
	    ks.test <- kruskal.test(data[,i], g=groups)
	    # Store the result in the data frame
	    kruskal.wallis.table <- rbind(kruskal.wallis.table,
	                                  data.frame(id=names(data)[i],
	                                             p.value=ks.test$p.value
	                                  ))
	    # Report number of values tested
	    cat(paste("Kruskal-Wallis test for ",names(data)[i]," ", i, "/", 
	              dim(data)[2], "; p-value=", ks.test$p.value,"\n", sep=""))
	}
	
	kruskal.wallis.table$E.value <- kruskal.wallis.table$p.value * dim(kruskal.wallis.table)[1]
	
	kruskal.wallis.table$FWER <- pbinom(q=0, p=kruskal.wallis.table$p.value, 
	                                    size=dim(kruskal.wallis.table)[1], lower.tail=FALSE)
	
	kruskal.wallis.table <- kruskal.wallis.table[order(kruskal.wallis.table$p.value,
	                                                   decreasing=FALSE), ]

	pvalues <- as.data.frame(kruskal.wallis.table$p.value)
	# adjust p-values using Benjamini-Hochberg correction
	padj = p.adjust(pvalues$`kruskal.wallis.table$p.value`, method = "BH")
	kruskal.wallis.table$padj <- padj
	kruskal.wallis.table <- kruskal.wallis.table[order(kruskal.wallis.table$padj,
                                                   decreasing=FALSE), ]
 	                                                  
	return(kruskal.wallis.table)
}
