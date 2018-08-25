FROM alpine:3.7

LABEL maintainer "Ramón G. Camus <rgcamus@gmail.com>"

RUN apk update && apk upgrade \
    && apk add tzdata curl wget bash \
    && apk add ruby ruby-bundler nodejs

# Needed to make native extensions
RUN apk add ruby-dev g++ musl-dev make \
    && echo "gem: --no-document" > /etc/gemrc \
    && gem install bundler smashing json

# Create dashboard and link volumes
RUN smashing new smashing

RUN rm /smashing/jobs -rf

WORKDIR /smashing

RUN cd /smashing 
RUN bundle 
    
COPY run.sh /smashing/
COPY dashboards /smashing/dashboards 
COPY jobs /smashing/jobs 
COPY lib-smashing /smashing/lib-smashing 
COPY config /smashing/config 
COPY public /smashing/public 
COPY widgets /smashing/widgets 
COPY jobs /smashing/jobs 

ENV AWS_PROXY_HOST aws_proxy.server.consul
ENV AWS_PROXY_PORT 8081

ENV PORT 3030
EXPOSE ${PORT}
WORKDIR /smashing

VOLUME ["/etc/consul/"]
VOLUME ["/etc/goss/"]

COPY artifacts/startup-script /var/startup-script
COPY artifacts/smashing-consul.json /var/smashing-consul.json
COPY artifacts/smashing-goss.yaml /var/smashing-goss.yaml

RUN cp /var/startup-script /usr/local/bin/startup-script
RUN chmod 774 /usr/local/bin/startup-script

ENTRYPOINT ["/usr/local/bin/startup-script"]
