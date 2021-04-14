# Deploy a version of the model to be used
# Will need to mount this location so the container has
# access to read and write to the model.
# Only want to run this once, otherwise will overwrite the local model
source("model.R")

# Create a version of the model as defined in model.R
# New versions replace old versions
# If need to persist from previous version, input existing history and rng_seed
model <- MFITRandomModel$new(
  target_allocation = setNames(rep(1/4, 4), c("Control", "Walking", "Resistance", "Aerobic")),
  imbalance_tolerance = 4,
  version = "0.0.1",
  history = NULL,
  rng_seed = NULL
)

# Instead of this, would use a Docker volume which persists the model?
# New model would require updating the volume?
if(!file.exists("../data/model.rds")) {
  saveRDS(model, "../data/model.rds")  
} else {
  response <- menu(c("Yes", "No"), title="Do you want to overwrite the model?")
  if(response == 1) {
    saveRDS(model, "../data/model.rds") 
    cat("Model overwritten.\n")  
  } else {
    cat("Model not saved.\n")  
  }
  
}

