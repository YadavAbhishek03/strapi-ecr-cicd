# Base image
FROM strapi/strapi

# Set build-time variables
ARG STRAPI_APP_KEYS
ARG STRAPI_API_TOKEN_SALT
ARG STRAPI_JWT_SECRET

# Set environment variables for Strapi
ENV STRAPI_APP_KEYS=$STRAPI_APP_KEYS
ENV STRAPI_API_TOKEN_SALT=$STRAPI_API_TOKEN_SALT
ENV STRAPI_JWT_SECRET=$STRAPI_JWT_SECRET

# Install necessary dependencies and copy your app files
WORKDIR /srv/app
COPY . .

# Install dependencies
RUN npm install

# Expose port
EXPOSE 1337

# Start Strapi app
CMD ["npm", "run", "develop"]
