# CICD Template for Docker Images running R jobs and Azure container registries

## Description

This is a template repo that nay serve as a starting point for new workflows based on R scripts and allow for the migration of applications to Azure. With very little configuration, the continuous integration and deployment of containerised R code is easily automated.

The CICD pipline does the following:
1. Deploy a container registry
2. Build a Docker image running the provided R script
3. Push the image to the registry

Commits to 'main' triggers a workflow run that deploys a container image for testing. It may also be triggered manually. 

A second workflow deploying a container instance for production use may be triggered manually. 

## Getting started

### Clone the repo and connect with GitHub

If using RStudio, the simplest approach might be to create a new project via version control.

*Should this fail, you may not have the necessary permissions to clone repos within the organisation. You may need to generate personal access token (PAT) and use the `git clone <repo-url>` command from a terminal.*

1. Go to File > New Project > Version Control > Git
2. Paste in the url for this repo and provide your own name for the project
3. Click Create Project
4. Open a terminal in RStudio (it should open in the current working directory) and run the following commands:

```
git remote set-url origin <url-for-this-repo>
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

Make sure to modify the following files:

- R script
   1. The first few lines of the sample R script shows how to connect to blob storage and retrieving a file. Make sure to change the resource names and file names as needed.
   2. Simillarly, at the bottom of the script, sample code shows how to upload a file to blob storage.
  
- Dockerfile
   1. Uncomment the line with the 'install.packages()' command **OR** use the script called install.packages.r to install the required packages.
   2. Make sure that COPY, RUN and CMD commands refer to the correct filename, e.g. if you call your main script something else than script.r.

- .github/workflows/workflow.yml and .github/workflows/workflow_release_prod.yml
   1. set the correct values for all variables under `ENV:`

*Note that if you're changing if you're changing the cpu or memory settings, you will need to first delete the ACI(s) before running the workflow.*

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
      --name "appname" \
      --role Owner \
      --scopes /subscriptions/<your-subscription-id>/resourceGroups/<your-resource-group-name> \
      --sdk-auth
```

*Note that using the 'Owner' role is not considered best practice as it allows the SP to perform much more than we actually need. You may therefore choose to create a more restricted custom role and assign it to the SP. This may be based on the Contributor role with added permissions to assign managed identities.*

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

## Deploying for test and production

The GitHub Actions workflow is set up such that test releases are triggered by commits to the main branch. The test release wortkflow may also be triggered manually. Deployment of container instances for production use can only be triggered manually. This setup is intended as a safeguard allowing users to test that the test ACI runs correctly before deploying the same changes that go into production.

### Checking logs

This can be done using the portal or with Azure CLI:

```
az container logs --resource-group your-rg-name --name  aci-name
```