#!/usr/bin/env sh

printf "Package: *\nPin: release a=trusty-backports\nPin-Priority: 500\n" > /etc/apt/preferences.d/backports
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    unzip vim openjdk-7-jdk tomcat7 postgresql maven

cd /tmp

# install flyway
wget --quiet http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/3.2.1/flyway-commandline-3.2.1.tar.gz
tar -xzf flyway-commandline-3.2.1.tar.gz
rm -f flyway-commandline-3.2.1.tar.gz
mv flyway-3.2.1 /opt/
mv -f /tmp/flyway.conf /opt/flyway-3.2.1/conf/flyway.conf
chmod +x /opt/flyway-3.2.1/flyway
ln -s /opt/flyway-3.2.1/flyway /usr/local/bin/flyway

# download OSIAM
wget --quiet https://github.com/osiam/distribution/releases/download/v2.1/osiam-distribution-2.1.tar.gz
tar -xzf osiam-distribution-2.1.tar.gz

cd /tmp/osiam-distribution-2.1

# configure OSIAM
mkdir /etc/osiam
cp -r osiam-server/osiam-resource-server/configuration/* /etc/osiam
cp -r osiam-server/osiam-auth-server/configuration/* /etc/osiam
cp -r addon-self-administration/configuration/* /etc/osiam
cp -r addon-administration/configuration/* /etc/osiam

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

psql -h 127.0.0.1 -f addon-self-administration/sql/init_data.sql -U ong
psql -h 127.0.0.1 -f /tmp/setup_data.sql -U ong

# setup Tomcat
sed -i "/^shared\.loader=/c\shared.loader=/var/lib/tomcat7/shared/classes,/var/lib/tomcat7/shared/*.jar,/etc/osiam" /etc/tomcat7/catalina.properties
sed -i "/^JAVA_OPTS=/c\JAVA_OPTS=\"-Djava.awt.headless=true -Xms512m -Xmx1024m -XX:+UseConcMarkSweepGC\"" /etc/default/tomcat7

service tomcat7 restart

# deploy apps
find . -name '*.war' -exec cp {} /var/lib/tomcat7/webapps/ \;
