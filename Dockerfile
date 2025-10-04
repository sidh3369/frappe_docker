FROM frappe/erpnext-worker:latest

# Set working directory
WORKDIR /home/frappe

# Copy everything from your repo into the container
COPY . .

# Install bench if not already installed
RUN pip install frappe-bench

# Remove old bench folder if it exists
RUN rm -rf /home/frappe/frappe-bench || true

# Create a fresh folder for bench
RUN mkdir -p frappe-bench

# Change into the bench folder
WORKDIR /home/frappe/frappe-bench

# Initialize bench (clean directory)
RUN bench init . --skip-assets --frappe-branch version-14

# Get the HRMS app
RUN bench get-app --branch develop https://github.com/frappe/hrms

# Create a site (example: site1.local)
RUN bench new-site site1.local --admin-password admin --mariadb-root-password root --no-mariadb-socket

# Install the HRMS app on the site
RUN bench --site site1.local install-app hrms

# Expose the port
EXPOSE 8000

# Start bench
CMD ["bench", "start"]
