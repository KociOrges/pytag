plot_ordination <- function(nmds_res, grouping_column, use_ellipse = T, ell.kind = "se") {
  library(ggplot2)
  
  if(use_ellipse) {
    plot.new()
    ord <- ordiellipse(nmds_res[,1:2], as.factor(nmds_res[, grouping_column]) ,display = "sites", kind = ell.kind, conf = 0.95, label = T)
    dev.off()
    
    veganCovEllipse <- function (cov, center = c(0, 0), scale = 1, npoints = 100) 
    {
      theta <- (0:npoints) * 2 * pi/npoints
      Circle <- cbind(cos(theta), sin(theta))
      t(center + scale * t(Circle %*% chol(cov)))
    }
    
    #Generate ellipse points
    df_ell <- data.frame()
    for(g in levels(nmds_res[,grouping_column])){
      if(g!="" && (g %in% names(ord))){
        
        df_ell <- rbind(df_ell, cbind(as.data.frame(with(nmds_res[nmds_res[, grouping_column] == g,],
                                                         veganCovEllipse(ord[[g]]$cov,ord[[g]]$center,ord[[g]]$scale)))
                                      ,Group=g))
      }
    }
    
    col.ind = which( colnames(nmds_res) == grouping_column )
    colnames(nmds_res)[3] = "Group"
    
    #Generate mean values from NMDS plot grouped on Disease condition
    NMDS.mean=aggregate(nmds_res[,1:2], list(group=nmds_res$Group), mean)
    
    #=== NMDS with 95% SE/SD Ellipses
    p <- ggplot(data = nmds_res, aes(NMDS1, NMDS2, colour = Group))
    p <- p + theme_bw() + geom_point(aes(colour = Group, shape = Group))
    p <- p + geom_path(data = df_ell, aes(NMDS1, NMDS2), size=1, linetype=2)
    p <- p + annotate("text", x = NMDS.mean$NMDS1, y = NMDS.mean$NMDS2, label = NMDS.mean$group)
    
  } else {
  	col.ind = which( colnames(nmds_res) == grouping_column )
    colnames(nmds_res)[3] = "Group"
  	
    #Generate mean values from NMDS plot grouped on Disease condition
    NMDS.mean=aggregate(nmds_res[,1:2], list(group=nmds_res$Group), mean)
    
    #=== NMDS plot
    p <- ggplot(data = nmds_res, aes(NMDS1, NMDS2, colour = Group))
    p <- p + theme_bw() + geom_point(aes(colour = Group, shape = Group))
    p <- p + annotate("text", x = NMDS.mean$NMDS1, y = NMDS.mean$NMDS2, label = NMDS.mean$group)
  }
  
  return(p)
}