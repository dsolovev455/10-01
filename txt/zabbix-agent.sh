# repo override
#kz
sed -i 's/us.archive.ubuntu.com/mirror.hoster.kz/g' /etc/apt/sources.list
#ru
#sed -i 's/us.archive.ubuntu.com/mirror.linux-ia64.org/g' /etc/apt/sources.list

useradd $1 -s /bin/bash -d /home/solovev
mkdir /home/solovev
chown -R solovev:solovev /home/solovev
echo ''$1'    ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

usermod --password $(openssl passwd -6 $2) root
usermod --password $(openssl passwd -6 $2) $1

if [ $3 == "true" ]; then apt upgrade -y; else echo '$3'=$3; fi

rm -Rf /etc/hosts

echo "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
echo "$5	$4.localdomain	$4" >> /etc/hosts

echo "*******************************************************************************"
echo "************************** INSTALLING ZABBIX-AGENT ****************************"
echo "*******************************************************************************"
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bdebian11_all.deb
dpkg -i zabbix-release_6.0-4+debian11_all.deb
apt update 
apt install zabbix-agent -y
sed -i "s/Server=127.0.0.1/Server=$6/g" /etc/zabbix/zabbix_agentd.conf
echo 'UserParameter=custom_echo[*],echo $1' >> /etc/zabbix/zabbix_agentd.conf
echo 'UserParameter=my_script1[*], python3 /etc/zabbix/test_python_script.py $1 $2' > /etc/zabbix/zabbix_agentd.d/test_user_parameter1.conf
echo 'UserParameter=my_script2[*], bash /etc/zabbix/test_bash_script.sh $1 $2' > /etc/zabbix/zabbix_agentd.d/test_user_parameter2.conf
systemctl restart zabbix-agent
systemctl enable zabbix-agent

if [[ ! -f /etc/zabbix/test_python_script.py ]]
then
    echo 'import sys' >> /etc/zabbix/test_python_script.py
    echo 'import os' >> /etc/zabbix/test_python_script.py
    echo 'import re' >> /etc/zabbix/test_python_script.py
    echo 'from datetime import date' >> /etc/zabbix/test_python_script.py
    echo 'if (sys.argv[1] == "-ping"): # Если -ping' >> /etc/zabbix/test_python_script.py
    echo '        result=os.popen("ping -c 1 " + sys.argv[2]).read() # Делаем пинг по заданному адресу' >> /etc/zabbix/test_python_script.py
    echo '        result=re.findall(r"time=(.*) ms", result) # Выдёргиваем из результата время' >> /etc/zabbix/test_python_script.py
    echo '        print(result[0]) # Выводим результат в консоль' >> /etc/zabbix/test_python_script.py
    echo 'elif (sys.argv[1] == "-simple_print"): # Если simple_print ' >> /etc/zabbix/test_python_script.py
    echo '        print(sys.argv[2]) # Выводим в консоль содержимое sys.arvg[2]' >> /etc/zabbix/test_python_script.py
    echo 'elif (sys.argv[1] == "1"):' >> /etc/zabbix/test_python_script.py
    echo '        print("SolovevDV")' >> /etc/zabbix/test_python_script.py
    echo 'elif (sys.argv[1] == "2"):' >> /etc/zabbix/test_python_script.py
    echo '        current_date = date.today()' >> /etc/zabbix/test_python_script.py
    echo '        print(current_date)' >> /etc/zabbix/test_python_script.py
    echo 'else: # Во всех остальных случаях' >> /etc/zabbix/test_python_script.py
    echo '        print(f"unknown input: {sys.argv[1]}") # Выводим непонятый запрос в консоль.' >> /etc/zabbix/test_python_script.py
fi

if [[ ! -f /etc/zabbix/test_bash_script.sh ]]
then
    echo '#!/bin/bash' >> /etc/zabbix/test_bash_script.sh
    echo 'if [[ $1 -eq 1 ]]; then' >> /etc/zabbix/test_bash_script.sh
    echo '  echo "SolovevDV"' >> /etc/zabbix/test_bash_script.sh
    echo 'elif [[ $1 -eq 2 ]]; then' >> /etc/zabbix/test_bash_script.sh
    echo '  echo "$(date)"' >> /etc/zabbix/test_bash_script.sh
    echo 'else' >> /etc/zabbix/test_bash_script.sh
    echo '  echo "Wrong argument"' >> /etc/zabbix/test_bash_script.sh
    echo 'fi'  >> /etc/zabbix/test_bash_script.sh
fi





echo "*******************************************************************************"
echo "********************************* END *****************************************"
echo "*******************************************************************************"
