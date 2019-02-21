plot_signif_between_groups <- function(freq_data, meta_table, kruskal.wallis.table, grouping_column, range = "all", terms, pvalue.cutoff) {
  
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
        groups <- as.factor(meta_table[, grouping_column])
        data <- freq_data[rownames(freq_data) %in% rownames(meta_table), ]
        data <- data[, colSums(data) > 0]
  
        if(dim(data)[1] != dim(meta_table)[1]) {
          meta_table <- meta_table[rownames(meta_table) %in% rownames(data), ]
          groups <- as.factor(meta_table[, grouping_column])
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
    		dftmp <- NULL
    		tmp <- data.frame(data[,i], groups, rep(paste(i," padj = ", round(kruskal.wallis.table[kruskal.wallis.table$id == i, "padj"], 5), sep=""),dim(data)[1]))
    		tmp2 <- data.frame(rep (round (kruskal.wallis.table[kruskal.wallis.table$id == i, "padj"], 5), dim(data)[1]))
    		dftmp <- cbind(tmp, tmp2)
    		if(is.null(df)) {df <- dftmp;} else { df <- rbind(df, dftmp)} 
	}

	colnames(df) <- c("Value", "Group", "Measure", "padj")
	grouping_column <- "Group"

	# Load library for the Dunn's comparisons
	library(PMCMR)

	s <- combn(unique(as.character(df[, grouping_column])), 2)
	df_pw <- NULL
	for(k in unique(as.character(df$Measure))) {
	    #We need to calculate the coordinate to draw pair-wise significance lines
	    #for this we calculate bas as the maximum value
	    bas <- max(df[(df$Measure==k), "Value"])
	    
	    #Calculate increments as 10% of the maximum values
	    inc <- 0.1 * bas
	    
	    #Give an initial increment
	    bas <- bas + inc
	    for(l in 1:dim(s)[2]) {
	        data <- df[(df$Measure==k) & (df[,grouping_column]==s[1,l] | df[,grouping_column]==s[2,l]),]
	        #Perform DunnÆs post-hoc test 
	        tmp <- c(k,s[1,l],s[2,l],bas,paste(sprintf("%.2g",tryCatch( (out <- posthoc.kruskal.dunn.test(x=data$Value, g= data[, grouping_column], p.adjust.method="BH"))[[3]][1] ,error=function(e) NULL)), "", sep=""))
	        
	        #Ignore if post-hoc test fails
	        if(!is.na(as.numeric(tmp[length(tmp)]))) {
	            
	            #Only retain those pairs where the p-values are significant
	            if(as.numeric(tmp[length(tmp)]) < 0.05){
	                if(is.null(df_pw)) {df_pw <- tmp} else {df_pw <- rbind(df_pw, tmp)}
	                
	                #Generate the next position
	                bas <- bas + inc
	            }
	        }
	    }  
	}
	df_pw <- data.frame(row.names=NULL, df_pw)
	names(df_pw) <- c("Measure", "from", "to", "y", "p")
	
	df$Measure <- gsub(" padj =", "\n padj =", df$Measure)
	df_pw$Measure <- gsub(" padj =", "\n padj =", df_pw$Measure)

	p <- ggplot(aes_string(x=grouping_column,y="Value",color=grouping_column),data=df)
	p <- p + geom_boxplot() + geom_jitter(position = position_jitter(height = 0, width=0))
	p <- p + theme_bw()
	p <- p + geom_point(size=5, alpha=0.2)
	
	p <- p + theme(axis.text.x=element_text(size=12)) + theme(strip.text.x = element_text(size = 22, colour = "black"))+theme(text = element_text(size=18))
	p <- p + facet_wrap(~ Measure, scales="free",ncol=10)+ylab("Frequency (Normalised)") + xlab("Group")
	
	#This loop will generate the lines and signficances
	for(i in 1:dim(df_pw)[1]){
	  p <- p + geom_path(inherit.aes=F,aes(x,y), data = data.frame(x = c(which(levels(df[,grouping_column]) == as.character(df_pw[i,"from"])), which(levels(df[,grouping_column]) == as.character(df_pw[i,"to"]))), y = c(as.numeric(as.character(df_pw[i,"y"])), as.numeric(as.character(df_pw[i,"y"]))), Measure = c(as.character(df_pw[i,"Measure"]), as.character(df_pw[i,"Measure"]))), color="black",lineend = "butt",arrow = arrow(angle = 90, ends = "both", length = unit(0.1, "inches"))) 
	  p <- p + geom_text(inherit.aes=F,aes(x=x,y=y,label=label), data = data.frame(x=(which(levels(df[,grouping_column]) == as.character(df_pw[i,"from"])) + which(levels(df[,grouping_column]) == as.character(df_pw[i,"to"])))/2, y = as.numeric(as.character(df_pw[i,"y"])), Measure = as.character(df_pw[i,"Measure"]), label = as.character(cut(as.numeric(as.character(df_pw[i,"p"])), breaks = c(-Inf, 0.001, 0.01, 0.05, Inf), label = c("***", "**", "*", "")))))
	}
	
	#We are going to use orthogonal colours palette followed by greyscale values should we run out of assignments
	colours <- c("#F0A3FF", "#0075DC", "#993F00","#4C005C","#2BCE48","#FFCC99","#808080","#94FFB5","#8F7C00","#9DCC00","#C20088","#003380","#FFA405","#FFA8BB","#426600","#FF0010","#5EF1F2","#00998F","#740AFF","#990000","#FFFF00",grey.colors(1000));
	p <- p + scale_color_manual(grouping_column,values=colours)
	
	p <- p + theme(strip.background = element_rect(fill="grey")) + theme(panel.margin = unit(0.5, "lines"))

	return(p)
}
