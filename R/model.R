#' @title
#' MFIT Randomisation Model
#'
#' @description
#' A randomisation model for MFIT which satisfies the RARING API requirements
MFITRandomModel <- R6::R6Class("MFITRandomModel",

  public = list(

    #' @field The models target allocations
    target_allocation = NULL,
    #' @field The number of arms in the model
    num_arms = 0,
    #' @field The MWU imbalance parameter value
    imbalance_tolerance = 0,
    #' @field The history of allocations from the model
    history = NULL,
    #' @field The current RNG seed for the model
    rng_seed = NULL,
    #' @field The model version in MAJOR.MINOR.PATCH format
    version = NULL,
    
    #' @description
    #' Create a new instance of an MFITRandomModel
    #' @param target_allocation A named numeric vector giving the target allocation ratio to arms
    #' @param imbalance_tolerance The imbalance tolerance parameter for MWU model.
    #' @param history The starting history of allocations from the model
    #' @param rng_seed The RNG state
    initialize = function(
      target_allocation = NULL,
      imbalance_tolerance = NULL,
      history = NULL,
      rng_seed = NULL,
      version = NULL
    ) {
      if(is.null(names(target_allocation))) {
        names(target_allocation) <- seq_along(target_allocation)
      }
      self$target_allocation <- target_allocation
      self$num_arms <- length(target_allocation)
      self$imbalance_tolerance <- imbalance_tolerance
      self$history <- history
      self$version <- version
      if(is.null(rng_seed)) {
        if(!exists(".Random.seed", .GlobalEnv)) set.seed(NULL)
        rng_seed <- .GlobalEnv$.Random.seed
      }
      self$rng_seed <- rng_seed
    },
    
    #' @description 
    #' The name of the randomisation model.
    #' @return A string giving the model name.
    get_name = function() {
      "MFIT Model"
    },

    #' @description 
    #' The description of the randomisation model.
    #' @return A string giving the model description.
    get_description = function() {
      "Randomisation model for the MFIT trial."
    },

    #' @description 
    #' The version of the randomisation model
    #' @return A string giving the version of the model in x.x.x format.
    get_version = function() {
      self$version
    },

    #' @description 
    #' Returns a description of the random model parameters required.
    #' @return A list giving the required model parameters in the form
    #' 
    #'  key             value
    #'  name            str: short display name of parameter
    #'  description     str: human readable description
    #'  data_type       str: string, int, float, date
    #'  length          [optional] length of string
    get_parameter_descriptions = function() {
      # par_desc <- toJSON(
      #   list("target_allocations" = list(
      #     "name" = "Target Allocations",
      #     "description" = "The target allocation for each arm in the trial",
      #     "data_type" = "float",
      #     "length" = 4)),
      #   pretty = TRUE
      # )
      par_desc <- toJSON(
        list(
          "pr_control" = list(
            "name" = "Target allocation to control",
            "description" = "The target allocation probability/weighting to the control arm",
            "data_type" = "float",
            "length" = 1),
          "pr_walking" = list(
            "name" = "Target allocation to walking intervention",
            "description" = "The target allocation probability/weighting to the walking arm",
            "data_type" = "float",
            "length" = 1),
          "pr_resistance" = list(
            "name" = "Target allocation to resistance intervention",
            "description" = "The target allocation probability/weighting to the resistance arm",
            "data_type" = "float",
            "length" = 1),
          "pr_aerobic" = list(
            "name" = "Target allocation to aerobic + resistance intervention",
            "description" = "The target allocation probability/weighting to the aerobic + resistance arm",
            "data_type" = "float",
            "length" = 1),
          "imbalance_tolerance" = list(
            "name" = "Imbalance tolerance",
            "descripion" = "The imbalance tolerance parameter for Mass-Weighted Urn Randomisation",
            "data_type" = "float",
            "length" = 1
          )),
        pretty = TRUE
      )
      return(par_desc)
    },

    #' Returns a description of the inputs required for each random allocation.
    #' @return A list giving the inputs as a list (may be NULL if not inputs required)
    #' key             value
    #' name            str: short display name of input
    #' description     str: human readable description
    #' data_type       str: string, integer, float
    #' length          [optional] length of string
    get_parameter_input_descriptions = function() {
      return(NULL)
    },
    
    #' @description
    #' Return the number of allocations to each arm.
    #' @return A table giving the number of allocations to each arm.
    num_allocations = function() {
      a <- names(self$target_allocation)
      h <- self$history
      as.integer(table(factor(h, levels = a)))
    },
    
    #' @description 
    #' Return the current conditional allocation probability given current state.
    #' @return A numeric vector with one element per arm giving that arms allocation probability.
    get_conditional_prob = function() {
      n <- self$num_allocations()
      w <- self$target_allocation / sum(self$target_allocation)
      p <- pmax(self$imbalance_tolerance * w - n + (sum(n) + 1)*w, 0)
      return(p / sum(p))
    },

    #' @description 
    #' Generate a single allocation from the randomisation model
    random_allocation = function(inputs = NULL) {
      # Persist stored RNG state into R session
      if(!exists(".Random.seed", .GlobalEnv)) set.seed(NULL)
      assign(".Random.seed", self$rng_seed, envir = .GlobalEnv)
      # Generate allocation from model
      p <- self$get_conditional_prob()
      u <- runif(1)
      y <- findInterval(u, cumsum(c(0, p)))
      a <- names(self$target_allocation)[y]
      # Save the updated RNG state and model history
      self$history <- c(self$history, a)
      self$rng_seed <- .GlobalEnv$.Random.seed
      return(a)
    }

  ) # End public fields

) # End model class definition
