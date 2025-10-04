FROM frappe/erpnext-worker:latest

USER root

# Install Redis and dependencies
RUN apt-get update && \
    apt-get install -y redis-server git python3-venv python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Switch back to frappe user
USER frappe

WORKDIR /home/frappe

# Copy project files into container
COPY . .

# Add bench and other scripts to PATH
ENV PATH="/home/frappe/.local/bin:${PATH}"

# Install bench
RUN pip install --user frappe-bench

# Initialize bench
RUN bench init frappe-bench --skip-assets --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

# Get HRMS app
RUN bench get-app --branch develop https://github.com/frappe/hrms

# Create site
RUN bench new-site site1.local --admin-password admin --mariadb-root-password root --no-mariadb-socket

# Install app
RUN bench --site site1.local install-app hrms

EXPOSE 8000

CMD ["bench", "start"]
