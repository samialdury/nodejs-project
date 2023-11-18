ARG NODE_VERSION=20
ARG TINI_VERSION="v0.19.0"
ARG WORK_DIR="/app"

ARG COMMIT_SHA="unknown"
ARG LOG_LEVEL="info"
ARG PROJECT_NAME="nodejs-project"
ARG ENV="prod"

################################################################
#                                                              #
#                     Prepare alpine image                     #
#                                                              #
################################################################

FROM node:${NODE_VERSION}-alpine as node-alpine

ARG TINI_VERSION

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini

RUN chmod +x /tini
RUN apk --no-cache add curl
RUN curl -sf https://gobinaries.com/tj/node-prune | sh

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

################################################################
#                                                              #
#                   Prepare distroless image                   #
#                                                              #
################################################################

FROM gcr.io/distroless/nodejs${NODE_VERSION}-debian11:nonroot as node-distroless

################################################################
#                                                              #
#        Install all dependencies and build TypeScript         #
#                                                              #
################################################################

FROM node-alpine as build-js

ARG WORK_DIR

WORKDIR ${WORK_DIR}

# pnpm fetch does require only lockfile
COPY pnpm-lock.yaml pnpm-lock.yaml

# If you patched any package, include patches before running pnpm fetch
RUN pnpm fetch

COPY package.json package.json
COPY tsconfig.base.json tsconfig.base.json
COPY tsconfig.prod.json tsconfig.prod.json
COPY src src

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --offline --frozen-lockfile
RUN ./node_modules/.bin/tsc --project ./tsconfig.prod.json

################################################################
#                                                              #
#  Install only production dependencies & prune unused files   #
#                                                              #
################################################################

FROM node-alpine as install-prod-deps

ARG WORK_DIR

WORKDIR ${WORK_DIR}

ENV NODE_ENV="production"

# pnpm fetch does require only lockfile
COPY --from=build-js ${WORK_DIR}/pnpm-lock.yaml pnpm-lock.yaml

# If you patched any package, include patches before running pnpm fetch
RUN pnpm fetch --prod

COPY --from=build-js ${WORK_DIR}/package.json package.json

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --offline --frozen-lockfile --prod
RUN node-prune

################################################################
#                                                              #
#             Copy only necessary data for runtime             #
#                                                              #
################################################################

FROM node-distroless as final

ARG WORK_DIR
ARG COMMIT_SHA
ARG LOG_LEVEL
ARG PROJECT_NAME
ARG ENV

WORKDIR ${WORK_DIR}

ENV NODE_OPTIONS="--enable-source-maps"
ENV NODE_ENV="production"
ENV COMMIT_SHA=${COMMIT_SHA}
ENV LOG_LEVEL=${LOG_LEVEL}
ENV PROJECT_NAME=${PROJECT_NAME}
ENV ENV=${ENV}

COPY --from=node-alpine --chown=nonroot:nonroot /tini /tini

COPY --from=build-js --chown=nonroot:nonroot ${WORK_DIR}/package.json package.json
COPY --from=build-js --chown=nonroot:nonroot ${WORK_DIR}/build build

COPY --from=install-prod-deps --chown=nonroot:nonroot ${WORK_DIR}/node_modules node_modules

USER nonroot:nonroot

ENTRYPOINT ["/tini", "--"]

CMD ["/nodejs/bin/node", "./build/src/main.js"]
