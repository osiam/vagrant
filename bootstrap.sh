#!/usr/bin/env sh

OSIAM_VERSION=2.4

printf "Package: *\nPin: release a=trusty-backports\nPin-Priority: 500\n" > /etc/apt/preferences.d/backports
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    unzip vim openjdk-7-jdk tomcat7 postgresql maven linux-image-generic

cd /tmp

# install flyway
FLYWAY_VERSION=3.2.1
wget --quiet http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz
tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz
rm -f flyway-commandline-${FLYWAY_VERSION}.tar.gz
mv flyway-${FLYWAY_VERSION} /opt/flyway
mv -f /tmp/flyway.conf /opt/flyway/conf/flyway.conf
chmod +x /opt/flyway/flyway
ln -s /opt/flyway/flyway /usr/local/bin/flyway

# install greenmail webapp to provide simple smtp service for the self-administration and administration
wget --quiet http://central.maven.org/maven2/com/icegreen/greenmail-webapp/1.4.1/greenmail-webapp-1.4.1.war
mv greenmail-webapp-1.4.1.war /var/lib/tomcat7/webapps/

# download OSIAM
wget --quiet https://github.com/osiam/osiam/releases/download/v${OSIAM_VERSION}/osiam-distribution-${OSIAM_VERSION}.tar.gz
tar -xzf osiam-distribution-${OSIAM_VERSION}.tar.gz

cd /tmp/osiam-distribution-${OSIAM_VERSION}

# configure OSIAM
mkdir /etc/osiam
cp -r osiam-server/osiam-resource-server/configuration/* /etc/osiam
cp -r osiam-server/osiam-auth-server/configuration/* /etc/osiam
cp -r addon-self-administration/configuration/* /etc/osiam
cp -r addon-administration/configuration/* /etc/osiam

cat /tmp/addon-self-administration.properties >> /etc/osiam/addon-self-administration.properties

sed -i 's/org.osiam.mail.server.smtp.port=25/org.osiam.mail.server.smtp.port=10025/g' /etc/osiam/addon-administration.properties
sed -i 's/your.smtp.server.com/localhost/g' /etc/osiam/addon-administration.properties
sed -i 's/org.osiam.mail.server.username=username/org.osiam.mail.server.username=user1/g' /etc/osiam/addon-administration.properties

# configure database
echo "local all all           trust" > /etc/postgresql/9.3/main/pg_hba.conf
echo "host  all all 0.0.0.0/0 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

service postgresql restart

echo "CREATE USER ong WITH PASSWORD 'ong';" | sudo -u postgres psql
echo "CREATE DATABASE ong;" | sudo -u postgres psql
echo "GRANT ALL PRIVILEGES ON DATABASE ong TO ong;" | sudo -u postgres psql

# Provision database
mkdir -p migrations/auth-server
unzip -joqq osiam-server/osiam-auth-server/osiam-auth-server.war 'WEB-INF/classes/db/migration/postgresql/*' -d migrations/auth-server
flyway -table=auth_server_schema_version -locations=filesystem:migrations/auth-server migrate

mkdir -p migrations/resource-server
unzip -joqq osiam-server/osiam-resource-server/osiam-resource-server.war 'WEB-INF/classes/db/migration/postgresql/*' -d migrations/resource-server
flyway -table=resource_server_schema_version -locations=filesystem:migrations/resource-server migrate

psql -h 127.0.0.1 -f addon-self-administration/sql/client.sql -U ong
psql -h 127.0.0.1 -f addon-self-administration/sql/extension.sql -U ong
psql -h 127.0.0.1 -f addon-administration/sql/client.sql -U ong
psql -h 127.0.0.1 -f addon-administration/sql/admin_group.sql -U ong

# setup Tomcat
sed -i "/^shared\.loader=/c\shared.loader=/var/lib/tomcat7/shared/classes,/var/lib/tomcat7/shared/*.jar,/etc/osiam" /etc/tomcat7/catalina.properties
sed -i "/^JAVA_OPTS=/c\JAVA_OPTS=\"-Djava.awt.headless=true -Xms512m -Xmx2048m -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=1024m\"" /etc/default/tomcat7

service tomcat7 restart

# deploy apps
find . -name '*.war' -exec cp {} /var/lib/tomcat7/webapps/ \;

# configure docker
echo "DOCKER_OPTS=\"-H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock\"" >> /etc/default/docker
restart docker
