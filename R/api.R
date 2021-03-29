library("rctrandr")
library("jsonlite")
library("DBI")
library("data.table")
library("plumber")

#* log some
#* @filter logging
function(req){
  cat(as.character(Sys.time()), " ",
      req$REQEST_METHOD, req$PATH_INFO, "-",
      req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR, "\n")
  # now forward the request for more processing
  forward()
}

#* log some
#* @filter id
function(req){
  # Identify user for audit trail
  # now forward the request for more processing
  forward()
}

#* Complete randomisation - think this should be put not get
#* @serializer json
#* @param numbertrt Number of treatment arms, e.g. 3
#* @param samplesize Sample size e.g. 10
#* @get /completerand
function(numbertrt, samplesize){
  tryCatch({
    
    # dbf = "/data/randr/randr.db"
    dbf="/share/randr.db"
    dbcon <- DBI::dbConnect(RSQLite::SQLite(), dbf)

    ntrt <- fromJSON(numbertrt)
    wgts <- rep(1/ntrt, ntrt)
    N <- fromJSON(samplesize)
    # wgts <- rep(0.5, 2); N = 3
    
    seed <- sample(100000:999999, N, replace = T)

    arm <- sapply(1:N, function(i){
      set.seed(seed[i])
      ll <- rctrandr::complete_rand(wgts, 1)
      ll$trt
    })
    
    if(!dbExistsTable(dbcon, "rand")){
      DBI::dbExecute(dbcon, 'CREATE TABLE rand (
        id integer primary key,
        seed integer,
        arm integer,
        date text,
        time text)')
    }

    d <- data.table(seed = seed,
                    arm = arm,
                    date = format(Sys.Date(),"%Y-%m-%d"),
                    time = format(Sys.time(),"%H:%M:%S"))

    DBI::dbWriteTable(dbcon, "rand", d, append = TRUE)
    # dbGetQuery(dbcon, "SELECT * FROM rand")
    DBI::dbDisconnect(dbcon)
    arm
  }, error = function(e) {
    return(list(error = e))
  }, finally = {
    message("Hit finally")
  })
}

#* Return current randomisation list
#* @serializer json
#* @get /randlist
function(){
  tryCatch({
    # dbf = "/data/randr/randr.db"
    dbf="/share/randr.db"
    dbcon <- dbConnect(RSQLite::SQLite(), dbf)
    
    if(!dbExistsTable(dbcon, "rand")){
      DBI::dbExecute(dbcon, 'CREATE TABLE rand (
        id integer primary key,
        seed integer,
        arm integer,
        date text,
        time text)')
    }
    
    d <- dbGetQuery(dbcon, "SELECT * FROM rand")
    DBI::dbDisconnect(dbcon)
    d
  }, error = function(e) {
    return(list(error = e))
  }, finally = {
    message("Hit finally")
  })
}


# Boilerplate examples follow:



#* Echo back the input
#* @param msg1 First part of msg
#* @param msg1 Second part of msg
#* @get /echo
function(msg1="", msg2=""){
  list(msg = paste0("First is: '", msg1, "'", " then '", msg2, "'"))
}
#* Plot a histogram
#* @serializer png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}
#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b){
  as.numeric(a) + as.numeric(b)
}
#* @get /add
add <- function(x, y){
  return(as.numeric(x) + as.numeric(y))
}
#* @get /add2
add2 <- function(x, y){ 
  list(result = as.numeric(x) + as.numeric(y))
}

