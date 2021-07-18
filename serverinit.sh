#!/bin/bash




yum_config(){
  yum install epel-release -y
  curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
  curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  yum clean all && yum makecache
  yum install -y yum-axelget
  yum -y install  iotop iftop net-tools lrzsz gcc gcc-c++ make cmake libxml2-devel openssl-devel \
  curl curl-devel unzip sudo ntp libaio-devel  vim ncurses-devel autoconf automake zlib-devel perl  python3 python3-devel bash-completion
}

update_kernel(){
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	rpm -Uvh https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
	yum --enablerepo=elrepo-kernel -y install kernel-ml kernel-ml-devel
	kernel_version=`grep -oE "CentOS.*\)" /etc/grub2.cfg|head -n 1`
	grub2-set-default "${kernel_version}"

}
yum_update(){
	yum update -y
}


#system config
system_config(){
  sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
  timedatectl set-local-rtc 1 && timedatectl set-timezone Asia/Shanghai
}
ulimit_config(){
  echo "ulimit -SHn 102400" >> /etc/rc.local
  cat >> /etc/security/limits.conf << EOF
  *           soft   nofile       102400
  *           hard   nofile       102400
  *           soft   nproc        102400
  *           hard   nproc        102400
  *           soft  memlock      unlimited 
  *           hard  memlock      unlimited
EOF

}

#set sysctl
sysctl_config(){
  cp /etc/sysctl.conf /etc/sysctl.conf.bak
  cat > /etc/sysctl.conf << EOF
  net.ipv4.ip_forward = 1
  net.ipv4.conf.default.rp_filter = 1
  net.ipv4.conf.default.accept_source_route = 0
  kernel.sysrq = 0
  kernel.core_uses_pid = 1
  net.ipv4.tcp_syncookies = 1
  kernel.msgmnb = 65536
  kernel.msgmax = 65536
  kernel.shmmax = 68719476736
  kernel.shmall = 4294967296
  net.ipv4.tcp_max_tw_buckets = 6000
  net.ipv4.tcp_sack = 1
  net.ipv4.tcp_window_scaling = 1
  net.ipv4.tcp_rmem = 4096 87380 4194304
  net.ipv4.tcp_wmem = 4096 16384 4194304
  net.core.wmem_default = 8388608
  net.core.rmem_default = 8388608
  net.core.rmem_max = 16777216
  net.core.wmem_max = 16777216
  net.core.netdev_max_backlog = 262144
  net.ipv4.tcp_max_orphans = 3276800
  net.ipv4.tcp_max_syn_backlog = 262144
  net.ipv4.tcp_timestamps = 0
  net.ipv4.tcp_synack_retries = 1
  net.ipv4.tcp_syn_retries = 1
  net.ipv4.tcp_tw_reuse = 1
  net.ipv4.tcp_mem = 94500000 915000000 927000000
  net.ipv4.tcp_fin_timeout = 1
  net.ipv4.tcp_keepalive_time = 30
  net.ipv4.ip_local_port_range = 1024 65000
EOF
  /sbin/sysctl -p
  echo "sysctl set OK!!"
}
install_docker() {
	yum install -y yum-utils 
	yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
	yum-config-manager --disable docker-ce-test
	yum-config-manager --disable docker-ce-nightly
	yum install docker-ce docker-ce-cli containerd.io -y
	systemctl start docker
	systemctl enable docker
	echo "docker install succeed!!"
}

install_docker_compose() {
	curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose 
	docker-compose --version
	echo "docker-compose install succeed!!"
}

main(){
	yum_config
  	update_kernel
  	yum_update
	system_config
 	ulimit_config
	sysctl_config
  	install_docker
  	install_docker_compose
}
main
