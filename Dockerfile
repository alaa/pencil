# Pencil

FROM phusion/passenger-ruby21

USER root
WORKDIR /root

RUN git clone https://github.com/alaa/pencil.git

WORKDIR /root/pencil
RUN bundle

ENTRYPOINT ["./bin/agent"]
