FROM alpine:3.10

ENV TERRAFORM_VERSION=0.13.5
ENV KUBECTL_VERSION=v1.18.2
ENV HELM_VERSION=v3.2.4

WORKDIR /app

RUN apk --no-cache update \
  && apk upgrade \
  && apk --no-cache add curl git wget unzip openssh jq bind-tools bash python \
  && wget /app https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O terraform.zip ; unzip /app/terraform.zip \
  && chmod +x /app/terraform; mv /app/terraform /usr/local/bin/; rm /app/terraform.zip \
  && wget --no-check-certificate -P /app https://get.helm.sh/helm-$HELM_VERSION-linux-386.tar.gz ; tar -xzvf /app/helm-$HELM_VERSION-linux-386.tar.gz \
  && mv /app/linux-386/helm /usr/local/bin/helm; rm /app/helm-$HELM_VERSION-linux-386.tar.gz \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl; chmod +x /app/kubectl; mv /app/kubectl /usr/local/bin/ \
  && apk add --no-cache python3 py3-pip

RUN set -x && \
    apk add --update libintl && \
    apk add --virtual build_deps gettext &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps 

RUN apk update && apk add \
	ca-certificates \
	groff \
	less \
	python \
	py-pip \
	&& rm -rf /var/cache/apk/* \
  && pip install pip --upgrade \
  && pip install awscli