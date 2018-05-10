from ubuntu:16.04

RUN apt-get update --fix-missing
RUN apt-get install -y nodejs npm

RUN mkdir /app
COPY package.json /app/
COPY hello.js /app/
WORKDIR /app
RUN npm install

EXPOSE 3000

CMD ["/usr/bin/nodejs", "hello.js"]
