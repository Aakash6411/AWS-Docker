# Stage 1: Seedhe Nginx use karein bina React build ke
FROM nginx:1.25-alpine

# Ek simple html file container ke andar hi create kar dete hain
# Base image for production server
FROM nginx:1.25-alpine

# Single proper command to create index.html with Author name
RUN echo "<h1>Welcome to my E-commerce Frontend! Container is running successfully.</h1><p>Author: Aakash Kumar Singh</p>" > /usr/share/nginx/html/index.html

# Expose HTTP Port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]