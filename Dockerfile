# Fixed Dockerfile for Frappe v14 + HRMS
FROM frappe/erpnext-worker:latest

# 1) Do system installs as root (so apt can run)
USER root
RUN apt-get update && \
    apt-get install -y redis-server git python3-venv python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Ensure /home/frappe exists and has correct ownership
RUN mkdir -p /home/frappe && chown -R frappe:frappe /home/frappe

# 2) Remove any old bench folder AS ROOT to avoid permission-denied
RUN rm -rf /home/frappe/frappe-bench || true

# 3) Switch to frappe user for bench operations
USER frappe
WORKDIR /home/frappe

# add local pip scripts location to PATH (fixes bench/honcho warnings)
ENV PATH="/home/frappe/.local/bin:${PATH}"

# 4) Copy project files into container AFTER cleanup (avoid copying bench artifacts)
COPY . .

# 5) Install bench for frappe user (goes to /home/frappe/.local)
RUN pip install --user frappe-bench

# 6) Initialize bench (creates /home/frappe/frappe-bench)
RUN bench init frappe-bench --skip-assets --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

# 7) Install HRMS app
RUN bench get-app --branch develop https://github.com/frappe/hrms

# 8) Create a site (example: site1.local) — replace passwords with env vars for production
RUN bench new-site site1.local \
    --admin-password admin \
    --mariadb-root-password root \
    --no-mariadb-socket

# 9) Install HRMS on the site
RUN bench --site site1.local install-app hrms

EXPOSE 8000

# 10) Start bench when container runs
CMD ["bench", "start"]
