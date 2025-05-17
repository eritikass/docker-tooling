# Use an official Nginx runtime as a parent image
FROM openresty/openresty:alpine

# install node-js 
RUN apk add --no-cache nodejs bash curl \
    && node --version

# Remove the default nginx index page
RUN mkdir -p /usr/share/nginx/html \
    && rm -f /usr/share/nginx/html/*.html

# Remove the default Nginx configuration
RUN rm -f /etc/nginx/conf.d/*.conf

# Copy your custom configuration file
COPY port-80-dir-listing.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /node-js

COPY ./node-js/* /node-js/

# Or if you prefer sites-enabled:
# COPY port-80-dir-listing.conf /etc/nginx/sites-available/my-site.conf
# RUN ln -s /etc/nginx/sites-available/my-site.conf /etc/nginx/sites-enabled/default

# (Optional) Copy any files you *do* want to be listed into the web root
# COPY ./my-files/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Command to run nginx in the foreground
CMD ["openresty", "-g", "daemon off;"]
