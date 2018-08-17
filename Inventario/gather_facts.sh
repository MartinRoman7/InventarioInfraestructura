#!/bin/bash

############################# Main variables #############################
ANSIBLE_USERNAME=martin.arcos
TARGET_HOSTS=all
BASE_DIR=/Users/ctin/Desktop/Ansible
########################## End Main variables ############################

while getopts ":u:T:b:" opt; do
case "${opt}" in

    u)
        ANSIBLE_USERNAME="${OPTARG}"
    ;;

    T)
        TARGET_HOSTS="${OPTARG}"
    ;;

    b)
        BASE_DIR="${OPTARG}"
    ;;


    *)
        echo "Usage: ${0} [options]"
        echo "Options:"
        echo " -u"
        echo "  Specify the ansible username"
        echo " -T"
        echo "  Specify target hosts"
        echo " -b"
        echo "  Specify the directory base"
        exit 1
    ;;
esac
done
shift $((OPTIND-1))


BASE_DIR_FACTS=${BASE_DIR}/Facts
mkdir ${BASE_DIR_FACTS}

echo "=================================="
echo "= Start of process to obtain facts ="
echo "=================================="


# Gather Ansible facts
ansible -m setup --tree ${BASE_DIR}/AnsibleFacts/

# Gather kernel facts
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "for param in kernel/core_uses_pid kernel/msgmax kernel/msgmnb kernel/shmall kernel/shmmax kernel/sysrq net/bridge/bridge-nf-call-arptables net/bridge/bridge-nf-call-ip6tables net/bridge/bridge-nf-call-iptables net/ipv4/conf/default/accept_source_route net/ipv4/conf/default/rp_filter net/ipv4/ip_forward net/ipv4/tcp_challenge_ack_limit net/ipv4/tcp_syncookies net/ipv4/tcp_tw_recycle net/ipv4/tcp_tw_reuse net/ipv6/conf/all/disable_ipv6 net/netfilter/nf_conntrack_tcp_be_liberal net/netfilter/nf_conntrack_tcp_timeout_close_wait net/netfilter/nf_conntrack_tcp_timeout_fin_wait net/netfilter/nf_conntrack_tcp_timeout_last_ack net/netfilter/nf_conntrack_tcp_timeout_time_wait; do if [ -f /proc/sys/\${param} ] ; then echo \"\${param}-dq-: [-dq-\`cat /proc/sys/\${param}\`-dq-]\" 2>/dev/null ; else echo \"\${param}-dq-: [-dq-N/A-dq-]\" 2>/dev/null ; fi ; done" -t ${BASE_DIR_FACTS}/KernelFacts/

# Gather databases facts
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "ps -ef | awk '{print \$1}' | grep -e mysql -e sqlserver -e db2 -e oracle -e postgresql -e sqlite -e sybase -e redis -e couchdb -e mongodb | uniq" -t ${BASE_DIR_FACTS}/Databases/

# Gather static routes facts
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "echo \"\$(/usr/sbin/ip ro sh || /sbin/ip ro sh)\" | awk '{print \$1 \" via \" \$3}'" -t ${BASE_DIR_FACTS}/StaticRoutes/

# Gather listening ports facts
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "netstat -tan | awk '/LISTEN/{print \$4}' | awk -F: '{print \" \" \$NF \"/tcp\";}' | sort -nu > temp.txt ; cat /etc/services | egrep -f temp.txt | awk '{print \$2 \" \" \$1}' | sed 's/\/tcp//'; cat /etc/services | egrep -f temp.txt | awk '{print \" \"\$2}' > temp2.txt; cat temp.txt | grep -v -f temp2.txt | sed 's/\/tcp//'; rm temp.txt; rm temp2.txt" -t ${BASE_DIR_FACTS}/Ports/

