FROM ruby:2.3

MAINTAINER NigelThorne "https://github.com/NigelThorne"


# # Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential wget git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get install -y --force-yes libgmp3-dev
RUN apt-get clean

# RUN wget -P /root/src http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz

#RUN cd /root/src; tar xvf ruby-2.2.2.tar.gz
#RUN cd /root/src/ruby-2.2.2; ./configure; make install

RUN gem update --system
RUN gem install bundler
RUN gem install foreman

# Copy the Gemfile and Gemfile.lock into the image. 
# Temporarily set the working directory to where they are. 
WORKDIR /tmp 
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install 


RUN mkdir -p /usr/src/app
ADD startup.sh /
ADD . /usr/src/app
ENV RACK_ENV production
ENV MAIN_APP_FILE app.rb

RUN cd /usr/src/app; bundle install

WORKDIR /usr/src/app

EXPOSE 8888
CMD ["foreman","start","-d","/usr/src/app"]


#EXPOSE 80
#CMD ["/bin/bash", "/startup.sh"]