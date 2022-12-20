docker-compose run --rm -p 8888:3001 -p 8069:8069 odoo /usr/bin/python3 -m debugpy --listen 0.0.0.0:3001 /usr/bin/odoo --db_user=odoo --db_host=db --db_password=odoo "$@"
