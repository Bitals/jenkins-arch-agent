FROM archlinux:base-devel

USER root

RUN groupadd -g 1000 builder
RUN groupadd -g 1005 flutterusers
RUN useradd -c "Building user" -d /home/builder -u 1000 -g 1000 -m builder
RUN usermod -aG wheel builder && usermod -aG flutterusers builder
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#RUN sed '/#MAKEFLAGS/s/.*/MAKEFLAGS="-j24"/' /etc/makepkg.conf > /home/builder/makepkg && mv /home/builder/makepkg /etc/makepkg.conf
#RUN echo 'MAKEFLAGS="-j24"' >> /etc/makepkg.conf && grep MAKEFLAGS /etc/makepkg.conf
#RUN sed '/NoProgressBar/s/.*/#NoProgressBar/' /etc/pacman.conf > /home/builder/pacman && mv /home/builder/pacman /etc/pacman.conf

COPY pacman.conf /etc/pacman.conf
RUN chown root:root /etc/pacman.conf
COPY BitalsPublic.key /home/builder/BitalsPublic.key
RUN pacman-key --init && pacman-key --populate archlinux && pacman-key -a /home/builder/BitalsPublic.key && \
    pacman-key --finger 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C && pacman-key --lsign-key 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C && \
    rm -rf /home/builder/BitalsPublic.key
COPY makepkg.conf /etc/makepkg.conf
RUN chown root:root /etc/makepkg.conf

RUN mkdir /home/builder/aur && chown builder:builder /home/builder/aur
RUN pacman -Syu git jq pacutils curl expect devtools --noconfirm

RUN pacman -S --noconfirm jdk17-openjdk


ARG VERSION=4.12
ARG user=builder
ARG group=builder
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent
RUN pacman -S --noconfirm git-lfs curl fontconfig \
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

# RUN echo "[Bitals]" >> /etc/pacman.conf
# RUN echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf
# RUN echo "Server = https://arch.bitals.xyz" >> /etc/pacman.conf
RUN pacman -Sy --noconfirm aurutils

COPY packagebuilder.sh /opt/packagebuilder.sh
RUN chmod +x /opt/packagebuilder.sh
COPY custombuilder.sh /opt/custombuilder.sh
RUN chmod +x /opt/custombuilder.sh
COPY vpn.sh /opt/vpn.sh
RUN chmod +x /opt/vpn.sh

RUN mkdir /tmpbuilddir && chown builder:builder /tmpbuilddir

COPY manual-connections /home/builder/manual-connections

#RUN pacman -Sc --noconfirm
USER builder

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]