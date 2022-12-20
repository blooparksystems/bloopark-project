#!/bin/bash
# Setup configuration for .env
if [ $1 = "-i" ]
then
    echo "Project Code: Default -> PROJECT_CODE"
    read PROJECT_CODE
    echo "Odoo Port: Default -> 8069"
    read ODOO_PORT
else
    PROJECT_CODE=$1
    ODOO_PORT=${2:-8069}
fi
# DEV and ADDONS are optional configs. These configs are used
# in ./dev.sh to bootsrap a new branch and a db.
DEV="16.0"
ADDONS="web"

# Create .env file
cat << EOF > .env
PROJECT_CODE=${PROJECT_CODE:-PROJECT_CODE}
ODOO_PORT=${ODOO_PORT:-8069}
DEV_BRANCH=$DEV
INITIAL_ADDONS=$ADDONS
EOF

git clone -b 16.0 --depth 1 git@github.com:odoo/design-themes.git ./addons_themes
pip3 install --upgrade pip
pip3 install -r dev/requirements.txt
git submodule update --init
git update-index --assume-unchanged config/* dev/*
chmod +x dev.sh
chmod +x dev/debug.sh
set -o allexport
source .env
set +o allexport
cd .git/hooks
rm -f commit-msg
rm -f pre-push
sed -i'.original' -e "s/PROJECT_CODE/$PROJECT_CODE/" ../../dev/.git-hooks/commit-msg.py
chmod +x ../../dev/.git-hooks/commit-msg.py
ln -s ../../dev/.git-hooks/commit-msg.py ./commit-msg
sed -i'.original' -e "s/PROJECT_CODE/$PROJECT_CODE/" ../../dev/.git-hooks/pre-push.py
chmod +x ../../dev/.git-hooks/pre-push.py
ln -s ../../dev/.git-hooks/pre-push.py ./pre-push
# Create docker containers
docker-compose up -d
