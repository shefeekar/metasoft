# Use an official Node.js runtime as the base image
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the app port (dotenv app doesn’t specify one by default,
# but most Node apps listen on 3000 or 5000 — adjust if needed)
EXPOSE 3000

# Default command to run the app
CMD ["node", "index.js"]

