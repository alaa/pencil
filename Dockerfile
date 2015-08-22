# Pencil

FROM phusion/passenger-ruby21

ADD . .
RUN bundle

ENTRYPOINT ["./bin/agent"]
