#!/bin/bash

install_packages () {
    export LANG=en_US
    echo "[updating repos]"
    echo P@ssw0rd | sudo -S yum install update -y >> /dev/null
    sudo yum install psmisc -y >> /dev/null
    echo "[installing git]"
    sudo yum install git -y >> /dev/null
    echo "[adding node repo]"
    curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash - >> /dev/null
    echo "[installing node]"
    sudo yum install nodejs -y >> /dev/null
    echo "[copying mongodb repo]"
    sudo cp /home/admin/setup/mongodb-org.repo /etc/yum.repos.d/mongodb-org.repo >> /dev/null
    echo "[installing mongodb server]"
    sudo yum install mongodb-org-server -y >> /dev/null
    echo "[enabling and starting mongod]"
    echo P@ssw0rd | sudo -S systemctl enable mongod >> /dev/null
    echo P@ssword | sudo -S systemctl start mongod >> /dev/null
}

create_user () {
    echo "[adding todoapp user]"
    sudo useradd todoapp >> /dev/null
    echo "[setting todoapp password]"
    echo "P@ssw0rd" | sudo passwd --stdin todoapp >> /dev/null
    echo "[making todoapp home directory]"
    sudo mkdir /home/todoapp/app >> /dev/null
    echo "[giving todoapp home ownership]"
    sudo chown todoapp -R /home/todoapp >> /dev/null
    echo "[git cloning as todoapp]"
    sudo git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todoapp/app/ACIT4640-todo-app
}

install_application () {
    echo "[running npm install]"
    sudo npm install --prefix /home/todoapp/app/ACIT4640-todo-app >> /dev/null
    echo "[moving database.js from setup folder to target]"
    sudo mv /home/admin/setup/database.js /home/todoapp/app/ACIT4640-todo-app/config/ >> /dev/null
    echo "[setting firewall rules]"
    sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp >> /dev/null
    sudo firewall-cmd --runtime-to-permanent >> /dev/null
    echo "[returning home and setting permissions]"
    cd /home >> /dev/null
    sudo chmod 755 -R /home/todoapp/ >> /dev/null
    echo "[giving todoapp home ownership]"
    sudo chown todoapp -R /home/todoapp >> /dev/null
}

install_nginx () {
    echo "[installing epel-release]"
    sudo yum install epel-release -y >> /dev/null
    echo "[installing nginx]"
    sudo yum install nginx -y >> /dev/null
    echo "[starting nginx]"
    sudo systemctl start nginx >> /dev/null
    echo "[moving nginx.conf to target]"
    sudo mv /home/admin/setup/nginx.conf /etc/nginx/nginx.conf >> /dev/null
    echo "[owning and setting permissions for nginx]"
    sudo chmod 777 /etc/nginx/nginx.conf >> /dev/null
    sudo chown nginx:nginx /etc/nginx/nginx.conf >> /dev/null
    echo "[enabling nginx]"
    sudo setenforce 0
    sudo systemctl enable nginx >> /dev/null
    echo "[restarting nginx]"
    sudo fuser -k 80/tcp >> /dev/null
    sudo systemctl restart nginx >> /dev/null
}

nodejs_systemd () {
    echo "[moving todoapp.service to target]"
    sudo mv /home/admin/setup/todoapp.service /etc/systemd/system/ >> /dev/null
    # sudo chmod 0644 /etc/systemd/system/todoapp.service
    sudo chown todoapp:todoapp /etc/systemd/system/todoapp.service
    echo "[reloading daemon]"
    sudo systemctl daemon-reload >> /dev/null
    echo "[enabling todoapp.service]"
    sudo systemctl enable todoapp >> /dev/null
    echo "[starting todoapp.service]"
    sudo systemctl start todoapp >> /dev/null
    echo "[checking todoapp.service status]"
    sudo systemctl status todoapp
    echo "[restarting nginx]"
    sudo setenforce 0
    sudo fuser -k 80/tcp >> /dev/null
    sudo systemctl restart nginx >> /dev/null
}

echo "Starting script..."

install_packages
create_user
install_application
install_nginx
nodejs_systemd

echo "DONE!"
