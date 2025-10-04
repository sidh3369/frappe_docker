# Base image from the official frappe docker registry
FROM frappe/erpnext-worker:latest

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Copy your bench or app files
COPY . .

# Get the HRMS app (optional)
RUN bench get-app --branch develop https://github.com/frappe/hrms

# Start the frappe server
CMD ["bench", "start"]
