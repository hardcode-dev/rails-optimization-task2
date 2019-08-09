FROM ruby:2.6.3-stretch
RUN apt-get update
RUN apt-get install -y valgrind
RUN apt-get install -y massif-visualizer
WORKDIR /home/profiling
RUN gem install oj
CMD bash
