ARG DOCKER_IMAGE_BASE

FROM ${DOCKER_IMAGE_BASE}

ADD /scripts/install_trau.sh ${HOME}/install_trau.sh
ADD /scripts/z3-4.4.1.0.patches ${HOME}/z3-4.4.1.0.patches
RUN $HOME/install_trau.sh
