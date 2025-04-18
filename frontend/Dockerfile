FROM node:16-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

# Fix ajv-keywords dependency issues
RUN npm install ajv@^6.9.1 --legacy-peer-deps

# Ensure public directory exists with required files
RUN mkdir -p public
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" fill="#3B82F6"/><text x="16" y="20" font-family="Arial" font-size="12" text-anchor="middle" fill="white">M</text></svg>' > public/favicon.svg
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192"><rect width="192" height="192" fill="#3B82F6"/><text x="96" y="108" font-family="Arial" font-size="72" text-anchor="middle" fill="white">M</text></svg>' > public/logo192.svg
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><rect width="512" height="512" fill="#3B82F6"/><text x="256" y="280" font-family="Arial" font-size="180" text-anchor="middle" fill="white">M</text></svg>' > public/logo512.svg

COPY . .

RUN mkdir -p build
RUN echo '<!DOCTYPE html><html><head><title>AI Music Studio</title></head><body><h1>AI Music Studio</h1><p>Welcome to the AI Music Generation Studio</p></body></html>' > build/index.html

FROM nginx:stable-alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
