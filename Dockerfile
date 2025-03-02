FROM node:20-alpine
ENV PORT=3000
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package.json ./
COPY package-lock.json ./
COPY index.js ./
RUN npm install
EXPOSE $PORT
CMD [ "npm", "run", "start" ]