# CICD Template for Docker Images running R jobs and Azure container registries

[![Deploy container registry and docker image](https://github.com/PeerChristensen/AzureDocker-CICD-Template/actions/workflows/workflow.yml/badge.svg)](https://github.com/PeerChristensen/AzureDocker-CICD-Template/actions/workflows/workflow.yml)

## Description

This is a template repo that nay serve as a starting point for new workflows based on R scripts and allow for the migration of current jobs to Azure. With very little configuration, the continuous integration and deployment of containerised R code is easily automated.

The CICD pipline does the following:
1. Deploy a container registry
2. Build a Docker image running the provided R script
3. Push the image to the registry

Commits to 'main' triggers a pipeline run. It may also be triggered manually.

## Getting started

### Clone the repo and connect with GitHub

If using RStudio, the simplest approach might be to create a new project via version control.

*Should this approach fail, you may not have the necessary permissions to clone repos within the organisation. In that case, you may need to generate personal access token (PAT) and use the `git clone <repo-url>` command from a terminal.*

1. Go to File > New Project > Version Control > Git
2. Paste in the url for this repo and provide your own name for the project
3. Click Create Project
4. Open a terminal in RStudio (it should open in the current working directory) and run the following commands:

```
git remote set-url origin https://github.com/PeerChristensen/testr.git
git push
```

Your local project is now connected to your new GitHub repo.
Changes can be committed through the RStudio interface or the command line, e.g. as shown below.

```
git add .
git commit -m "a short message describing any changes"
git push
```

Note that the GitHub Actions workflow, which builds and deploys your Docker container, is triggered by commits to the 'main' branch. You may therefore want to commit your work using feature branches. `git checkout -b feature_branch_name` and `git switch` are useful commands.

### Required code changes

- R script
   1. The first few lines of the sample R script shows how to connect to blob storage and retrieving a file. Make sure to change the resource names and file names as needed.
   2. Simillarly, at the bottom of the script, sample code shows how to upload a file to blob storage.  - Dockerfile
   3. For local development, omit the code used to connect to your key vault and provide the access key directly. However, do not expose this key by committing it to Git.
   4. Uncomment the line with the 'install.packages()' command **OR** use the script called install.packages.r to install the required packages.
   5. Make sure that COPY, RUN and CMD commands refer to the correct filename, e.g. if you call your main script something else than script.r.
- .github/workflows/workflow.yml
   1. set RESOURCEGROUP_NAME: name-of-your-resource group
   2. set REGISTRY_NAME: containerregistryname. Note that is has to be lower case letters only
   3. set SHORT_NAME: contregname (e.g.)

### Connecting GitHub to Azure

For the pipeline to work, GitHub must be granted permission to make changes to your Azure environment. This can be donw using the Azure CLI.

1. First, login to Azure. The command opens a browser window with the Azure login page.

```
az login
```

The value for "id" in the JSON output will be your subscription id.

2. Then, run the following command to create a Service Principal with contributor permissions to your resource group:

```
az ad sp create-for-rbac \
      --name "gh-actions-aci-test" \
      --role contributor \
      --scopes /subscriptions/<your-subscription-id>/resourceGroups/<your-resource-group-name> \
      --sdk-auth
```

3. Copy the JSON output.
4. In your GitHub repo, go to Settings > Secrets and variables > Actions
5. Create a new repository secret. It should be called AZURE_CREDENTIALS and its value should be the JSON string you just copied.

### Testing your Docker image locally

The below commands build and run a Docker image. You will need to have Docker Desktop installed.

```
docker build -t imagename .
docker run imagename
```

 The -t (tag) parameter lets you provide a name for you Docker image. Make sure you're running these commands from the directory where the Dckerfile is located. The dot (.) indicates that the files and folders used to build the image are in the current directory.

## Post deployment setup

1. Create a Container Instance in the Azure portal based on the uploaded image. 
2. After it's successfully deployed, go to the new ACI resource > Settings > Identity. Set the (system assigned) managed identity to "On". Then save and copy the Object ID.
3. Go to your key vault > Access policies and create a new policy with the 'Get' secret permission. Next, in the 'Principal' field, paste the object ID and select your ACI.

This allows your container instance to access the key vault by means of a Managed Identity.

