FROM frappe/erpnext-worker:latest

WORKDIR /home/frappe

COPY . .

RUN pip install --user frappe-bench

# Add bench to PATH
ENV PATH="/home/frappe/.local/bin:${PATH}"

# Initialize bench (this creates frappe-bench)
RUN bench init frappe-bench --skip-assets --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

# Get the HRMS app
RUN bench get-app --branch develop https://github.com/frappe/hrms

# Create a site
RUN bench new-site site1.local \
    --admin-password admin \
    --mariadb-root-password root \
    --no-mariadb-socket

# Install the app
RUN bench --site site1.local install-app hrms

EXPOSE 8000

CMD ["bench", "start"]
