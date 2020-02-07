echo Using functions to handle copy paste operations

downloadNodeExporter () {
local nodeVersion=0.18.1
echo Checking if Node is installed
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
#Test if User Exists
## 
# -s shell
# -M No Home
# -N No Group

useradd -M --system -N -s /usr/sbin/nologin node_exporter 
#Server Account
passwd -l node_exporter


if [ ! -f "/etc/sysconfig/node_exporter" ]; then
echo Creating Node Exporter Config File
  echo OPTIONS=\"\" > /etc/sysconfig/node_exporter
fi

if [ ! -f "/etc/systemd/system/node_exporter.service" ]; then
echo Creating Node Exporter Service
mkdir /etc/sysconfig

cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/usr/local/bin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
EOF

systemctl enable node_exporter
systemctl start node_exporter
fi

}
#ToDo Check Sudo/Root
downloadNodeExporter
configureNodeExporter

#Check Status
systemctl status node_exporter
curl http://localhost:9100/metrics

