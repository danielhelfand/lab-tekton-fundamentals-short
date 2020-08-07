FROM quay.io/eduk8s/workshop-dashboard:master

COPY --chown=1001:0 . /home/eduk8s/

ENV TKN_CLI_VERSION=0.11.0
RUN curl -kLs https://github.com/tektoncd/cli/releases/download/v${TKN_CLI_VERSION}/tkn_${TKN_CLI_VERSION}_Linux_x86_64.tar.gz -o /home/eduk8s/tkn.tar.gz && \
    tar -xvzf tkn.tar.gz && \
    chmod +x tkn && \
    mv tkn /opt/eduk8s/bin && \
    rm tkn.tar.gz && \
    chmod +x /home/eduk8s/workshop/setup.d/generate-yaml.sh && \
    fix-permissions /home/eduk8s