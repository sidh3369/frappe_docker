FROM frappe/erpnext-worker:latest

# Set work directory
WORKDIR /home/frappe/frappe-bench

# Copy everything from your repo into the container
COPY . .

# Install bench if not already installed
RUN pip install frappe-bench

# Initialize bench (if not already present)
RUN bench init frappe-bench --skip-assets --frappe-branch version-14

# Get the HRMS app
RUN bench get-app --branch develop https://github.com/frappe/hrms

# Create a site (example: site1.local)
RUN bench new-site site1.local --admin-password admin --mariadb-root-password root --no-mariadb-socket

# Install the app on the site
RUN bench --site site1.local install-app hrms

# Expose the port
EXPOSE 8000

# Start bench
CMD ["bench", "start"]
