FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nano
RUN apt-get update && apt-get install -y gnupg software-properties-common curl

# Install Google Cloud CLI (gcloud)

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-cli -y
      

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt-get update && apt-get install -y terraform
RUN touch /root/.bashrc
RUN terraform -install-autocomplete


# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin


# Install helm
RUN apt-get update && apt install -y apt-utils
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
RUN apt-get update && apt-get install apt-transport-https --yes
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update && apt-get install -y helm

# 
ARG JFROG_ARTIFACTORY_READ_USER
ARG JFROG_ARTIFACTORY_READ_TOKEN
RUN curl -u${JFROG_ARTIFACTORY_READ_USER}:${JFROG_ARTIFACTORY_READ_TOKEN} https://unity3d.jfrog.io/artifactory/api/npm/auth > ~/.npmrc
RUN helm repo add kronus https://unity3d.jfrog.io/artifactory/kronus-helm-prod/ --username $JFROG_ARTIFACTORY_READ_USER --password $JFROG_ARTIFACTORY_READ_TOKEN



# Add helm prometheus repo
RUN helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
RUN helm repo update



RUN mkdir -p /git
RUN mkdir -p /root/.config
RUN mkdir -p /root/.config/gcloud