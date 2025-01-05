# Step 1: Use Node.js image to build the app
FROM node:18-alpine AS build

# Step 2: Set the working directory
WORKDIR /app

# Step 3: Copy package.json and package-lock.json (or yarn.lock) for dependencies
COPY package*.json ./

# Step 4: Install frontend dependencies
RUN npm install

# Step 5: Copy the rest of the frontend code
COPY . .

# Step 6: Build the React app for production (Vite places the build in 'dist')
RUN npm run build

# Step 7: Use Nginx to serve the static files
FROM nginx:alpine

# Step 8: Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Step 9: Copy the build output from the previous stage to the Nginx directory
COPY --from=build /app/dist /usr/share/nginx/html

# Step 10: Expose port 80 for the web server
EXPOSE 80

# Step 11: Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]
