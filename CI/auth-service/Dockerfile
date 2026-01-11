FROM node:18-alpine

WORKDIR /app

# Explicit path – NO glob
COPY package.json /app/package.json

RUN npm install --omit=dev

# Explicit copy
COPY index.js /app/index.js

EXPOSE 3000
CMD ["node", "index.js"]
