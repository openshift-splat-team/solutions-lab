# docker build --no-cache --progress=plain -f .gitpod.Dockerfile .
FROM gitpod/workspace-full

# System
RUN bash -c "sudo install-packages direnv gettext gnupg golang bc"
RUN bash -c "sudo apt-get update"
RUN bash -c "sudo pip install --upgrade pip"

# AWS CLIs
RUN bash -c "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && aws --version \
    && rm awscliv2.zip \
    "

# Done :)
RUN bash -c "echo 'done.'"

