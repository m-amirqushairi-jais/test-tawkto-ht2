# api-service container image.
#
# NOTE TO CANDIDATE: this Dockerfile builds and runs the service, but it has a
# number of problems ranging from "it won't build" to "it works but you would
# never ship this". Fix what you can; note what you can't.

# task 1: fix 1 - fix image name `slimm` -> `slim`
FROM node:18-slim

# task 1: fix 2 - remove due to no purpose in this image

WORKDIR /app

# task 1: fix 4 - instead of copying entire project, copy only necessary files to reduce image size and build time; this also helps to avoid including sensitive files or unnecessary dependencies in the image.
# layer caching: by copying package.json and package-lock.json first, we can take advantage of Docker's layer caching; if these files haven't changed, the npm install layer will be cached, speeding up subsequent builds.
COPY package*.json ./

# install only production dependencies; this reduces the image size and attack surface by excluding development tools and libraries that are not needed at runtime.
RUN npm install --omit=dev 

COPY server.js ./

# task 1: fix 3 - remove hardcoded MongoDB credentials from the image; these should be provided at runtime via environment variables or a secrets manager.

EXPOSE 3000

CMD ["npm", "start"]
