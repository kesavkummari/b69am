#!/bin/bash

yum clean all

amazon-linux-extras install tomcat8.5=8.5.50

alternatives --set java  /usr/lib/jvm/java-11-amazon-corretto.x86_64/bin/java

mv /home/ec2-user/javaapp/ROOT.war /var/lib/tomcat/webapps/


### Java 
yum -y install java-11-amazon-corretto-headless-11.0.13+8-2.amzn2.x86_64 log4j-cve-2021-44228-hotpatch

#### Httpd

#!/bin/bash

# Install apache
yum -y install httpd-2.4.52

# Set up proxy for Tomcat server
cat <<EOT >> /etc/httpd/conf/httpd.conf
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so

ProxyRequests Off
ProxyPass / http://localhost:8080/
ProxyPassReverse / http://localhost:8080/

<Location "/">
  Order allow,deny
  Allow from all
</Location>
EOT


#### Python
#!/bin/bash

cd /home/ec2-user

# Install python3
yum -y install python3-3.7.9-1.amzn2.0.2

# Install pip
yum -y install python3-pip-9.0.3
pip3 install -Iv --upgrade pip==20.2.1

# Install awscli and python dev libraries
pip3 install --user -r scripts/requirements.txt


#### requirements.txt

awscli==1.27.84
boto3==1.26.84
pycryptodome==3.9.7

#### start

#!/bin/bash
service tomcat start
service httpd start

#### Stop 
#!/bin/bash
isExistApp = `pgrep httpd`
if [[ -n  $isExistApp ]]; then
    service httpd stop
fi


