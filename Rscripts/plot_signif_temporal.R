plot_signif_temporal <- function(freq_data, meta_table, kruskal.wallis.table, condition, grouping_column, range = "all", terms, pvalue.cutoff) {
  
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
        meta_cond <- meta_table[apply(meta_table, 1, function(r) any(r %in% c(condition))),]
	groups <- as.factor(meta_cond[, grouping_column])
	
	data <- freq_data[rownames(freq_data) %in% rownames(meta_cond), ]
	data <- data[, colSums(data) > 0]
	
	if(dim(data)[1] != dim(meta_cond)[1]) {
	  meta_cond <- meta_cond[rownames(meta_cond) %in% rownames(data), ]
	  groups <- as.factor(meta_cond[, grouping_column])
	}

	# Keep the significant terms based on pvalue.cutoff
	selected <- which(kruskal.wallis.table$padj < pvalue.cutoff)

	diff.cat.factor <- kruskal.wallis.table$id[selected]
	diff.cat <- as.vector(diff.cat.factor)
	cat("Number of significant terms: ", length(diff.cat))
	      
	if(missing(terms)) {
		terms = length(diff.cat)
	} else if (length(diff.cat) < terms) {
	  print("Number of terms given is longer that the length of significant terms. All significant ones will be returned.")
	  terms = length(diff.cat)
	}

	df <- NULL
	for(i in diff.cat[1:terms]) {
    		tmp <- data.frame(data[,i], groups, rep(paste(i," padj = ",round(kruskal.wallis.table[kruskal.wallis.table$id==i,"padj"],5),sep=""),dim(data)[1]))
    		if(is.null(df)){df<-tmp} else { df<-rbind(df,tmp)}
	}
	colnames(df) <- c("Value", "Date", "Term")
	df$Term <- gsub(" padj =", "\n padj =", df$Term)

	p <- ggplot(df, aes(x=Date,y=Value, group = 1)) + ylab("Frequency (Normalised)")
	p <- p + theme_bw()
	p <- p + theme(axis.text.x=element_text(size=7, angle=90, hjust=1, vjust=0.2)) + theme(axis.text.y=element_text(size=14)) +theme(strip.text.x = element_text(size = 14, colour = "black")) + theme(text = element_text(size=28)) + facet_wrap( ~ factor(df$Term, levels = unique(df$Term)), scales="free_x", ncol=25)
	p <- p + stat_summary(fun.y=mean, geom="point",color="#56B4E9", size=2) + stat_summary(fun.y=mean, geom="line",color="#56B4E9", size=1)

	return(p)
}
