ARG DOCKER_IMAGE_BASE

FROM ${DOCKER_IMAGE_BASE}

ADD /scripts/install_original_z3.sh ${HOME}/install_original_z3.sh
RUN $HOME/install_original_z3.sh
