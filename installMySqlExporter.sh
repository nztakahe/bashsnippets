echo Using functions to handle copy paste operations

downloadmySQLExporter () {
local mySQLVersion=0.12.1
echo Checking if mysql_exporter is installed
local mySQLInstallLocation=/usr/local/bin/mysqld_exporter
if [ -f "$mySQLInstallLocation" ]; then
  echo mysqld_exporter Already Installed?
  #ToDo Check Version
  return
fi

#Download File
local INSTALLFILE=mysqld_exporter-$mySQLVersion.linux-amd64
local DOWNLOADFILE=mysqld_exporter-$mySQLVersion.linux-amd64.tar.gz
if [ ! -f $DOWNLOADFILE ]; then
  wget https://github.com/prometheus/mysqld_exporter/releases/download/v$mySQLVersion/$DOWNLOADFILE | wait
fi

tar -xvzf $DOWNLOADFILE
mv $INSTALLFILE/mysqld_exporter $mySQLInstallLocation
}

configuremySQLExporter(){
local serviceUser=mysql_exporter
local serviceName=mysql_exporter
local serviceOptions='--config.my-cnf /etc/.mysqld_exporter.cnf --collect.slave_status'
local serviceBin=/usr/local/bin/mysql_exporter

useradd -M --system -N -s /usr/sbin/nologin $serviceUser
passwd -l $serviceUser

#Service Configuration
if [ ! -f "/etc/sysconfig/$serviceName" ]; then
echo Creating $serviceName Config File
  echo OPTIONS=\"$serviceOptions\" > /etc/sysconfig/$serviceName
fi

#SystemD config
if [ ! -f "/etc/systemd/system/$serviceName.service" ]; then
echo Creating $serviceName Service
mkdir /etc/sysconfig

cat << EOF > /etc/systemd/system/$serviceName.service
[Unit]
Description=$serviceName

[Service]
User=$serviceUser
EnvironmentFile=/etc/sysconfig/$serviceName
ExecStart=$serviceBin \$OPTIONS

[Install]
WantedBy=multi-user.target
EOF

systemctl enable $serviceName
systemctl start $serviceName
fi
}

function mySQLCreds(){
local serviceUser=mysql_exporter
local mysqlExportUser=tobecompleted
local mysqlExport=redacted
if [ ! -f /etc/.mysqld_exporter.cnf ]; then
echo Creating mySQLExporterCreds
cat << EOF > /etc/.mysqld_exporter.cnf
[client]
user=$mysqlExportUser
password=$mysqlExport  
}
EOF
chown $serviceUser:root /etc/.mysqld_exporter.cnf
chmod 470 /etc/.mysqld_exporter.cnf
fi
}

downloadmySQLExporter
