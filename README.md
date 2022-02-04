# Cloud Operations Slack Bot :robot:  

The purpose of this repository is to provide a Slack Bot for use in the MoJ [CloudOps](https://ministryofjustice.github.io/cloud-operations/#cloud-operations) team.  

In our search for a bot which met our needs we could not find any with the correct functionality. As such we are scratching our own itch!  

Initially the primary function of the repository will be to enable us to manage a list of team members.  

Upon being called to select a random team member the slack bot should then reply to the channel, tagging the user when doing so.  

## Features :sparkles:  

- ✔️ Register a user, associate the channel ID request in the database 
- ✔️ Convert User Slack IDs to Usernames in messages  
- ✔️ Convert Channel Slack IDs to Channel Name in messages 
- :construction: Confirm User online prior to selection from list
- :construction: Create separate lists per channel
- :construction: Add a _plan my week_ feature. This feature would automatically generate a table of events and randomly select a user to host each event. 
- :construction: Add a 'deregister' feature :wave: 
- :construction: Heroku sleepiness

### Error Handling: 
- ✔️ "Select from a channel with no users"
- :construction: "@CloudOpsBot help" add help output
- :construction: fuzzy user commands i.e. 'select' = 'choose'