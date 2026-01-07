FROM alpine:3.19

# Install core tools
RUN apk add --no-cache \
    git \
    openssh \
    ca-certificates \
    curl \
    bash

# Install yq (pinned version)
RUN wget -q https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64 \
    -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Default shell
ENTRYPOINT ["/bin/bash"]
