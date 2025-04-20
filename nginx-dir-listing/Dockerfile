# Use an official Nginx runtime as a parent image
FROM nginx:alpine

# Remove the default nginx index page
RUN rm -f /usr/share/nginx/html/*.html

# Remove the default Nginx configuration
RUN rm -f /etc/nginx/conf.d/*.conf

# Copy your custom configuration file
COPY port-80-dir-listing.conf /etc/nginx/conf.d/default.conf
# Or if you prefer sites-enabled:
# COPY port-80-dir-listing.conf /etc/nginx/sites-available/my-site.conf
# RUN ln -s /etc/nginx/sites-available/my-site.conf /etc/nginx/sites-enabled/default

# (Optional) Copy any files you *do* want to be listed into the web root
# COPY ./my-files/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Command to run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
