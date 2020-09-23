# Run Qualtrics surveys on MTurk with R

I have been running academic surveys on MTurk a couple of times, but find myself figuring out the same issues every single time. Therefore, here a record of how it can be done, with a couple of quality control steps added to the basic procedure. For now, these are primarily my own notes for future reference, but if anyone else finds them helpful, that'd be great.

Suggestions for how to do any of this better are very welcome - raising an Issue is probably easiest, but feel free to email me: lukas.wallrich@gmail.com

# Navigating this repo

This repo consists of four key files. 

- `survey_setup.Rmd` contains all the code that needs to be run once, to set everything up. It generates some MTurk 'entities' that need to be referenced later, their IDs should be added to `parameters.R` 
- `survey_template.html` is the HTML template used on mturk.com, which shows the survey link to workers and collects the survey code (generated on Qualtrics) from them - the code in `survey_setup.Rmd` customises the template, so that it does not need to be edited directly. 
- `survey_run.R` is a code that can be run continuously to manage data collection, while keeping each HIT to 9 respondents, in order to minimise MTurk fees. 
- Finally, `process_submissions.Rmd` contains some code to approve and reject survey submissions.

# Quality assurance steps

MTurk gives access to a diverse pool of subjects, and enables quick data collection, but there can be issues with data management and quality.
- *Prevent duplicate submissions* while running HITs of 9: MTurk charges double when more than 9 responses are requested to a HIT, therefore it makes sense to split up a survey into many HITs. However, that raises issues with duplicate responses. The approach here deals with that by *assigning a qualification* on MTurk after each batch of 9 is completed that prevents workers from participating in future batches.
- *Prevent submissions from duplicate IPs and false geo-locations* - geo-location can be checked in Qualtrics, while duplicate IPs require an external webservice.

# What else is needed?
- Qualtrics (or other) survey that generates a unique survey code and displays it at the end for each respondent - see here for how to do this: [Qualtrics support page](https://www.qualtrics.com/support/survey-platform/common-use-cases-rc/assigning-randomized-ids-to-respondents/)
- the pyMTurkR package, [documented here](https://www.rdocumentation.org/packages/pyMTurkR/versions/1.1.4). Note that it is actually a Python package wrapped into R, so the installation might take a few extra steps.

# ToDo:
- Add alternative survey_template_2.html that does not pass workerID to Qualtrics.