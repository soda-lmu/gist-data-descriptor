# Function that pivots a dataset according to the given variables pivot_var_names creating two columns for each variable, one for each annotator
pivot_func <- function(dataset, pivot_var_names) {
  df <- dataset %>% select(report_name, ID, page_used, llm_year, llm_scope, llm_value, llm_unit, annotator_ID, all_of(pivot_var_names)) %>%
    group_by(report_name, ID, page_used, llm_year, llm_scope, llm_value, llm_unit) %>%
    mutate(annotator_rank = row_number()) %>%
    pivot_wider(names_from = annotator_rank, values_from = c(annotator_ID, all_of(pivot_var_names)), names_sep = "_") %>%
    ungroup()
  return (df) 
}


# Helper function to split a variable into two separate columns by checking whether the value came from annotator 1 or 2
split_by_annotator <- function(df, annotator_col, annotator_id_1, var_name) {
  var_name_1 <- paste0(var_name, "_1")
  var_name_2 <- paste0(var_name, "_2")
  
  df <- df %>%
    mutate(
      !!sym(var_name_2) := ifelse(!!sym(annotator_col) == !!sym(annotator_id_1), NA, !!sym(var_name_1)),
      !!sym(var_name_1) := ifelse(!is.na(!!sym(var_name_2)), NA, !!sym(var_name_1))
    )
  return(df)
}

# Function that splits dataset into duplicates and non-duplicates, pivots the duplicates and splits the non-duplicates into two columns
pivot_w_split <- function(dataset, vars) {
  # Before we can do the pivot, we need to split the non-duplicate rows from the cleaned data 
  # because for these rows we only get one column instead of two
  non_duplicates <- dataset %>% group_by(report_name, ID, page_used, llm_year, llm_scope, llm_value, llm_unit) %>% filter(n() == 1)
  duplicates <- dataset %>% group_by(report_name, ID, page_used, llm_year, llm_scope, llm_value, llm_unit) %>% filter(n() > 1)
  
  # Now we pivot the duplicates first
  pivot_corrections <- pivot_func(duplicates, vars) %>% arrange(report_name, ID, page_used, llm_year, llm_scope)
  
  # Get the annotators for each report (for later joining)
  annotators <- pivot_corrections %>% select(report_name, annotator_ID_1, annotator_ID_2) %>% group_by(report_name) %>% summarise(annotator_ID_1 = first(annotator_ID_1), annotator_ID_2 = first(annotator_ID_2))
  
  # Now we pivot the non-duplicates
  pivot_corrections_nd <- pivot_func(non_duplicates, vars) %>% arrange(report_name, ID, page_used, llm_year, llm_scope)
  
  # Split the non-duplicates into two columns using annotators
  pivot_corrections_nd <- pivot_corrections_nd %>% rename(annotator_ID = annotator_ID_1) %>%
    left_join(annotators, by = "report_name")

  for (var in vars) {
    pivot_corrections_nd <- split_by_annotator(pivot_corrections_nd, "annotator_ID", "annotator_ID_1", var)
  }
  
  # Merge the two datasets back together
  pivot_combined <- pivot_corrections %>% bind_rows(pivot_corrections_nd %>% select(-annotator_ID))
  
  return(pivot_combined)
}

# Function that compares values of annotator 1 and 2 and returns agreement 
agreement_func <- function(dataset, var_name) {
  agreement_name <- sym(paste0("agreement", "_", var_name))
  var_name_1 <- sym(paste0(var_name, "_1"))
  var_name_2 <- sym(paste0(var_name, "_2"))
  
  dataset %>% mutate(agreement = case_when(
    is.na({{var_name_1}}) & is.na({{var_name_2}}) ~ T,  
    {{var_name_1}} == {{var_name_2}} ~ T, 
    .default = F)) %>%
    rename({{agreement_name}} := agreement)
}

# Function that checks what value annotators agree on "Yes", "No" or "NA"
agreement_on_func <- function(dataset, var_name, agreement_val) {
  agreement_name <- sym(paste0("agreement", "_", var_name, "_", str_to_lower(agreement_val)))
  var_name_1 <- sym(paste0(var_name, "_1"))
  var_name_2 <- sym(paste0(var_name, "_2"))
  
  if (agreement_val == "NA") {
    dataset %>% mutate(agreement = case_when(
      is.na({{var_name_1}}) & is.na({{var_name_2}}) ~ T,  
      .default = F)) %>%
      rename({{agreement_name}} := agreement)
  }
  else {
    dataset %>% mutate(agreement = case_when(
      {{var_name_1}} == {{var_name_2}} & {{var_name_1}} == agreement_val ~ T, 
      .default = F)) %>%
      rename({{agreement_name}} := agreement)
  }
}