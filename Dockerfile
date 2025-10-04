FROM frappe/erpnext-worker:latest

WORKDIR /home/frappe

COPY . .

RUN pip install --user frappe-bench

ENV PATH="/home/frappe/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y redis-server

RUN bench init frappe-bench --skip-assets --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

RUN bench get-app --branch develop https://github.com/frappe/hrms

RUN bench new-site site1.local --admin-password admin --mariadb-root-password root --no-mariadb-socket

RUN bench --site site1.local install-app hrms

EXPOSE 8000

CMD ["bench", "start"]
