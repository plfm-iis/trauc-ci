ARG DOCKER_IMAGE_BASE

FROM ${DOCKER_IMAGE_BASE}

USER user
WORKDIR /home/user

ADD /scripts/install_trau_pre.sh ${HOME}/install_trau.sh
ADD /scripts/z3-4.4.1.0.patches ${HOME}/z3-4.4.1.0.patches
RUN $HOME/install_trau.sh

ENV LD_LIBRARY_PATH="/usr/local/lib"
