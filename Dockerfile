# Use the official Ubuntu 24.04 base image
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Arguments for user and group creation
ARG HOST_UID
ARG HOST_GID
ARG USERNAME=dockeruser

# Create or modify user and group with matching UID and GID
RUN if ! getent group ${HOST_GID} >/dev/null; then groupadd -g ${HOST_GID} ${USERNAME}; fi && \
    if ! id -u ${HOST_UID} >/dev/null 2>&1; then \
        useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash ${USERNAME}; \
    else \
        existing_user=$(getent passwd ${HOST_UID} | cut -d: -f1); \
        if [ "$existing_user" != "$USERNAME" ]; then \
            usermod -l ${USERNAME} -d /home/${USERNAME} -m $existing_user; \
            groupmod -n ${USERNAME} $(getent group ${HOST_GID} | cut -d: -f1); \
        fi; \
    fi && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME}:ubuntu" | chpasswd && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Install Visual Studio Code as root
USER root
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && apt-get install -y code \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install xeyes for testing
RUN apt-get update && apt-get install -y x11-apps

# Switch back to the regular user
USER $USERNAME

# Set the working directory
WORKDIR /home/$USERNAME

# Command to run when starting the container
CMD [ "bash" ]
