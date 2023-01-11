# CICD Template for Docker Images running R jobs and Azure container registries

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

Note that the GitHub workflow, which 

### Required changes

Besides developing an R script, you will need to modify the following files:

1. Dockerfile
   1. Uncomment the line with the 'install.packages()' command **OR** use the script called install.packages.r to install the required packages.
   2. Make sure that COPY, RUN and CMD commands refer to the correct filename, e.g. if you call your main script something else than script.r.
2. .github/workflows/workflow.yml
   1. set RESOURCEGROUP_NAME: name-of-your-resource group
   2. set REGISTRY_NAME: containerregistryname
      1. Note that is has to be lower case letters only
   3. set SHORT_NAME: contregname (e.g.)

### Connecting GitHub to Azure

For the pipeline to work, GitHub must be granted permission to make changes to your Azure environment.

### Testing your Docker image locally

The below commands build and run a Docker image. You will need to have Docker Desktop installed.

```
docker build -t imagename .
docker run imagename
```

 The -t (tag) parameter lets you provide a name for you Docker image. Make sure you're running these commands from the directory where the Dckerfile is located. The dot (.) indicates that the files and folders used to build the image are in the current directory.
