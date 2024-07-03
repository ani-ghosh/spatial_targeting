library(terra)

calculate_suitability <- function(rasters, optimal_ranges) {
  # Normalize and weight rasters
  normalized <- lapply(seq_along(rasters), function(i) {
    r <- rasters[[i]]
    opt_from <- as.numeric(optimal_ranges$"Optimal From"[i])
    opt_to <- as.numeric(optimal_ranges$"Optimal To"[i])
    
    if (is.na(opt_from) || is.na(opt_to)) {
      return(r)  # If optimal values are not set, return the original raster
    }
    
    min_val <- as.numeric(optimal_ranges$"Min Value"[i])
    max_val <- as.numeric(optimal_ranges$"Max Value"[i])
    
    normalized <- (r - min_val) / (max_val - min_val)
    
    # Apply optimal range
    normalized <- ifel(r < opt_from, normalized * (r - min_val) / (opt_from - min_val),
                       ifel(r > opt_to, normalized * (max_val - r) / (max_val - opt_to),
                            1))
    
    return(normalized)
  })
  
  # Calculate geometric mean for combined layers
  combined <- normalized[optimal_ranges$Combine]
  if (length(combined) > 0) {
    combined_suitability <- combined[[1]]
    if (length(combined) > 1) {
      for (i in 2:length(combined)) {
        combined_suitability <- combined_suitability * combined[[i]]
      }
    }
    combined_suitability <- combined_suitability^(1/length(combined))
  } else {
    combined_suitability <- NULL
  }
  
  # Calculate arithmetic mean for non-combined layers
  non_combined <- normalized[!optimal_ranges$Combine]
  if (length(non_combined) > 0) {
    non_combined_suitability <- Reduce('+', non_combined) / length(non_combined)
  } else {
    non_combined_suitability <- NULL
  }
  
  # Combine results
  if (!is.null(combined_suitability) && !is.null(non_combined_suitability)) {
    suitability <- (combined_suitability + non_combined_suitability) / 2
  } else if (!is.null(combined_suitability)) {
    suitability <- combined_suitability
  } else if (!is.null(non_combined_suitability)) {
    suitability <- non_combined_suitability
  } else {
    stop("No valid rasters to process")
  }
  
  return(suitability)
}

calculate_similarity <- function(rasters, reference_points) {
  # Placeholder for similarity calculation
  # Implement your similarity algorithm here
}

calculate_statistics <- function(zone_raster, value_rasters, stats_type) {
  # Placeholder for statistics calculation
  # Implement your statistics algorithm here
}