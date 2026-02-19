library(tidyverse)

# This script is meant to update the annotation dataset to exclude rows which no longer exist in gold standard

# Load the datasets
gs <- read_csv("data/processed/combined_annotations/gold_standard_with_ISINs_edited_revised.csv")
annotations <- read_csv("data/processed/combined_annotations/annotation_dataset.csv")

# Check which merge_ids in annotations are not in gs
merge_ids_gs <- unique(gs$merge_id)
merge_ids_annotations <- unique(annotations$merge_id)
merge_ids_to_remove <- setdiff(merge_ids_annotations, merge_ids_gs)

# Test
annotations |> filter(merge_id %in% merge_ids_to_remove) |> View()

# Remove rows from annotations where merge_id is in merge_ids_to_remove
annotations_updated <- annotations |> filter(!merge_id %in% merge_ids_to_remove)

# Save updated annotations dataset
write_csv(annotations_updated, "data/processed/combined_annotations/annotation_dataset_updated.csv")
