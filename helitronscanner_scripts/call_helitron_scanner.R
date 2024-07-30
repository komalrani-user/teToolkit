# Run HelitronScanner
#
# This function runs HelitronScanner with the specified parameters.
#
# @param genome_path Path to the genome file.
# @param output_dir Directory for the output.
# @param genome_name Name of the genome.
# @param lcv_filepath_head Path to the head LCV file. Default is a predefined path.
# @param lcv_filepath_tail Path to the tail LCV file. Default is a predefined path.
# @return NULL
# @export
run_helitronscanner <- function(genome_path,
                                output_dir,
                                genome_name,
                                lcv_filepath_head = "/rds/projects/c/catonim-easyte/komal_te_project/TrainingSet/head.lcvs",
                                lcv_filepath_tail = "/rds/projects/c/catonim-easyte/komal_te_project/TrainingSet/tail.lcvs") {
  #load modules
  library(rJava)
  
  # Change to the HelitronScanner directory
  helitron_scanner_dir <- "/rds/projects/c/catonim-easyte/komal_te_project/HelitronScanner"
  setwd(helitron_scanner_dir)
  
  # Define the new output directory to create within HelitronScanner
  helitron_output_dir <- file.path(helitron_scanner_dir, "helitron_output_dir")
  
  # Create the helitron_dir if it doesn't exist
  if (!dir.exists(helitron_output_dir)) {
    dir.create(helitron_output_dir, recursive = TRUE)
  }
  
  # Scan head
  head_output <- file.path(output_dir, paste0(genome_name, "_head"))
  system2("java", args = c("-jar", "HelitronScanner.jar", "scanHead",
                           "-lf", lcv_filepath_head,
                           "-genome", genome_path,
                           "-bs", "0",
                           "-o", head_output))
  
  # Scan tail
  tail_output <- file.path(output_dir, paste0(genome_name, "_tail"))
  system2("java", args = c("-jar", "HelitronScanner.jar", "scanTail",
                           "-lf", lcv_filepath_tail,
                           "-genome", genome_path,
                           "-bs", "0",
                           "-o", tail_output))
  
  # Pair the termini scores
  paired_output <- file.path(output_dir, paste0(genome_name, "_paired"))
  system2("java", args = c("-jar", "HelitronScanner.jar", "pairends",
                           "-head_score", head_output,
                           "-tail_score", tail_output,
                           "-output", paired_output))
  
  # Draw Helitrons from the genome
  draw_output <- file.path(output_dir, paste0(genome_name, "_draw"))
  system2("java", args = c("-jar", "HelitronScanner.jar", "draw",
                           "-pscore", paired_output,
                           "-genome", genome_path,
                           "-output", draw_output,
                           "-pure_helitron"))
}

# Example usage
genome_path <- "/rds/projects/c/catonim-easyte/komal_te_project/tir_learner/ncbi_dataset/data/GCF_000001735.4/GCF_000001735.4_TAIR10.1_genomic.fna"
output_dir <- "/rds/projects/c/catonim-easyte/komal_te_project/HelitronScanner/helitron_output_dir"
genome_name <- "Arabidopsis"

run_helitronscanner(genome_path, output_dir, genome_name)
