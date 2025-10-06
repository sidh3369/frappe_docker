# ------------------------------------------------------------
# ✅ Frappe + ERPNext + HRMS Dockerfile (with Node.js 20 fix)
# ------------------------------------------------------------

FROM python:3.10-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata

# ------------------------------------------------------------
# 1️⃣ Install base dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    git curl wget vim gnupg2 ca-certificates \
    build-essential mariadb-client redis-server \
    python3-dev python3-pip python3-setuptools python3-venv \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 2️⃣ Install Node.js 20 + Yarn (important for HRMS)
# ------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    node -v && yarn -v

# ------------------------------------------------------------
# 3️⃣ Install Bench (Frappe CLI)
# ------------------------------------------------------------
RUN pip install --upgrade pip && pip install frappe-bench

# ------------------------------------------------------------
# 4️⃣ Initialize new bench
# ------------------------------------------------------------
WORKDIR /home/frappe
RUN bench init frappe-bench --frappe-branch version-16 --python python3

# ------------------------------------------------------------
# 5️⃣ Set working directory
# ------------------------------------------------------------
WORKDIR /home/frappe/frappe-bench

# ------------------------------------------------------------
# 6️⃣ Get ERPNext app
# ------------------------------------------------------------
RUN bench get-app --branch version-16 https://github.com/frappe/erpnext

# ------------------------------------------------------------
# 7️⃣ Get HRMS app (develop branch)
# ------------------------------------------------------------
RUN bench get-app --branch develop https://github.com/frappe/hrms

# ------------------------------------------------------------
# 8️⃣ Create site (replace password as needed)
# ------------------------------------------------------------
RUN bench new-site site1.local --admin-password admin --db-root-password root

# ------------------------------------------------------------
# 9️⃣ Install apps on site
# ------------------------------------------------------------
RUN bench --site site1.local install-app erpnext hrms

# ------------------------------------------------------------
# 🔟 Expose ports and set entrypoint
# ------------------------------------------------------------
EXPOSE 8000
CMD ["bench", "start"]
