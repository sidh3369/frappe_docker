# ------------------------------------------------------------
# ✅ Frappe + ERPNext + HRMS for Render Deployment
# ------------------------------------------------------------

FROM python:3.10-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata

# ------------------------------------------------------------
# 1️⃣ Install required system dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    git curl wget gnupg2 ca-certificates \
    build-essential mariadb-client redis-server \
    python3-dev python3-setuptools python3-venv \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 2️⃣ Install Node.js 20 (fix HRMS nanoid error) + Yarn
# ------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    node -v && yarn -v

# ------------------------------------------------------------
# 3️⃣ Install Bench CLI
# ------------------------------------------------------------
RUN pip install --upgrade pip && pip install frappe-bench

# ------------------------------------------------------------
# 4️⃣ Initialize Frappe Bench
# ------------------------------------------------------------
WORKDIR /home/frappe
RUN bench init frappe-bench --frappe-branch version-16 --python python3

# ------------------------------------------------------------
# 5️⃣ Switch to bench directory
# ------------------------------------------------------------
WORKDIR /home/frappe/frappe-bench

# ------------------------------------------------------------
# 6️⃣ Get ERPNext + HRMS apps
# ------------------------------------------------------------
RUN bench get-app --branch version-16 https://github.com/frappe/erpnext
RUN bench get-app --branch develop https://github.com/frappe/hrms

# ------------------------------------------------------------
# 7️⃣ Create new site (Render will handle DB via env vars)
# ------------------------------------------------------------
# Replace admin/root passwords as needed
RUN bench new-site site1.local --admin-password admin --db-root-password root --no-mariadb-socket

# ------------------------------------------------------------
# 8️⃣ Install apps
# ------------------------------------------------------------
RUN bench --site site1.local install-app erpnext hrms

# ------------------------------------------------------------
# 9️⃣ Expose port 8000 for Render
# ------------------------------------------------------------
EXPOSE 8000

# ------------------------------------------------------------
# 🔟 Start Frappe on Render
# ------------------------------------------------------------
CMD ["bench", "start"]
