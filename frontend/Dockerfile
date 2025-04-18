# frontend/Dockerfile

############################
# 1) Build‑stage: React build
############################
FROM node:16-alpine AS build
WORKDIR /app

# 1.1 Alleen package.json/lock cachen
COPY package*.json ./

# 1.2 Installeer alle deps
RUN npm install --legacy-peer-deps

# 1.3 Pin ajv en ajv‑keywords voor compatibiliteit met react-scripts
RUN npm install ajv@6.12.6 ajv-keywords@3.5.2 --legacy-peer-deps

# 1.4 Copy de rest van je source en maak de productie‑build
COPY . .
RUN npm run build

############################
# 2) Serve‑stage: Nginx
############################
FROM nginx:stable-alpine

# 2.1 Kopieer de gegenereerde build
COPY --from=build /app/build /usr/share/nginx/html

# 2.2 Jouw eigen nginx config (SPA fallback en /api proxy)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