# Gather virtual hosts facts
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "echo \"/etc/nginx/vhosts/-dq-: [-dq-\`cat /etc/nginx/vhosts/*.conf | grep 'server_name' | sed -e 's/.*server_name//g' -e 's/;//' | uniq | sort\`-dq-]\" ; echo \"/var/containers/nginx/etc/nginx/vhosts/-dq-: [-dq-\`cat /var/containers/nginx/etc/nginx/vhosts/*.conf | grep 'server_name' | sed -e 's/.*server_name//g' -e 's/;//g' | uniq | sort\`-dq-]\"" -t ${BASE_DIR_FACTS}/VirtualHosts/

# Gather Limits.conf
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "if [ ! -f /etc/security/limits.conf ]; then echo \"limits.conf-dq-: [-dq-'N/A'-dq-]\"; else echo \"limits.conf-dq-: [-dq-\`cat /etc/security/limits.conf | egrep -v -e '#' | egrep -e '.'\`-dq-]\"; fi" -t ${BASE_DIR_FACTS}/Limits/

# Gather Dockers
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "echo \"===> Contenedor NGINX-dq-: [-dq-\`cat /var/containers/nginx/etc/nginx/vhosts/*.conf | grep 'server_name' | sed -e 's/.*server_name//g' -e 's/;//' | uniq | sort\`-dq-]\"; echo \"===> Contenedor IHS-dq-: [-dq-\`cat /var/containers/ihs/vhosts/* | egrep -e 'ServerName' | awk '{if(\$1 == \"ServerName\") print \$2}' | uniq | sort\`-dq-]\"" -t ${BASE_DIR_FACTS}/Dockers/

## Gather LXC NGINX Virtual Hosts
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "echo \"LXC NGINX Virtual Hosts-dq-: [-dq-\`cat /var/lib/lxc/*/rootfs/etc/nginx/vhosts/*.conf | grep 'server_name' | sed -e 's/.*server_name//g' -e 's/;//' | uniq | sort\`-dq-]\"" -t ${BASE_DIR_FACTS}/LXC_NGNIX_VH/

# Gather IHS Virtual Hosts
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "echo \"Server Name-dq-: [-dq-\`cat /opt/IBM/IHS/vhosts/* | egrep -e 'ServerName' | awk '{if(\$1 == \'ServerName\') print \$2}' | uniq | sort\`-dq-]\"; echo \"Server Alias-dq-: [-dq-\`cat /opt/IBM/IHS/vhosts/* | egrep -e 'ServerAlias' | awk '{if(\$1 == \'ServerAlias\') print \$2}' | uniq | sort\`-dq-]\"; echo \"Document Root-dq-: [-dq-\`cat /opt/IBM/IHS/vhosts/* | egrep -e 'DocumentRoot' | awk '{if(\$1 == \'DocumentRoot\') print \$2}' | uniq | sort\`-dq-]\"" -t ${BASE_DIR_FACTS}/IHS_VH/

## Gather Standalone.XML
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "echo \"User Name-dq-: [-dq-\`cat /opt/jboss/standalone/configuration/standalone.xml | egrep -e 'user[ \t]name=' | sed -e 's/.*<user name=\"//g' -e 's/\"\/\>//g'\`-dq-]\"; echo \"Jndi Name-dq-: [-dq-\`cat /opt/jboss/standalone/configuration/standalone.xml | egrep -e 'jndi-name=' | sed -e 's/.*jndi-name=\"//g' -e 's/[\"\>]//g' | grep 'jdbc' | awk '{print \$1}'\`-dq-]\"; echo \"Deployment Name-dq-: [-dq-\`cat /opt/jboss/standalone/configuration/standalone.xml | egrep -e 'deployment.name=' | sed -e 's/.*name=\"//g' -e 's/[\"\>]//g'\`-dq-]\"" -t ${BASE_DIR_FACTS}/Standalone/

