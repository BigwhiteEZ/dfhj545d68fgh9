#!/bin/bash
clear
echo "============================================================================================="
echo "                              WELCOME TO NKNx FAST DEPLOY!"
echo "============================================================================================="
echo
echo "This script will automatically provision a node as you configured it in your snippet."
echo "So grab a coffee, lean back or do something else - installation will take about 5 minutes."
echo -e "============================================================================================="
echo
echo "Hardening your OS..."
echo "---------------------------"
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq upgrade -y
echo "Installing necessary libraries..."
echo "---------------------------"
apt-get install make curl git unzip whois makepasswd -y --allow-downgrades --allow-remove-essential --allow-change-held-packages
apt-get install unzip jq -y --allow-downgrades --allow-remove-essential --allow-change-held-packages
curl --insecure --data "secret=c449235286c118d0c9ea5bebfe9297f8e0a18dbe" https://api.nknx.org/fast-deploy/callbacks/created
useradd nknx
mkdir -p /home/nknx/.ssh
mkdir -p /home/nknx/.nknx
adduser nknx sudo
chsh -s /bin/bash nknx
PASSWORD=$(mkpasswd i85m0Xhz)
usermod --password $PASSWORD nknx > /dev/null 2>&1
cd /home/nknx
echo "Installing NKN Commercial..."
echo "---------------------------"
wget --quiet --continue --show-progress https://commercial.nkn.org/downloads/nkn-commercial/linux-amd64.zip > /dev/null 2>&1
unzip -qq linux-amd64.zip
cd linux-amd64
cat >config.json <<EOF
{
    "nkn-node": {
      "noRemotePortCheck": true
    }
}
EOF
./nkn-commercial -b NKNXKoKhqNRhynXkoj2YKXZ3GLdyuBhNn3kV -c /home/nknx/linux-amd64/config.json -d /home/nknx/nkn-commercial -u nknx install > /dev/null 2>&1
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
echo "Waiting for wallet generation..."
echo "---------------------------"
while [ ! -f /home/nknx/nkn-commercial/services/nkn-node/wallet.json ]; do sleep 10; done
echo "Downloading pruned snapshot..."
echo "---------------------------"
curl --insecure --data "secret=c449235286c118d0c9ea5bebfe9297f8e0a18dbe" https://api.nknx.org/fast-deploy/callbacks/downloading-snapshot
cd /home/nknx/nkn-commercial/services/nkn-node/
systemctl stop nkn-commercial.service
rm -rf ChainDB
wget -c https://link.jscdn.cn/sharepoint/aHR0cHM6Ly93aDV2aC1teS5zaGFyZXBvaW50LmNvbS86dTovZy9wZXJzb25hbC9qYmJka19pcF9jaS9FZnlxR1ZsY3dyVkluQkxBT2w0SnA2TUJIdEMtRU1QVmtiRC1zeHZMY2tQd1N3P2U9djhFUlVH.tar.gz -O - | tar -xz
mv aHR0cHM6Ly93aDV2aC1teS5zaGFyZXBvaW50LmNvbS86dTovZy9wZXJzb25hbC9qYmJka19pcF9jaS9FZnlxR1ZsY3dyVkluQkxBT2w0SnA2TUJIdEMtRU1QVmtiRC1zeHZMY2tQd1N3P2U9djhFUlVH ChainDB
curl --insecure --data "secret=c449235286c118d0c9ea5bebfe9297f8e0a18dbe" https://api.nknx.org/fast-deploy/callbacks/unzipping-snapshot
chown -R nknx:nknx ChainDB/
systemctl start nkn-commercial.service
echo "Applying finishing touches..."
echo "---------------------------"
addr=$(jq -r .Address /home/nknx/nkn-commercial/services/nkn-node/wallet.json)
cd /home/nknx/.nknx
cat >donationcheck <<EOF
cd /home/nknx/linux-amd64
response=\$(curl --write-out %{http_code} --silent --output /dev/null "https://openapi.nkn.org/api/v1/addresses/ZZZYYY/hasMinedToAddress/NKNXXXXXGKct2cZuhSGW6xqiqeFVd5nJtAzg")
if [ "\$response" -eq 202 ]
then
systemctl stop nkn-commercial.service
./nkn-commercial -b NKNXKoKhqNRhynXkoj2YKXZ3GLdyuBhNn3kV -c /home/nknx/linux-amd64/config.json -d /home/nknx/nkn-commercial -u nknx install
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
cd /home/nknx/.nknx
crontab -l > tempcron
sed -i '$ d' tempcron
crontab tempcron > /dev/null 2>&1
rm tempcron > /dev/null 2>&1
#curl --insecure --data "secret=c449235286c118d0c9ea5bebfe9297f8e0a18dbe" https://api.nknx.org/fast-deploy/callbacks/donated
#rm /home/nknx/.nknx/donationcheck > /dev/null 2>&1
fi
EOF
#sed -i "s/ZZZYYY/$addr/g" donationcheck
#crontab -l > tempcron
#echo "27 * * * * /home/nknx/.nknx/donationcheck >/dev/null 2>&1" >> tempcron
#crontab tempcron
#rm tempcron
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
curl --insecure --data "secret=c449235286c118d0c9ea5bebfe9297f8e0a18dbe" https://api.nknx.org/fast-deploy/callbacks/finish-install
sleep 2
clear
echo
echo
echo
echo
echo "                                  -----------------------"
echo "                                  |   NKNx FAST-DEPLOY  |"
echo "                                  -----------------------"
echo
echo "============================================================================================="
echo "   NKN ADDRESS OF THIS NODE: $addr"
echo "   PASSWORD FOR THIS WALLET IS: i85m0Xhz"
echo "============================================================================================="
echo "   ALL MINED NKN WILL GO TO: NKNXKoKhqNRhynXkoj2YKXZ3GLdyuBhNn3kV"
echo "   (FIRST MINING WILL BE DONATED TO NKNX-TEAM)"
echo "============================================================================================="
echo
echo "You can now disconnect from your terminal. The node will automatically appear in NKNx after 1 minute."
echo
echo
echo
echo
