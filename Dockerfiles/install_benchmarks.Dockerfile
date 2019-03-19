ARG DOCKER_IMAGE_BASE

FROM ${DOCKER_IMAGE_BASE}

USER user
WORKDIR /home/user

ADD /scripts/install_benchmarks.sh $HOME/install_benchmarks.sh
RUN $HOME/install_benchmarks.sh

ADD /scripts/ci-run.sh "${BENCHMARK_PATH}/install_benchmarks.sh"
