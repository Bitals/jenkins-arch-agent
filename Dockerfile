FROM archlinux:base-devel

USER root

RUN groupadd -g 1000 builder
RUN groupadd -g 1005 flutterusers
RUN useradd -c "Building user" -d /home/builder -u 1000 -g 1000 -m builder
RUN usermod -aG wheel builder && usermod -aG flutterusers builder
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY bash.bashrc /etc/bash.bashrc
RUN chown root:root /etc/bash.bashrc
COPY pacman.conf /etc/pacman.conf
RUN chown root:root /etc/pacman.conf
COPY BitalsPublic.key /home/builder/BitalsPublic.key
RUN pacman-key --init && pacman-key --populate archlinux && pacman-key -a /home/builder/BitalsPublic.key && \
    pacman-key --finger B85CCC7E84084D98FDCA5CB9619D32E653C5E767 && pacman-key --lsign-key B85CCC7E84084D98FDCA5CB9619D32E653C5E767 && \
    gpg --import /home/builder/BitalsPublic.key && \
    rm -rf /home/builder/BitalsPublic.key
COPY makepkg.conf /etc/makepkg.conf
RUN chown root:root /etc/makepkg.conf

RUN mkdir /home/builder/aur && chown builder:builder /home/builder/aur
RUN pacman -Syu --noconfirm git jq pacutils curl expect devtools clang lsb-release

RUN pacman -S --noconfirm jdk17-openjdk


ARG VERSION=4.12
ARG user=builder
ARG group=builder
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent
RUN pacman -S --noconfirm git-lfs fontconfig \
  && curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar


USER builder
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}
VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

#RUN cd /home/builder/aur && git clone https://aur.archlinux.org/aurutils.git && \
#    cd aurutils && makepkg -sci --noconfirm

USER root
#RUN cd /home/builder/aur/aurutils && pacman -U --noconfirm aurutils-9.5-1-any.pkg.tar.zst

COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN pacman -Sy --noconfirm aurutils

COPY packagebuilder.sh /opt/packagebuilder.sh
RUN chmod +x /opt/packagebuilder.sh
COPY custombuilder.sh /opt/custombuilder.sh
RUN chmod +x /opt/custombuilder.sh
COPY update-devel.sh /opt/update-devel.sh
RUN chmod +x /opt/update-devel.sh
COPY aur-update-devel-fork.sh /opt/aur-update-devel-fork.sh
RUN chmod +x /opt/aur-update-devel-fork.sh
COPY rebuilder.sh /opt/rebuilder.sh
RUN chmod +x /opt/rebuilder.sh
COPY vpn.sh /opt/vpn.sh
RUN chmod +x /opt/vpn.sh

RUN pacman -S --noconfirm sccache && mkdir /home/builder/sccache && chown builder:builder /home/builder/sccache
ENV RUSTC_WRAPPER=/usr/bin/sccache
ENV SCCACHE_DIR=/home/builder/sccache
ENV SCCACHE_CACHE_SIZE="100G"
RUN pacman -S --noconfirm ccache && mkdir /home/builder/ccache && chown builder:builder /home/builder/ccache
ENV CCACHE_SLOPPINESS=locale,time_macros
ENV CCACHE_DIR=/home/builder/ccache
ENV CCACHE_MAXSIZE="100G"

COPY manual-connections /opt/manual-connections

COPY aurutils-plugins/lib/* /usr/local/bin/

#RUN pacman -Sc --noconfirm
USER builder

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]