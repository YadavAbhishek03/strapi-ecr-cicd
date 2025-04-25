# Use Node.js official image
FROM node:20-alpine

# Install dependencies & yarn
RUN apk add --no-cache \
  build-base \
  python3 \
  make \
  g++ \
  sqlite \
  sqlite-dev \
  git 

# Set working directory
WORKDIR /app

# Copy over package.json and yarn.lock
COPY strapi/package.json strapi/yarn.lock ./

# Copy .env
COPY strapi/.env .env

# Install node modules with Yarn
RUN yarn install

# Copy the rest of the Strapi app
COPY strapi/ .

# Build admin panel
RUN yarn build

# Rebuild native modules for Alpine
RUN node -e "require('child_process').execSync('npm rebuild better-sqlite3', { stdio: 'inherit' })"

# Create .tmp for SQLite
RUN mkdir -p .tmp

# Set correct permissions
RUN chown -R node:node /app
USER node

# Expose Strapi port
EXPOSE 1337

# Start Strapi
CMD ["yarn", "start"]
