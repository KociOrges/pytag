create_frequency_table <- function(data, ontology = "all") {
  
  # Words/terms that are assigned from the tagger to the same ontology entry and are described by a shared identifier, but are in a different form (e.g. coeliac disease and celieac disease), are put together as the occurence of the same term.
  
  # Extract the columns for the Ontological Terms and their Identifiers
  library(data.table)
  
  if(!"all" %in% ontology) {
    data = data[data$Ontology %in% ontology,]
  }
  
  terms_id <- NULL
  terms_id$terms <- data$Term
  terms_id$id <- data$Identifier
  terms_id <- as.data.table(terms_id)
  
  onto_terms_id <- data
  df <- terms_id[ , .(terms = list(terms)[[1]][1]), by = id]
  
  for(i in 1:dim(df)[1]) { 
    
    term = as.character(df$terms[i])
    id = as.character(df$id[i]) 
    # Check if any Terms have the same identifier. If so, then use the same name for each Term
    onto_terms_id$Term[onto_terms_id$Identifier == id] <- term
  }
  
  # When annotating a single abstract, Inflect package is used to avoid both singular and plural forms for a term to be included in the list of the identified terms. After the annotation, if a single word is found in both forms between different abstracts then their frequencies are put together and described by their singular form. The general case where a single word is found with a prefix of “s” is considered for the plural form.
  
  count <- 0
  uniq_terms <- unique(onto_terms_id$Term)
  for(i in 1:length(uniq_terms)){    
    
    term <- as.character(uniq_terms[i])
    term_pl <- paste(term,"s", sep="")
    
    count <- count + 1
    if(term_pl %in%  onto_terms_id$Term) {
      onto_terms_id$Term[onto_terms_id$Term == term_pl] <- term
    }
  }
  
  # Remove any special characters from the text of the identified ontological terms 
  onto_terms_id$Term = gsub("[^[:alnum:][:blank:]]", " ", onto_terms_id$Term)
  
  # Create the table with the frequencies of each term across every keyword
  onto_terms_freq <- table ( onto_terms_id$Keyword, onto_terms_id$Term )
  colnames(onto_terms_freq) <- gsub("\\.\\.+", ".", colnames(onto_terms_freq))
  colnames(onto_terms_freq) <- gsub("X", "", colnames(onto_terms_freq))
  
  # transpose the data.frame
  onto_terms_freq <- t(onto_terms_freq)
  
  df_rows <- row.names(onto_terms_freq)
  df_cols <- onto_terms_freq
  row.names(df_cols) <- NULL
  df <- as.data.frame(cbind(df_rows, df_cols))
  
  # collapse the rows with the same name
  onto_terms_aggr <- aggregate(. ~ df_rows, df, sum)
  row.names(onto_terms_aggr) <- onto_terms_aggr$df_rows
  onto_terms_aggr$df_rows <- NULL
  freq_table <- t(as.data.frame(do.call(cbind, onto_terms_aggr)))
  
  return(freq_table)
}