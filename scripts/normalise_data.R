normalise_data <- function(freq_data, annot_sum, by) {
	norm.method = match.arg(by, c("Total_number_of_references","Available_abstracts","Annotated_abstracts"))

	switch(norm.method,
		"Total_number_of_references" = (norm_data <- freq_data / annot_sum$Total_number_of_references),
		"Available_abstracts" = (norm_data <- freq_data / annot_sum$Available_abstracts),
		"Annotated_abstracts" = (norm_data <- freq_data / annot_sum$Annotated_abstracts),
	)
	return(norm_data)
}