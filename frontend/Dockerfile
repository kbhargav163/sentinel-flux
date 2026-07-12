# Stage 1: Build the React application
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve the production assets using Nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 3001
# Update Nginx port matching our Helm spec
RUN sed -i 's/listen\.80;/listen 3001;/g' /etc/nginx/conf.d/default.conf || true
CMD ["nginx", "-g", "daemon off;"]