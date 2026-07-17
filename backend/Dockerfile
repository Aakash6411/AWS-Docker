# Use a lightweight LTS Node image
FROM node:18-alpine
WORKDIR /usr/src/app

# Copy ONLY package.json (package-lock.json ko ignore karein)
COPY package.json ./

# RUN npm install (Yeh automatically internet se packages download karega)
RUN npm install

# Copy rest of the source code
COPY . .

# Expose API port
EXPOSE 5000

# Non-root user safety precaution
USER node

CMD ["node", "server.js"]