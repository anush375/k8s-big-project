FROM jenkins/jnlp-slave:3.10-1

USER root

# Install Docker for image construction.
RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-18.06.1-ce.tgz && \
    tar xzvf docker-18.06.1-ce.tgz && \
    mv docker/docker /usr/bin/ && \
    rm -rf docker && rm docker-18.06.1-ce.tgz && \
    chmod +x /usr/bin/docker

# Install dgoss and goss for image testing.
RUN curl -Lk https://raw.githubusercontent.com/aelsabbahy/goss/master/extras/dgoss/dgoss -o /usr/local/bin/dgoss && \
    chmod +rx /usr/local/bin/dgoss && \
    curl -Lk https://github.com/aelsabbahy/goss/releases/download/v0.3.6/goss-linux-amd64 -o /usr/local/bin/goss && \
    chmod +rx /usr/local/bin/goss

USER jenkins