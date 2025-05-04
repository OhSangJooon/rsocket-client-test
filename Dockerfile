FROM node:18
WORKDIR /app
COPY . .
RUN mkdir -p /app/logs
RUN npm install
RUN npm install ws
CMD node test.js && tail -f /dev/null