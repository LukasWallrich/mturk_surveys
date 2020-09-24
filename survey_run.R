#load packages and set auth variables
library(pyMTurkR)
library(magrittr)
source("parameters.R") #Includes setting of access keys
options(pyMTurkR.sandbox = F)

AccountBalance()


# variable to index number of completed assignments
completed <- 0
total <- 45

# list to store assignments into
allassigns <- list()

# Number of assignments per iteration
# If >9, will get charged 40% instead of 20%!
# Smaller number might help to keep HIT closer to top if data collection 
# is extraordinarily slow (e.g., in country with few MTurk workers)
assignmentsPerBatch <- 9

#Create first HIT
HTML_question <- readLines("survey_details.html") %>% paste(collapse = "\n")
current_HIT <- CreateHIT(question = HTML_question, hit.type = HITType_id, 
          expiration = seconds(days = 4),
          assignments = min(assignmentsPerBatch, total-completed)) 

#Preview HIT if created in sandbox mode: 
#browseURL(paste0("https://workersandbox.mturk.com/mturk/preview?groupId=", HITType_id)) 

repeat {
  st <- status(current_HIT$HITId, verbose = FALSE) 
  p <- st$NumberOfAssignmentsPending
  a <- st$NumberOfAssignmentsAvailable
  if (length(p) == 0) g <- "0"
  if (length(a) == 0) g <- "0"
  print(paste0(Sys.time(), ": pending: ", p, "; available: ", a))
  
  # check if all assignmentsPerBatch have been completed
  if (as.numeric(p)+as.numeric(a) == 0) {
    # if yes, retrieve submitted assignments
    w <- length(allassigns) + 1
    allassigns[[w]] <- GetAssignment(hit = current_HIT$HITId)
    
    # assign blocking qualification to workers who completed previous HIT
    AssignQualification(compl_qual_id, allassigns[[w]]$WorkerId, verbose = T)
    
    # increment number of completed assignments
    completed <- completed + length(allassigns[[w]]) 
    
    # optionally display total assignments completed thus far
    message(paste("Total assignments completed: ", completed, "\n", sep=""))
    
    # check if enough assignments have been completed
    if(completed < total) {    
      # if not, create another HIT
      current_HIT <- CreateHIT(hit.type = HITType_id,
                       assignments = min(assignmentsPerBatch, total-completed),
                       expiration = seconds(days = 4),
                       question = HTML_question)
      # wait some time and check again
      Sys.sleep(600)
    } else {
      # if total met, exit loop:
      break
    }
  } else {
    # wait some time and check again
    Sys.sleep(60) # TIME (IN SECONDS) TO WAIT BETWEEN CHECKING FOR ASSIGNMENTS
  }
}
