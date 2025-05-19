FROM ubuntu:24.04

USER root

RUN apt update && \
    apt install -y --no-install-recommends \
    python3 \
    python3-pip \
    ansible \
    sshpass \
    git \
    openssh-client \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

WORKDIR /workspace

COPY . /workspace

CMD ["./run_playbook.sh"]