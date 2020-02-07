echo Using functions to handle copy paste operations

downloadNodeExporter () {
local nodeVersion=0.18.1
echo Checking if node_exporter is installed
if [ -f "/usr/local/bin/node_exporter" ]; then
  echo node_exporter Already Installed?
  #ToDo Check Version
  return
fi

#Download File
local INSTALLFILE=node_exporter-$nodeVersion.linux-amd64.tar.gz
if [ ! -f "$INSTALLFILE" ]; then
  wget https://github.com/prometheus/node_exporter/releases/download/v$nodeVersion/$INSTALLFILE | wait
fi

#Extract and Move to Bin
tar -xvzf $INSTALLFILE
mv node_exporter-$nodeVersion.linux-amd64/node_exporter /usr/local/bin/node_exporter
}

configureNodeExporter(){
local serviceUser=node_exporter
local serviceName=node_exporter
local serviceOptions=''
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

#ToDo Check Sudo/Root
downloadNodeExporter
configureNodeExporter

#Check Status
systemctl status node_exporter
curl http://localhost:9100/metrics

