#!/bin/bash
service_user=redis
download_link="http://download.redis.io/releases/redis-2.8.12.tar.gz"
redis_home="/usr/local/redis/"
rdir=${download_link##*/}
install_packages(){
	apt-get install tcl8.5 build-essential
}

compile_redis(){
     id ${service_user} >/dev/null 2>&1 || useradd -r ${service_user}
     [[ -d ${redis_home} ]] || mkdir -p ${redis_home}
     cd /tmp/
     wget -cnd ${download_link}
     tar -xzvf ${rdir}
     cd ${rdir%.tar.gz} 
     make 
}

create_dir_struct(){
     mkdir -p ${redis_home}/{bin,etc,log,run,lib}
     cp -v /tmp/${rdir%.tar.gz}/src/redis-{cli,server,sentinel,chef-aof} ${redis_home}/bin/
     ln -fs ${redis_home}/bin/redis-server /usr/local/bin/redis-server
     ln -fs ${redis_home}/bin/redis-cli /usr/local/bin/redis-cli
     ln -fs ${redis_home}/bin/redis-sentinel /usr/local/bin/redis-sentinel
     curl https://raw.githubusercontent.com/rahulinux/redis/master/redis.conf >\
         ${redis_home}/etc/redis.conf
     ln -fs ${redis_home}/etc/redis.conf /etc/redis.conf
     chown -R ${service_user}. ${redis_home}
     curl https://raw.githubusercontent.com/rahulinux/redis/master/redis-init.sh > \
       /etc/init.d/redis-server
     chmod +x /etc/init.d/redis-server
     mkdir /data 
     chown ${service_user}. /data
}

main(){
  install_packages
  compile_redis
  create_dir_struct
}


main
