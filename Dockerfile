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
    pacman-key --finger 6EE846D21B2D275374676D9893B0349A16DD4C4C && pacman-key --lsign-key 6EE846D21B2D275374676D9893B0349A16DD4C4C && \
    gpg --import /home/builder/BitalsPublic.key && \
    rm -rf /home/builder/BitalsPublic.key
COPY makepkg.conf /etc/makepkg.conf
RUN chown root:root /etc/makepkg.conf

RUN mkdir /home/builder/aur && chown -R builder:builder /home/builder/aur
RUN pacman -Syu --noconfirm multilib-devel git jq pacutils curl expect devtools clang lsb-release pacleaner

RUN pacman -S --noconfirm jdk17-openjdk


ARG VERSION=3206.vb_15dcf73f6a_9
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


ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}
VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

#RUN cd /home/builder/aur && git clone https://aur.archlinux.org/aurutils.git && \
#    cd aurutils && makepkg -sci --noconfirm

USER root
#RUN cd /home/builder/aur/aurutils && pacman -U --noconfirm aurutils-9.5-1-any.pkg.tar.zst

COPY jenkinsci-docker-agent/jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN pacman -Sy --noconfirm aurutils

RUN pacman -S --noconfirm sccache && mkdir /home/builder/sccache && chown builder:builder /home/builder/sccache
ENV RUSTC_WRAPPER=/usr/bin/sccache
ENV SCCACHE_DIR=/home/builder/sccache
ENV SCCACHE_CACHE_SIZE="100G"
RUN pacman -S --noconfirm ccache && mkdir /home/builder/ccache && chown builder:builder /home/builder/ccache
ENV CCACHE_SLOPPINESS=locale,time_macros
ENV CCACHE_DIR=/home/builder/ccache
ENV CCACHE_MAXSIZE="100G"
ENV PUB_CACHE=/home/builder/pub-cache

ENV CARGO_BUILD_JOBS=24

COPY packagebuilder.sh /opt/packagebuilder.sh
RUN chmod +x /opt/packagebuilder.sh
COPY custombuilder.sh /opt/custombuilder.sh
RUN chmod +x /opt/custombuilder.sh
COPY update-devel.sh /opt/update-devel.sh
RUN chmod +x /opt/update-devel.sh
COPY update-devel.sh /opt/update-devel.sh
RUN chmod +x /opt/update-devel.sh
COPY rebuilder.sh /opt/rebuilder.sh
RUN chmod +x /opt/rebuilder.sh
COPY runner.sh /opt/runner.sh
RUN chmod +x /opt/runner.sh

RUN pacman -S --noconfirm python-build python-installer python-setuptools pyenv
RUN mkdir /root/.pyenv/ && pyenv global system
RUN chown -R builder:builder /home/builder
#RUN pacman -Sc --noconfirm
USER builder
RUN mkdir /home/builder/.pyenv/ && pyenv global system

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
