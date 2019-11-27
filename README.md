# CI/CD pipeline using GCP services

### Goal
Build a lightweight CI/CD solution using Google Cloud produts/services.

The solution should be able to:
* build the application code and produce a runnable file
* build a Docker container able to run the application
* deploy the container using a Google Cloud solution (Google Kubernetes Engine)

### How does it work?
We will work with two code repositories: 
* one for the actual application code (it will also contain a small `Dockerfile` and a `cloudbuild.yaml` file) - a simple Spring Boot web application built with Gradle, in this case
* one for the pipeline, handling deployments and keeping a history of what's been built and deployed over time

A push to the application repository branch of our choice (let's say `master`) will trigger a **Google Cloud Build** that builds the source code, creates a Docker image that knows to run the application, pushes the image to Container Registry, then updates the Kubernetes deployment manifest and pushes the changes to the candidate branch of the pipeline repository. That push will trigger another Google Cloud Build which deploys the previous image into the Kubernetes cluster and commits the manifest to the production branch, in case of success. 

To simplify things, the [Cloud Shell][1] can be used for running the gcloud commands required for setting up the pipeline. The alternative is to install the Cloud SDK locally, by selecting the preferred OS from [here][2] and following the steps.

### Steps
1. [Create a new / select an existing GCP project][3]
In Cloud Shell, set the active project: 
    ```
    gcloud config set project [PROJECT_ID]
    ```
2. In Cloud Shell, prepare the PROJECT_ID variable for future use:
    ```
    PROJECT_ID=$(gcloud config get-value project)
    ```
3. In Cloud Shell, enable container, cloudbuild and sourcerepo APIs: 
    ```
    gcloud services enable container.googleapis.com cloudbuild.googleapis.com sourcerepo.googleapis.com
    ```
4. In Cloud Shell, create a Kubernetes cluster:
    ```
    gcloud container clusters create [CONTAINER_NAME] --num-nodes 1 --zone europe-west1
    ```
    \* there's no hard requiredment to use that specific zone, one can be picked from [here][4].
5. In Cloud Shell, create the pipeline repository:
    ```
    gcloud source repos create pipeline
    ```
6. In Cloud Shell, clone the pipeline repository and create the production branch:
    ```
    gcloud source repos clone pipeline
    git checkout -b production
    ```
7. Add two new files into the repository: 

* [cloudbuild-pipeline.yaml][5] as `cloudbuild.yaml` and [kubernetes.yaml.tpl][6] as `kubernetes.yaml.tpl` and commit the change

8. Create the candidate branch out of production and push the two branches
    ```
    git checkout -b candidate
    git push -u origin candidate
    git push -u origin production
    ```
9. Grand write permissions to the Cloud Build service account, for the pipeline repository
    ```
    PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"
    cat >/tmp/pipeline-policy.yaml <<EOF
    bindings:
    - members:
      - serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
      role: roles/source.writer
    EOF
    gcloud source repos set-iam-policy pipeline /tmp/pipeline-policy.yaml   
    ```
10. [Create a trigger][7] for the pipeline repository: 

* Create Trigger -> Select the pipeline repository, pick a name, select 'Branch' trigger type, use 'candidate' as Branch, select 'Cloud Build configuration file (yaml or json)' and the location of the cloud build file -> Create trigger

11. [Connect][7] the application repository: 

* Connect Repository -> Select GitHub (Cloud Build GitHub App) -> Continue -> Select GitHub Accout, select the repository -> Connect Repository -> Skip For Now

12. [Create a trigger][7] for the application repository: 

* Create Trigger -> Select the application repository, pick a name, select 'Branch' trigger type, use 'master' as Branch, select 'Cloud Build configuration file (yaml or json)' and the location of the cloud build file -> Create trigger

The same `pipeline` repository can be used for building and deploying multiple applications, by creating multiple pairs of branches, one `candidate` and one `production` branch for each. The branch names would need to be updated in both `cloudbuild.yaml` files.

[1]: https://console.cloud.google.com/?cloudshell=true
[2]: https://cloud.google.com/sdk/docs/quickstarts
[3]: https://console.cloud.google.com/cloud-resource-manager
[4]: https://cloud.google.com/about/locations 
[5]: ./pipeline/cloudbuild-pipeline.yaml
[6]: ./pipeline/kubernetes.yaml.tpl
[7]: https://console.cloud.google.com/cloud-build/triggers