# Gather State of Containers 

    # Docker
    #ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "echo \"Dockers Runnning-dq-: [-dq-\`sudo docker ps | grep 'Up' | awk 'FNR != 1 {print \$1}'\`-dq-]\"; echo \"Dockers Down-dq-: [-dq-\`sudo docker ps | grep 'Exited' | awk '{print \$1}'\`-dq-]\"; echo \"Dockers Restarting-dq-: [-dq-\`sudo docker ps | grep 'Restarting' | awk '{print \$1}'\`-dq-]\"; echo \"Dockers Paused-dq-: [-dq-\`sudo docker ps --filter status=paused | awk 'FNR != 1 {print \$1}'\`-dq-]\"" -t ${BASE_DIR_FACTS}/Docker_Status/

    # LXC 
    #ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "for i in $( sudo lxc-ls -1 ); do sudo lxc-info -n ${i} | awk ' FNR == 2 { if( \$2 == \"RUNNING\") print \"\'\"Container Running: ${i}\"\'\"}'; sudo lxc-info -n ${i} | awk ' FNR == 2 { if( \$2 == \"STOPPED\") print \"\'\"Container Stopped: ${i}\"\'\"}'; done" -t ${BASE_DIR_FACTS}/LXC_Status/

# Gather firewall rules
ansible ${TARGET_HOSTS} -u ${ANSIBLE_USERNAME} -m shell -a "sudo iptables-save | grep -v -e '#' -e 'COMMIT' -e '^:' | sed 's/^*/Tabla: /g'" -t ${BASE_DIR_FACTS}/Firewall/ 


echo "=================================="
echo "= End of process to obtain facts ="
echo "=================================="

#####################################################
# Copy to another directory the params that we      #
# we want with key,value                            #
#####################################################

mkdir ${BASE_DIR}/Aux

for directory in KernelFacts VirtualHosts Limits Dockers LXC_NGNIX_VH IHS_VH Standalone; do
    echo ${directory}
    cp -r ${BASE_DIR_FACTS}/${directory} ${BASE_DIR}/Aux
    rm -r ${BASE_DIR_FACTS}/${directory}
done

#####################################################
# Translate ansible output to formated json object  #
# AnsibleFacts wont require this transformation     #
#####################################################

cd ${BASE_DIR_FACTS}
for i in $( ls ); do
    echo ${i}   #Directory
    for k in $( ls ${BASE_DIR_FACTS}/${i} ); do
        echo ${k}   #Files
        cat ${BASE_DIR_FACTS}/${i}/${k} | python -c "import json; import sys; data = json.load(sys.stdin); print json.dumps({'${i}' :data['stdout_lines']})" > ${BASE_DIR_FACTS}/${i}/${k}_post
        mv ${BASE_DIR_FACTS}/${i}/${k}_post ${BASE_DIR_FACTS}/${i}/${k}
    done
done

#####################################################
#   We use a diferent directory for the facts that  #
#   have values and we want to make a key,value     #
#   The directory is Aux, but at the end all        # 
#   the facts are in BASE_DIR_FACTS                 #
#####################################################

cd ${BASE_DIR}/Aux
for i in $( ls ); do
    echo ${i}
    for k in $( ls ${BASE_DIR}/Aux/${i} ); do
        echo ${k}
        cat ${BASE_DIR}/Aux/${i}/${k} | python -c "import json; import sys; data = json.load(sys.stdin); print json.dumps({'${i}' :data['stdout_lines']})" > ${BASE_DIR}/Aux/${i}/${k}_post
        cat ${BASE_DIR}/Aux/${i}/${k}_post | sed -e 's/-dq-/\"/g' -e 's/]\"/]/g' -e 's/\[/[{/' -e 's/\]\]}/\]}\]}/' > ${BASE_DIR}/Aux/${i}/${k}_post_post
        mv ${BASE_DIR}/Aux/${i}/${k}_post_post ${BASE_DIR}/Aux/${i}/${k}
        rm ${BASE_DIR}/Aux/${i}/${k}_post
    done
done

cd ${BASE_DIR}/Aux
for i in $( ls ); do
    cp -r ${BASE_DIR}/Aux/${i} ${BASE_DIR_FACTS}
done

rm -r ${BASE_DIR}/Aux

echo "================================"
echo "= End of process to clear data ="
echo "================================"

