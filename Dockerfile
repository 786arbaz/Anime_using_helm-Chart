# Use an official Nginx runtime as a base image
FROM nginx:latest

# Set the working directory inside the container
WORKDIR /usr/share/nginx/html

# Copy the HTML, CSS, and video files into the container
COPY . .

# Expose port 80 to the outside world
EXPOSE 80

# Command to run the application when the container starts
CMD ["nginx", "-g", "daemon off;"]
