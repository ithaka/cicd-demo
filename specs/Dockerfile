from ubuntu:16.04

RUN apt-get update
RUN apt-get install -y ruby git vim curl sudo
#RUN apt-get install -y ruby git vim curl sudo
#RUN gem install bundler

RUN useradd -ms /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

RUN chmod u+w /etc/sudoers
RUN echo "%sudo  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chmod u-w /etc/sudoers


COPY . /home/ubuntu/specs

RUN chown -R ubuntu:ubuntu /home/ubuntu/specs
RUN chmod 775 /home/ubuntu/specs

USER ubuntu
WORKDIR /home/ubuntu

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby

WORKDIR /home/ubuntu/specs
RUN bash --login -c "gem install bundler && bundle install"

USER root
WORKDIR /
