FROM node:10-buster as node-build
ADD https://github.com/Tanibox/tania-core/archive/1.7.2.tar.gz ./
ADD conf.json ./
RUN tar -xvzf 1.7.2.tar.gz && mv tania-core-1.7.2 /work && cp conf.json /work/
RUN cd /work && npm install && npm install vue-template-compiler@2.6.11 --save-dev && npm install vue@2.6.11 --save-dev 
RUN cd /work && npm run dev

FROM golang:buster as go-build
WORKDIR /work/
# Install TARGETPLATFORM parser to translate its value to GOOS, GOARCH, and GOARM
COPY --from=tonistiigi/xx:golang / /
# Bring in work files
COPY --from=node-build /work /work
# Bring TARGETPLATFORM to the build scope
ARG TARGETPLATFORM
# Compile
RUN /go/bin/go get && /go/bin/go build

FROM ubuntu
WORKDIR /app/
COPY --from=go-build /work /app
RUN mkdir -p data

VOLUME /app/uploads

EXPOSE 8080
ENTRYPOINT ["./tania-core"]
