# Dockerfile — fixed for bench init (adds cron, redis, mysql libs, etc.)
FROM frappe/erpnext-worker:latest

# use root for system installs
USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages required by bench/erpnext
# - cron provides /usr/bin/crontab (fixes your error)
# - redis-server needed by bench init
# - git, build-essential, python3-venv, python3-pip for building
# - default-libmysqlclient-dev / libmariadb-dev-* for MySQL/MariaDB Python bindings
# - mariadb-client for client-side DB operations (bench new-site may use it)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron \
      redis-server \
      git \
      curl \
      build-essential \
      python3-venv \
      python3-pip \
      default-libmysqlclient-dev \
      libmariadb-dev-compat \
      libmariadb-dev \
      mariadb-client \
      locales && \
    rm -rf /var/lib/apt/lists/*

# Ensure /home/frappe exists and correct owner
RUN mkdir -p /home/frappe && chown -R frappe:frappe /home/frappe

# Remove any existing incomplete bench folder (do as root)
RUN rm -rf /home/frappe/frappe-bench || true

# switch to frappe user for bench operations
USER frappe
WORKDIR /home/frappe

# Put user-local pip bin folder into PATH so bench/honcho are found
ENV PATH="/home/frappe/.local/bin:${PATH}"

# Install bench into the user's local bin
RUN pip install --user --no-cache-dir frappe-bench

# Initialize bench; bench will create /home/frappe/frappe-bench
# NOTE: skip-assets speeds up init; change branch if you need other version
RUN bench init frappe-bench --skip-assets --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

# Get HRMS app and install site
# (You may want to replace site name and passwords with env vars in production)
RUN bench get-app --branch develop https://github.com/frappe/hrms

# Create a new site (use --no-mariadb-socket if using remote DB)
RUN bench new-site site1.local \
    --admin-password admin \
    --mariadb-root-password root \
    --no-mariadb-socket

# Install the HRMS app on the created site
RUN bench --site site1.local install-app hrms

# Expose web port
EXPOSE 8000

# Default command
CMD ["bench", "start"]
