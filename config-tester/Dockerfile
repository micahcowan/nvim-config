# ubuntu:noble as of writing
FROM ubuntu

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    git unzip wget curl npm python3 python3-venv
# The packages listed above must be installed for Mason installs to work
# npm needed for most lsps.
# python3 and python3-venv needed for brightpyright

# Can't ADD nvim stuff under /usr! Doesn't find its parser library files.
# It must check whether it was under /usr, and adjust its paths accordingly.
ADD nvim-linux-x86_64.tar.gz /root/opt/
ADD bashrc /root/.bashrc
ADD config/ /root/.config/nvim/

WORKDIR "/root"
