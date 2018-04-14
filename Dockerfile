FROM ubuntu:14.04.5

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
    
COPY dashboards /smashing/dashboards 
COPY jobs /smashing/jobs 
COPY lib-smashing /smashing/lib-smashing 
COPY config /smashing/config 
COPY public /smashing/public 
COPY widgets /smashing/widgets 
COPY jobs /smashing/jobs 

COPY run.sh /

ENV PORT 3030
EXPOSE ${PORT}
WORKDIR /smashing

CMD ["/run.sh"]
