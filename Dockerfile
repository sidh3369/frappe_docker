# Base image (Frappe official worker image)
FROM frappe/erpnext-worker:latest

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    redis-server git python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

USER frappe
WORKDIR /home/frappe

# Add bench binaries to PATH
ENV PATH="/home/frappe/.local/bin:${PATH}"

# Install bench globally for frappe user
RUN pip install --user frappe-bench

# Remove any old bench instance to avoid conflicts
RUN rm -rf /home/frappe/frappe-bench

# Initialize bench
RUN bench init frappe-bench --skip-assets --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

# Get HRMS app
RUN bench get-app --branch develop https://github.com/frappe/hrms

# Create a site (change passwords as needed)
RUN bench new-site site1.local \
    --admin-password admin \
    --mariadb-root-password root \
    --no-mariadb-socket

# Install HRMS app
RUN bench --site site1.local install-app hrms

# Expose Frappe port
EXPOSE 8000

# Default command to run bench
CMD ["bench", "start"]
