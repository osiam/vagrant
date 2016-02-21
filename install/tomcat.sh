#!/bin/bash

set -e

# setup tomcat
cp install/osiam.xml /var/lib/tomcat8/conf/Catalina/localhost/osiam.xml
find . -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
sed -i "/^shared\.loader=/c\shared.loader=/var/lib/tomcat8/shared/classes,/var/lib/tomcat8/shared/*.jar,/etc/osiam" /etc/tomcat8/catalina.properties
sed -i "/^JAVA_OPTS=/c\JAVA_OPTS=\"-Djava.awt.headless=true -Xms512m -Xmx2048m -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=1024m\"" /etc/default/tomcat8

sed -i 's/org.osiam.mail.server.smtp.port=25/org.osiam.mail.server.smtp.port=10025/g' /etc/osiam/addon-administration.properties
sed -i 's/your.smtp.server.com/localhost/g' /etc/osiam/addon-administration.properties
sed -i 's/org.osiam.mail.server.username=username/org.osiam.mail.server.username=user1/g' /etc/osiam/addon-administration.properties

service tomcat8 restart
