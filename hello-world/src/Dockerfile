FROM node:10.1.0-alpine
EXPOSE 3000

WORKDIR /app

COPY package.json .
RUN npm install

COPY hello.js .

USER node
CMD ["node", "hello.js"]