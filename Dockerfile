# Firefox over ssh X11Forwarding

FROM debian:stable

ENV GPG_KEY 0x6887935AB297B391
# ENV KEY_SERVER keys.mozilla.org
ENV KEY_SERVER x-hkp://pool.sks-keyservers.net
# ENV GPG_FINGERPRINT "3A0B 3D84 3708 9613 6B84 5E82 6887 935A B297 B391"
# https://dist.torproject.org/tormessenger/0.1.0b3/tor-messenger-linux64-0.1.0b3_en-US.tar.xz
ENV VER '0.1.0b3'
ENV PACKAGE tor-messenger-linux64-${VER}_en-US.tar.xz
ENV SOURCE https://dist.torproject.org/tormessenger/$VER/$PACKAGE
# ENV SOURCE https://dist.torproject.org/tormessenger/$VER/$PACKAGE
ENV CHKSUM sha256sums.txt
ENV SOURCE_CHKSUM https://dist.torproject.org/tormessenger/$VER/$CHKSUM
ENV SOURCE_CHKSUM_ASC https://dist.torproject.org/tormessenger/$VER/$CHKSUM.asc

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# make sure the package repository is up to date
# and blindly upgrade all packages
RUN apt-get update
RUN apt-get upgrade -y -qq

# install ssh and iceweasel RUN apt-get install -y -qq openssh-server

# various utils that aid in getting firefox installed
RUN apt-get install -y -qq curl wget xz-utils bzip2 unzip

# install pulseaudio to forward sound server to local session using paprefs
# RUN apt-get install -y -qq pulseaudio

# Create user "docker" and set the password to "docker"
RUN useradd -m -d /home/docker docker
RUN echo "docker:docker" | chpasswd

# Prepare ssh config folder
RUN mkdir -p /home/docker/.ssh
RUN chown -R docker:docker /home/docker
RUN chown -R docker:docker /home/docker/.ssh

# grab the latest firefox, flash and privacytools.io encouraged plugins
WORKDIR /home/docker
RUN wget $SOURCE
RUN wget $SOURCE_CHKSUM
RUN wget $SOURCE_CHKSUM_ASC

# install addons globally
WORKDIR /home/docker

# RUN gpg --keyserver x-hkp://pool.sks-keyservers.net --recv-keys $GPG_KEY
RUN gpg --keyserver $KEY_SERVER --recv-keys $GPG_KEY
# RUN gpg --fingerprint $GPG_KEY | grep "3A0B 3D84 3708 9613 6B84 5E82 6887 935A B297 B391"
RUN gpg --verify $CHKSUM.asc
RUN sha256sum -c $CHKSUM 2>/dev/null | grep $PACKAGE
RUN tar xvf $PACKAGE

# Create OpenSSH privilege separation directory, enable X11Forwarding
RUN mkdir -p /var/run/sshd
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config

# Expose the SSH port
EXPOSE 22

# Start SSH
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]


