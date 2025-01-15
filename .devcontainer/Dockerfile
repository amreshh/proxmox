FROM registry.opensuse.org/opensuse/leap:15.6

ENV OPENTOFU_VERSION="1.9.0"
ENV TALOS_VERSION="v1.9.1"

ADD ./opentofu.repo /etc/zypp/repos.d/opentofu.repo

RUN zypper --gpg-auto-import-keys refresh opentofu
RUN zypper --gpg-auto-import-keys refresh opentofu-source
RUN zypper install -y tar \
    gzip \
    git \
    helm \
    kubernetes-client \
    bash-completion \
    tofu-${OPENTOFU_VERSION}
RUN curl -L https://github.com/siderolabs/talos/releases/download/${TALOS_VERSION}/talosctl-linux-amd64 -o /usr/local/bin/talosctl && chmod +x /usr/local/bin/talosctl

RUN helm repo add cilium https://helm.cilium.io/ && helm repo update

RUN echo 'complete -C /usr/bin/tofu tofu' >>~/.bashrc
RUN echo 'alias ls="ls --color"' >>~/.bashrc
RUN echo 'source <(talosctl completion bash)' >>~/.bashrc
RUN echo 'source <(kubectl completion bash)' >>~/.bashrc
RUN echo 'source <(helm completion bash)' >>~/.bashrc
