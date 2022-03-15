[![Ruby on Rails CI](https://img.shields.io/github/workflow/status/ministryofjustice/cloud-operations-slack-bot/Ruby%20on%20Rails%20CI/main?label=Tests&logo=Ruby&logoColor=crimson&style=for-the-badge&color=success)](https://github.com/ministryofjustice/cloud-operations-slack-bot/actions/workflows/rubyonrails.yml)  [![Docker Image CI](https://img.shields.io/github/workflow/status/ministryofjustice/cloud-operations-slack-bot/Docker%20Image%20CI/main?logo=Docker&style=for-the-badge&color=9cf)](https://github.com/ministryofjustice/cloud-operations-slack-bot/actions/workflows/docker-image.yml) [![CodeQL Scan](https://img.shields.io/github/workflow/status/ministryofjustice/cloud-operations-slack-bot/CodeQL?color=ff69b4&label=CodeQL%20Scan&logo=Ruby&logoColor=crimson&style=for-the-badge)](https://github.com/ministryofjustice/cloud-operations-slack-bot/actions/workflows/codeql-analysis.yml)  

# Cloud Operations Slack Bot :robot: ![Watchers](https://img.shields.io/github/watchers/ministryofjustice/cloud-operations-slack-bot?style=social)  

The purpose of this repository is to provide a Slack Bot for use in the MoJ [CloudOps](https://ministryofjustice.github.io/cloud-operations/#cloud-operations) team.  

In our search for a bot which met our needs we could not find any with the correct functionality. As such we are scratching our own itch!  

Initially the primary function of the repository will be to enable us to manage a list of team members.  

Upon being called to select a random team member the slack bot should then reply to the channel, tagging the user when doing so.  

## Local Development

To run this app locally, you will need to copy `.env.example` to `.env` file and must populate:  

```
SLACK_SIGNING_SECRET=
SLACK_OAUTH_TOKEN=
...
DB_PASSWORD=
```

You will see `Failure/Error: hex_hash = OpenSSL::HMAC.hexdigest(digest, signing_secret, sig_basestring)` when running RSpec if the file is not present.  

Available `Makefile` targets:  

- `make build`  
- `make run`  
- `make test`  

## Remote Deployment  

If you wish to release another Helm Chart upgrade to the k8s cluster in Cloud Platform, please follow the steps below:  

- Step :one: : Follow the [Cloud Platform guide](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html#how-to-use-kubectl-to-connect-to-the-cluster) to authenticate and configure your local `kubectl` to connect to the cluster.  


- Step :two: : Populate the below values in the `.env` file:  

```
ECR_URL= <can be found in the kubernetes secrets>
SECRET_KEY_BASE= #generate one by: openssl rand -base64 32
```  

Follow the [Cloud Platform guide](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials) to read secrets in kubernetes.  


- Step :three: : Update the appVersion value of the chart in `cloudopsbot/Chart.yaml` file to the appropriate values (an example: `v1.0.1`). Run the below command to get a list of available tags:  

```
git tag
```  

- Step :four: : use the below Makefile target to release a Helm chart upgrade:  

```
make deploy
```  

## Features / To Do :sparkles:  

- ✔️ Register a user, associate the channel ID request in the database 
- ✔️ Convert User Slack IDs to Usernames in messages  
- ✔️ Convert Channel Slack IDs to Channel Name in messages 
- :construction: Confirm User online prior to selection from list
- :construction: Create separate lists per channel
- :construction: Add a _plan my week_ feature. This feature would automatically generate a table of events and randomly select a user to host each event. 
- ✔️ Add a 'deregister' feature :wave: 
- ✔️ ~Heroku sleepiness~ Migrated to AWS on Cloud Platforms
- :construction: List all registered users in a channel 
- :construction: Add an icebreaker feature, maybe scrape from somewhere?
- :construction: Return form for more information related to ceremony

### Error Handling: 
- ✔️ "Select from a channel with no users"
- ✔️ "@CloudOpsBot help" add help output
- :construction: fuzzy user commands i.e. 'select' = 'choose'

### Bugs 

- Fix /tmp/db permission errors 999:root