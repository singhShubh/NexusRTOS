FROM ubuntu:22.04

# Non-interactive APT to prevent hanging in Docker builds
ENV DEBIAN_FRONTEND=noninteractive

# Core dev tools for Cortex-M33 + QEMU RTOS development (no hardware flashing)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo ca-certificates curl wget gnupg \
        git cmake ninja-build make ccache tree file \
        python3 python3-pip python3-venv python3-setuptools python3-wheel python3-dev \
        gcc-arm-none-eabi libnewlib-arm-none-eabi binutils \
        gdb-multiarch \
        qemu-system-arm \
        device-tree-compiler \
        clang-format \
        less vim nano \
    && rm -rf /var/lib/apt/lists/*

# Helpful Python utilities (no hardware dependencies)
RUN pip3 install --no-cache-dir pyserial black

# Create a non-root user with passwordless sudo
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd -m -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Ensure VS Code / Codespaces get a proper login shell
SHELL ["/bin/bash", "-l", "-c"]
CMD ["bash", "-l"]

# Nice terminal defaults
ENV TERM=xterm-256color