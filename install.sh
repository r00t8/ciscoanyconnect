#!/bin/bash

mkdir /usr/local/src/tmpciscoanyconnect
cd /usr/local/src/tmpciscoanyconnect

cat > ./hack.c <<END
#include <sys/socket.h>
#include <linux/netlink.h>

int _ZN27CInterfaceRouteMonitorLinux20routeCallbackHandlerEv()
{
  int fd=50;          // max fd to try
  char buf[8192];
  struct sockaddr_nl sa;
  socklen_t len = sizeof(sa);

  while (fd) {
     if (!getsockname(fd, (struct sockaddr *)&sa, &len)) {
        if (sa.nl_family == AF_NETLINK) {
           ssize_t n = recv(fd, buf, sizeof(buf), MSG_DONTWAIT);
        }
     }
     fd--;
  }
  return 0;
}
END

gcc -o libhack.so -shared -fPIC hack.c
cp libhack.so  /opt/cisco/anyconnect/lib/
/etc/init.d/vpnagentd stop
mkdir /usr/local/src/tmpciscoanyconnect/backup
cp /etc/init.d/vpnagentd /usr/local/src/tmpciscoanyconnect/backup/
sed -i 's#/opt/cisco/anyconnect/bin/vpnagentd#LD_PRELOAD=/opt/cisco/anyconnect/lib/libhack.so /opt/cisco/anyconnect/bin/vpnagentd#g' /etc/init.d/vpnagentd

/etc/init.d/vpnagentd start

echo "###########################################"
echo "##### NOW CONNECT TO YOUR VPN ACCOUNT#####"
echo "###########################################"
echo "After connecting to VPN, RUN below mentioned commands"
echo "iptables-save | grep -v DROP | iptables-restore"
echo "route add -net 192.168.1.0 netmask 255.255.255.0 dev eth0"
echo "Change IP address in about command if you have different IP schema"