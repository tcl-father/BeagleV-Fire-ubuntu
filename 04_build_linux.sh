#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)
wdir=`pwd`
CC=${CC:-"${wdir}/riscv-toolchain/bin/riscv64-linux-"}

cd ./linux/

if [ ! -f ./.patched ] ; then
	if [ -f arch/riscv/configs/mpfs_defconfig ] ; then
		patch -p1 < ../patches/linux/0001-Add-BeagleV-Fire-device-tree.patch
		patch -p1 < ../patches/linux/0001-PCIe-Change-controller-and-bridge-base-address.patch
		patch -p1 < ../patches/linux/0001-GPIO-Add-Microchip-CoreGPIO-driver.patch
		patch -p1 < ../patches/linux/0001-ADC-Add-Microchip-MCP356X-driver.patch
		patch -p1 < ../patches/linux/0001-Microchip-QSPI-Add-regular-transfers.patch
		patch -p1 < ../patches/linux/0001-BeagleV-Fire-Add-printk-to-IM219-driver-for-board-te.patch
		patch -p1 < ../patches/linux/0001-MMC-SPI-Hack-to-support-non-DMA-capable-SPI-ctrl.patch
	fi
	touch .patched
fi

if [ -f arch/riscv/configs/mpfs_defconfig ] ; then
	cp -v ../patches/linux/Makefile arch/riscv/boot/dts/microchip/Makefile
	cp -v ../patches/linux/dts/mpfs-beaglev-fire.dts arch/riscv/boot/dts/microchip/
	cp -v ../patches/linux/dts/mpfs-beaglev-fire-fabric.dtsi arch/riscv/boot/dts/microchip/
else
	cp -v ../patches/linux/mainline/Makefile arch/riscv/boot/dts/microchip/Makefile
	cp -v ../patches/linux/mainline/dts/mpfs-beaglev-fire.dts arch/riscv/boot/dts/microchip/
	cp -v ../patches/linux/mainline/dts/mpfs-beaglev-fire-fabric.dtsi arch/riscv/boot/dts/microchip/
fi

echo "make ARCH=riscv CROSS_COMPILE=${CC} clean"
make ARCH=riscv CROSS_COMPILE=${CC} clean

if [ -f arch/riscv/configs/mpfs_defconfig ] ; then
	echo "make ARCH=riscv CROSS_COMPILE=${CC} mpfs_defconfig"
	make ARCH=riscv CROSS_COMPILE=${CC} mpfs_defconfig

	#
	# General setup
	#
	./scripts/config --enable CONFIG_AUDIT
	./scripts/config --disable CONFIG_LOCALVERSION_AUTO

	#
	# CPU/Task time and stats accounting
	#
	./scripts/config --enable CONFIG_TASKSTATS
	./scripts/config --enable CONFIG_TASK_DELAY_ACCT
	./scripts/config --enable CONFIG_TASK_XACCT

	#
	# Scheduler features
	#
	# end of Scheduler features
	./scripts/config --enable CONFIG_MEMCG
	./scripts/config --enable CONFIG_MEMCG_SWAP
	./scripts/config --enable CONFIG_MEMCG_KMEM
	./scripts/config --enable CONFIG_BLK_CGROUP
	./scripts/config --enable CONFIG_SCHED_MM_CID
	./scripts/config --enable CONFIG_CGROUP_PIDS
	./scripts/config --enable CONFIG_CGROUP_RDMA
	./scripts/config --enable CONFIG_CGROUP_FREEZER
	./scripts/config --enable CONFIG_CGROUP_HUGETLB
	./scripts/config --enable CONFIG_CPUSETS
	./scripts/config --enable CONFIG_PROC_PID_CPUSET
	./scripts/config --enable CONFIG_CGROUP_DEVICE
	./scripts/config --enable CONFIG_CGROUP_CPUACCT
	./scripts/config --enable CONFIG_CGROUP_PERF
	./scripts/config --enable CONFIG_NAMESPACES
	./scripts/config --enable CONFIG_UTS_NS
	./scripts/config --enable CONFIG_TIME_NS
	./scripts/config --enable CONFIG_IPC_NS
	./scripts/config --enable CONFIG_USER_NS
	./scripts/config --enable CONFIG_PID_NS
	./scripts/config --enable CONFIG_NET_NS
	./scripts/config --enable CONFIG_CHECKPOINT_RESTORE
	./scripts/config --enable CONFIG_SCHED_AUTOGROUP
	./scripts/config --enable CONFIG_RELAY
	./scripts/config --enable CONFIG_EMBEDDED

	#
	# Kernel Performance Events And Counters
	#
	./scripts/config --enable CONFIG_PERF_EVENTS
	./scripts/config --enable CONFIG_PROFILING

	#
	# Boot options
	#
	./scripts/config --set-str CONFIG_CMDLINE "root=/dev/mmcblk0p3 ro rootfstype=ext4 rootwait console=ttyS0,115200 earlycon uio_pdrv_genirq.of_id=generic-uio net.ifnames=0"
	./scripts/config --enable CONFIG_CMDLINE_FORCE

	./scripts/config --enable CONFIG_EEPROM_AT24
	./scripts/config --enable CONFIG_OF_OVERLAY
	./scripts/config --enable CONFIG_GPIO_MICROCHIP_CORE
	./scripts/config --enable CONFIG_MCP356X
	./scripts/config --enable CONFIG_POLARFIRE_SOC_GENERIC_SERVICE

	#
	# General architecture-dependent options
	#
	./scripts/config --enable CONFIG_KPROBES

	#
	# GCOV-based kernel profiling
	#
	./scripts/config --enable CONFIG_MODULE_FORCE_LOAD
	./scripts/config --enable CONFIG_MODULE_FORCE_UNLOAD
	./scripts/config --enable CONFIG_MODVERSIONS
	./scripts/config --enable CONFIG_MODULE_COMPRESS_XZ
	./scripts/config --set-str CONFIG_MODPROBE_PATH "/usr/sbin/modprobe"
	./scripts/config --enable CONFIG_BLK_CGROUP_IOCOST
	./scripts/config --enable CONFIG_BLK_SED_OPAL

	#
	# IO Schedulers
	#
	./scripts/config --module CONFIG_MQ_IOSCHED_KYBER
	./scripts/config --module CONFIG_IOSCHED_BFQ
	./scripts/config --enable CONFIG_BFQ_GROUP_IOSCHED

	#
	# Executable file formats
	#
	./scripts/config --module CONFIG_BINFMT_MISC

	#
	# Memory Management options
	#
	./scripts/config --enable CONFIG_KSM

	#
	# File systems
	#
	./scripts/config --enable CONFIG_EXT4_FS_SECURITY
	./scripts/config --disable CONFIG_FANOTIFY
	./scripts/config --enable CONFIG_AUTOFS_FS

	#
	# DOS/FAT/EXFAT/NT Filesystems
	#
	./scripts/config --enable CONFIG_FAT_FS
	./scripts/config --enable CONFIG_MSDOS_FS
	./scripts/config --enable CONFIG_VFAT_FS
	./scripts/config --enable CONFIG_NLS_CODEPAGE_437
	./scripts/config --enable CONFIG_NLS_ASCII
	./scripts/config --enable CONFIG_UNICODE

	#
	# Pseudo filesystems
	#
	./scripts/config --enable CONFIG_PROC_CHILDREN
	./scripts/config --enable CONFIG_HUGETLBFS
	./scripts/config --enable CONFIG_NLS_CODEPAGE_437

	#
	# Security options
	#
	./scripts/config --enable CONFIG_SECURITY
	./scripts/config --enable CONFIG_SECURITYFS
	./scripts/config --enable CONFIG_SECURITY_NETWORK
	./scripts/config --enable CONFIG_SECURITY_PATH
	./scripts/config --set-val CONFIG_LSM_MMAP_MIN_ADDR 65536

	./scripts/config --enable CONFIG_INTEGRITY

	#./scripts/config --disable CONFIG_VMAP_STACK
	#./scripts/config --disable CONFIG_SMP

	./scripts/config --enable CONFIG_USB_MUSB_DUAL_ROLE

	./scripts/config --enable CONFIG_USB_GADGET
	./scripts/config --enable CONFIG_USB_CONFIGFS
	./scripts/config --enable CONFIG_CONFIGFS_FS
	./scripts/config --enable CONFIG_USB_CONFIGFS_SERIAL
	./scripts/config --enable CONFIG_USB_CONFIGFS_ACM
	./scripts/config --enable CONFIG_USB_CONFIGFS_OBEX
	./scripts/config --enable CONFIG_USB_CONFIGFS_NCM
	./scripts/config --enable CONFIG_USB_CONFIGFS_ECM
	./scripts/config --enable CONFIG_USB_CONFIGFS_ECM_SUBSET
	./scripts/config --enable CONFIG_USB_CONFIGFS_RNDIS
	./scripts/config --enable CONFIG_USB_CONFIGFS_EEM
	./scripts/config --enable CONFIG_USB_CONFIGFS_PHONET
	./scripts/config --enable CONFIG_USB_CONFIGFS_MASS_STORAGE
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_LB_SS
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_FS
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC1
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC2
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_MIDI
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_HID
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UVC
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_PRINTER

	./scripts/config --module CONFIG_MEDIA_SUPPORT
	./scripts/config --enable CONFIG_MEDIA_SUPPORT_FILTER
	./scripts/config --enable CONFIG_MEDIA_SUBDRV_AUTOSELECT
	./scripts/config --enable CONFIG_MEDIA_CAMERA_SUPPORT
	./scripts/config --module CONFIG_VIDEO_IMX219

	#Optimize:
	./scripts/config --enable CONFIG_IP_NF_IPTABLES
	./scripts/config --enable CONFIG_NETFILTER_XTABLES
	./scripts/config --enable CONFIG_NLS_ISO8859_1
	./scripts/config --enable CONFIG_BLK_DEV_DM

	#Docker:

	#
	# Networking options
	#
	./scripts/config --module CONFIG_PACKET_DIAG
	./scripts/config --module CONFIG_UNIX_DIAG
	./scripts/config --enable CONFIG_XFRM
	./scripts/config --enable CONFIG_XFRM_OFFLOAD
	./scripts/config --module CONFIG_XFRM_ALGO
	./scripts/config --module CONFIG_XFRM_USER
	./scripts/config --module CONFIG_XFRM_INTERFACE
	./scripts/config --enable CONFIG_XFRM_SUB_POLICY
	./scripts/config --enable CONFIG_XFRM_MIGRATE
	./scripts/config --enable CONFIG_XFRM_STATISTICS
	./scripts/config --module CONFIG_NET_KEY
	./scripts/config --enable CONFIG_NET_KEY_MIGRATE
	./scripts/config --enable CONFIG_IP_MULTICAST
	./scripts/config --enable CONFIG_IP_ADVANCED_ROUTER
	./scripts/config --enable CONFIG_IP_FIB_TRIE_STATS
	./scripts/config --enable CONFIG_IP_MULTIPLE_TABLES
	./scripts/config --enable CONFIG_IP_ROUTE_MULTIPATH
	./scripts/config --enable CONFIG_IP_ROUTE_VERBOSE
	./scripts/config --enable CONFIG_IP_PNP
	./scripts/config --enable CONFIG_IP_PNP_DHCP
	./scripts/config --enable CONFIG_IP_PNP_BOOTP
	./scripts/config --enable CONFIG_IP_PNP_RARP
	./scripts/config --module CONFIG_NET_IPIP
	./scripts/config --module CONFIG_NET_IPGRE_DEMUX
	./scripts/config --module CONFIG_NET_IP_TUNNEL
	./scripts/config --enable CONFIG_XDP_SOCKETS
	./scripts/config --module CONFIG_NET_IPVTI
	./scripts/config --module CONFIG_NET_IPGRE
	./scripts/config --enable CONFIG_NET_IPGRE_BROADCAST
	./scripts/config --enable CONFIG_IP_MROUTE
	./scripts/config --module CONFIG_NET_FOU
	./scripts/config --enable CONFIG_NET_FOU_IP_TUNNELS
	./scripts/config --module CONFIG_INET_AH
	./scripts/config --module CONFIG_INET_ESP
	./scripts/config --module CONFIG_INET_ESP_OFFLOAD
	./scripts/config --module CONFIG_INET_IPCOMP
	./scripts/config --module CONFIG_INET_XFRM_TUNNEL
	./scripts/config --module CONFIG_INET_TUNNEL
	./scripts/config --module CONFIG_INET_DIAG
	./scripts/config --module CONFIG_INET_TCP_DIAG
	./scripts/config --module CONFIG_INET_UDP_DIAG
	./scripts/config --module CONFIG_INET_RAW_DIAG
	./scripts/config --enable CONFIG_INET_DIAG_DESTROY
	./scripts/config --enable CONFIG_TCP_CONG_ADVANCED
	./scripts/config --module CONFIG_TCP_CONG_HSTCP
	./scripts/config --module CONFIG_TCP_CONG_HYBLA
	./scripts/config --module CONFIG_TCP_CONG_VEGAS
	./scripts/config --module CONFIG_TCP_CONG_NV
	./scripts/config --module CONFIG_TCP_CONG_SCALABLE
	./scripts/config --module CONFIG_TCP_CONG_LP
	./scripts/config --module CONFIG_TCP_CONG_VENO
	./scripts/config --module CONFIG_TCP_CONG_YEAH
	./scripts/config --module CONFIG_TCP_CONG_ILLINOIS
	./scripts/config --module CONFIG_TCP_CONG_DCTCP
	./scripts/config --module CONFIG_TCP_CONG_CDG
	./scripts/config --module CONFIG_TCP_CONG_BBR
	./scripts/config --enable CONFIG_IPV6_MROUTE
	./scripts/config --enable CONFIG_IPV6_SEG6_LWTUNNEL
	./scripts/config --enable CONFIG_IPV6_SEG6_HMAC
	./scripts/config --enable CONFIG_NETLABEL
	./scripts/config --enable CONFIG_MPTCP
	./scripts/config --module CONFIG_INET_MPTCP_DIAG
	./scripts/config --enable CONFIG_NETWORK_SECMARK
	./scripts/config --enable CONFIG_NETWORK_PHY_TIMESTAMPING
	./scripts/config --enable CONFIG_NETFILTER
	./scripts/config --enable CONFIG_NETFILTER_ADVANCED
	./scripts/config --module CONFIG_BRIDGE_NETFILTER

	#
	# Core Netfilter Configuration
	#
	./scripts/config --module CONFIG_NETFILTER_NETLINK_ACCT
	./scripts/config --module CONFIG_NETFILTER_NETLINK_QUEUE
	./scripts/config --module CONFIG_NETFILTER_NETLINK_LOG
	./scripts/config --module CONFIG_NETFILTER_NETLINK_OSF
	./scripts/config --module CONFIG_NF_CONNTRACK
	./scripts/config --enable CONFIG_NF_CONNTRACK_SECMARK
	./scripts/config --enable CONFIG_NF_CONNTRACK_ZONES
	./scripts/config --enable CONFIG_NF_CONNTRACK_PROCFS
	./scripts/config --enable CONFIG_NF_CONNTRACK_EVENTS
	./scripts/config --enable CONFIG_NF_CONNTRACK_TIMEOUT
	./scripts/config --enable CONFIG_NF_CONNTRACK_TIMESTAMP
	./scripts/config --enable CONFIG_NF_CONNTRACK_LABELS
	./scripts/config --module CONFIG_NF_CONNTRACK_AMANDA
	./scripts/config --module CONFIG_NF_CONNTRACK_FTP
	./scripts/config --module CONFIG_NF_CONNTRACK_H323
	./scripts/config --module CONFIG_NF_CONNTRACK_IRC
	./scripts/config --module CONFIG_NF_CONNTRACK_NETBIOS_NS
	./scripts/config --module CONFIG_NF_CONNTRACK_SNMP
	./scripts/config --module CONFIG_NF_CONNTRACK_PPTP
	./scripts/config --module CONFIG_NF_CONNTRACK_SANE
	./scripts/config --module CONFIG_NF_CONNTRACK_SIP
	./scripts/config --module CONFIG_NF_CONNTRACK_TFTP
	./scripts/config --module CONFIG_NF_CT_NETLINK
	./scripts/config --module CONFIG_NF_CT_NETLINK_TIMEOUT
	./scripts/config --module CONFIG_NF_CT_NETLINK_HELPER
	./scripts/config --enable CONFIG_NETFILTER_NETLINK_GLUE_CT
	./scripts/config --module CONFIG_NF_NAT
	./scripts/config --module CONFIG_NF_NAT_FTP
	./scripts/config --module CONFIG_NF_NAT_TFTP
	./scripts/config --module CONFIG_NF_TABLES
	./scripts/config --enable CONFIG_NF_TABLES_INET
	./scripts/config --enable CONFIG_NF_TABLES_NETDEV
	./scripts/config --module CONFIG_NFT_NUMGEN
	./scripts/config --module CONFIG_NFT_CT
	./scripts/config --module CONFIG_NFT_CONNLIMIT
	./scripts/config --module CONFIG_NFT_LOG
	./scripts/config --module CONFIG_NFT_LIMIT
	./scripts/config --module CONFIG_NFT_MASQ
	./scripts/config --module CONFIG_NFT_REDIR
	./scripts/config --module CONFIG_NFT_NAT
	./scripts/config --module CONFIG_NFT_TUNNEL
	./scripts/config --module CONFIG_NFT_OBJREF
	./scripts/config --module CONFIG_NFT_QUEUE
	./scripts/config --module CONFIG_NFT_QUOTA
	./scripts/config --module CONFIG_NFT_REJECT
	./scripts/config --module CONFIG_NFT_COMPAT
	./scripts/config --module CONFIG_NFT_HASH
	./scripts/config --module CONFIG_NFT_FIB_INET
	./scripts/config --module CONFIG_NFT_XFRM
	./scripts/config --module CONFIG_NFT_SOCKET
	./scripts/config --module CONFIG_NFT_OSF
	./scripts/config --module CONFIG_NFT_TPROXY
	./scripts/config --module CONFIG_NFT_SYNPROXY
	./scripts/config --module CONFIG_NF_DUP_NETDEV
	./scripts/config --module CONFIG_NFT_DUP_NETDEV
	./scripts/config --module CONFIG_NFT_FWD_NETDEV
	./scripts/config --module CONFIG_NFT_FIB_NETDEV
	./scripts/config --module CONFIG_NF_FLOW_TABLE

	#
	# Xtables combined modules
	#
	./scripts/config --module CONFIG_NETFILTER_XT_MARK
	./scripts/config --module CONFIG_NETFILTER_XT_CONNMARK
	./scripts/config --module CONFIG_NETFILTER_XT_SET

	#
	# Xtables targets
	#
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_AUDIT
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_CHECKSUM
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_CLASSIFY
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_CONNMARK
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_CONNSECMARK
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_CT
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_DSCP
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_HL
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_HMARK
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_IDLETIMER
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_LOG
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_MARK
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_NETMAP
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_NFLOG
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_NFQUEUE
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_RATEEST
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_TEE
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_TPROXY
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_TRACE
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_SECMARK
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_TCPMSS
	./scripts/config --module CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP

	#
	# Xtables matches
	#
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_ADDRTYPE
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_BPF
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CGROUP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CLUSTER
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_COMMENT
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CONNBYTES
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CONNLABEL
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CONNLIMIT
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CONNMARK
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CONNTRACK
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_CPU
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_DCCP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_DEVGROUP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_DSCP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_ECN
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_ESP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_HASHLIMIT
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_HELPER
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_IPCOMP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_IPRANGE
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_IPVS
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_L2TP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_LENGTH
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_LIMIT
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_MAC
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_MARK
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_MULTIPORT
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_NFACCT
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_OSF
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_OWNER
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_POLICY
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_PHYSDEV
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_PKTTYPE
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_QUOTA
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_RATEEST
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_REALM
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_RECENT
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_SCTP
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_SOCKET
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_STATE
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_STATISTIC
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_STRING
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_TCPMSS
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_TIME
	./scripts/config --module CONFIG_NETFILTER_XT_MATCH_U32
	./scripts/config --module CONFIG_IP_SET
	./scripts/config --module CONFIG_IP_SET_BITMAP_IP
	./scripts/config --module CONFIG_IP_SET_BITMAP_IPMAC
	./scripts/config --module CONFIG_IP_SET_BITMAP_PORT
	./scripts/config --module CONFIG_IP_SET_HASH_IP
	./scripts/config --module CONFIG_IP_SET_HASH_IPMARK
	./scripts/config --module CONFIG_IP_SET_HASH_IPPORT
	./scripts/config --module CONFIG_IP_SET_HASH_IPPORTIP
	./scripts/config --module CONFIG_IP_SET_HASH_IPPORTNET
	./scripts/config --module CONFIG_IP_SET_HASH_IPMAC
	./scripts/config --module CONFIG_IP_SET_HASH_MAC
	./scripts/config --module CONFIG_IP_SET_HASH_NETPORTNET
	./scripts/config --module CONFIG_IP_SET_HASH_NET
	./scripts/config --module CONFIG_IP_SET_HASH_NETNET
	./scripts/config --module CONFIG_IP_SET_HASH_NETPORT
	./scripts/config --module CONFIG_IP_SET_HASH_NETIFACE
	./scripts/config --module CONFIG_IP_SET_LIST_SET
	./scripts/config --module CONFIG_IP_VS
	./scripts/config --enable CONFIG_IP_VS_IPV6

	#
	# IPVS transport protocol load balancing support
	#
	./scripts/config --enable CONFIG_IP_VS_PROTO_TCP
	./scripts/config --enable CONFIG_IP_VS_PROTO_UDP
	./scripts/config --enable CONFIG_IP_VS_PROTO_ESP
	./scripts/config --enable CONFIG_IP_VS_PROTO_AH
	./scripts/config --enable CONFIG_IP_VS_PROTO_SCTP

	#
	# IPVS scheduler
	#
	./scripts/config --module CONFIG_IP_VS_RR
	./scripts/config --module CONFIG_IP_VS_WRR
	./scripts/config --module CONFIG_IP_VS_LC
	./scripts/config --module CONFIG_IP_VS_WLC
	./scripts/config --module CONFIG_IP_VS_FO
	./scripts/config --module CONFIG_IP_VS_OVF
	./scripts/config --module CONFIG_IP_VS_LBLC
	./scripts/config --module CONFIG_IP_VS_LBLCR
	./scripts/config --module CONFIG_IP_VS_DH
	./scripts/config --module CONFIG_IP_VS_SH
	./scripts/config --module CONFIG_IP_VS_MH
	./scripts/config --module CONFIG_IP_VS_SED
	./scripts/config --module CONFIG_IP_VS_NQ

	#
	# IPVS application helper
	#
	./scripts/config --module CONFIG_IP_VS_FTP
	./scripts/config --enable CONFIG_IP_VS_NFCT
	./scripts/config --module CONFIG_IP_VS_PE_SIP

	#
	# IP: Netfilter Configuration
	#
	./scripts/config --module CONFIG_NF_SOCKET_IPV4
	./scripts/config --module CONFIG_NF_TPROXY_IPV4
	./scripts/config --module CONFIG_NFT_DUP_IPV4
	./scripts/config --module CONFIG_NFT_FIB_IPV4
	./scripts/config --enable CONFIG_NF_TABLES_ARP
	./scripts/config --module CONFIG_NF_LOG_ARP
	./scripts/config --module CONFIG_NF_LOG_IPV4
	./scripts/config --module CONFIG_NF_REJECT_IPV4
	./scripts/config --module CONFIG_IP_NF_MATCH_AH
	./scripts/config --module CONFIG_IP_NF_MATCH_ECN
	./scripts/config --module CONFIG_IP_NF_MATCH_RPFILTER
	./scripts/config --module CONFIG_IP_NF_MATCH_TTL
	./scripts/config --module CONFIG_IP_NF_FILTER
	./scripts/config --module CONFIG_IP_NF_TARGET_REJECT
	./scripts/config --module CONFIG_IP_NF_TARGET_SYNPROXY
	./scripts/config --module CONFIG_IP_NF_NAT
	./scripts/config --module CONFIG_IP_NF_TARGET_MASQUERADE
	./scripts/config --module CONFIG_IP_NF_TARGET_NETMAP
	./scripts/config --module CONFIG_IP_NF_TARGET_REDIRECT
	./scripts/config --module CONFIG_IP_NF_MANGLE
	./scripts/config --module CONFIG_IP_NF_TARGET_CLUSTERIP
	./scripts/config --module CONFIG_IP_NF_TARGET_ECN
	./scripts/config --module CONFIG_IP_NF_TARGET_TTL
	./scripts/config --module CONFIG_IP_NF_RAW
	./scripts/config --module CONFIG_IP_NF_SECURITY
	./scripts/config --module CONFIG_IP_NF_ARPTABLES
	./scripts/config --module CONFIG_IP_NF_ARPFILTER
	./scripts/config --module CONFIG_IP_NF_ARP_MANGLE

	#
	# IPv6: Netfilter Configuration
	#
	./scripts/config --module CONFIG_NF_SOCKET_IPV6
	./scripts/config --module CONFIG_NF_TPROXY_IPV6
	./scripts/config --module CONFIG_NFT_DUP_IPV6
	./scripts/config --module CONFIG_NFT_FIB_IPV6
	./scripts/config --module CONFIG_NF_REJECT_IPV6
	./scripts/config --module CONFIG_NF_LOG_IPV6
	./scripts/config --module CONFIG_IP6_NF_IPTABLES
	./scripts/config --module CONFIG_IP6_NF_MATCH_AH
	./scripts/config --module CONFIG_IP6_NF_MATCH_EUI64
	./scripts/config --module CONFIG_IP6_NF_MATCH_FRAG
	./scripts/config --module CONFIG_IP6_NF_MATCH_OPTS
	./scripts/config --module CONFIG_IP6_NF_MATCH_HL
	./scripts/config --module CONFIG_IP6_NF_MATCH_IPV6HEADER
	./scripts/config --module CONFIG_IP6_NF_MATCH_MH
	./scripts/config --module CONFIG_IP6_NF_MATCH_RPFILTER
	./scripts/config --module CONFIG_IP6_NF_MATCH_RT
	./scripts/config --module CONFIG_IP6_NF_MATCH_SRH
	./scripts/config --module CONFIG_IP6_NF_TARGET_HL
	./scripts/config --module CONFIG_IP6_NF_FILTER
	./scripts/config --module CONFIG_IP6_NF_TARGET_REJECT
	./scripts/config --module CONFIG_IP6_NF_TARGET_SYNPROXY
	./scripts/config --module CONFIG_IP6_NF_MANGLE
	./scripts/config --module CONFIG_IP6_NF_RAW
	./scripts/config --module CONFIG_IP6_NF_SECURITY
	./scripts/config --module CONFIG_IP6_NF_NAT
	./scripts/config --module CONFIG_IP6_NF_TARGET_MASQUERADE
	./scripts/config --module CONFIG_IP6_NF_TARGET_NPT
	./scripts/config --module CONFIG_NF_TABLES_BRIDGE
	./scripts/config --module CONFIG_NFT_BRIDGE_META
	./scripts/config --module CONFIG_NFT_BRIDGE_REJECT
	./scripts/config --module CONFIG_NF_LOG_BRIDGE
	./scripts/config --module CONFIG_NF_CONNTRACK_BRIDGE
	./scripts/config --module CONFIG_BRIDGE_NF_EBTABLES
	./scripts/config --module CONFIG_BRIDGE_EBT_BROUTE
	./scripts/config --module CONFIG_BRIDGE_EBT_T_FILTER
	./scripts/config --module CONFIG_BRIDGE_EBT_T_NAT
	./scripts/config --module CONFIG_BRIDGE_EBT_802_3
	./scripts/config --module CONFIG_BRIDGE_EBT_AMONG
	./scripts/config --module CONFIG_BRIDGE_EBT_ARP
	./scripts/config --module CONFIG_BRIDGE_EBT_IP
	./scripts/config --module CONFIG_BRIDGE_EBT_IP6
	./scripts/config --module CONFIG_BRIDGE_EBT_LIMIT
	./scripts/config --module CONFIG_BRIDGE_EBT_MARK
	./scripts/config --module CONFIG_BRIDGE_EBT_PKTTYPE
	./scripts/config --module CONFIG_BRIDGE_EBT_STP
	./scripts/config --module CONFIG_BRIDGE_EBT_VLAN
	./scripts/config --module CONFIG_BRIDGE_EBT_ARPREPLY
	./scripts/config --module CONFIG_BRIDGE_EBT_DNAT
	./scripts/config --module CONFIG_BRIDGE_EBT_MARK_T
	./scripts/config --module CONFIG_BRIDGE_EBT_REDIRECT
	./scripts/config --module CONFIG_BRIDGE_EBT_SNAT
	./scripts/config --module CONFIG_BRIDGE_EBT_LOG
	./scripts/config --module CONFIG_BRIDGE_EBT_NFLOG
	./scripts/config --module CONFIG_IP_DCCP
	./scripts/config --enable CONFIG_STP
	./scripts/config --module CONFIG_BRIDGE
	./scripts/config --enable CONFIG_BRIDGE_VLAN_FILTERING
	./scripts/config --module CONFIG_VLAN_8021Q
	./scripts/config --enable CONFIG_VLAN_8021Q_GVRP
	./scripts/config --enable CONFIG_VLAN_8021Q_MVRP
	./scripts/config --module CONFIG_LLC
	./scripts/config --module CONFIG_LLC2
	./scripts/config --enable CONFIG_NET_SCHED

	#
	# Queueing/Scheduling
	#
	./scripts/config --module CONFIG_NET_SCH_CBQ
	./scripts/config --module CONFIG_NET_SCH_HTB
	./scripts/config --module CONFIG_NET_SCH_HFSC
	./scripts/config --module CONFIG_NET_SCH_PRIO
	./scripts/config --module CONFIG_NET_SCH_MULTIQ
	./scripts/config --module CONFIG_NET_SCH_RED
	./scripts/config --module CONFIG_NET_SCH_SFB
	./scripts/config --module CONFIG_NET_SCH_SFQ
	./scripts/config --module CONFIG_NET_SCH_TEQL
	./scripts/config --module CONFIG_NET_SCH_TBF
	./scripts/config --module CONFIG_NET_SCH_CBS
	./scripts/config --module CONFIG_NET_SCH_ETF
	./scripts/config --module CONFIG_NET_SCH_TAPRIO
	./scripts/config --module CONFIG_NET_SCH_GRED
	./scripts/config --module CONFIG_NET_SCH_DSMARK
	./scripts/config --module CONFIG_NET_SCH_NETEM
	./scripts/config --module CONFIG_NET_SCH_DRR
	./scripts/config --module CONFIG_NET_SCH_MQPRIO
	./scripts/config --module CONFIG_NET_SCH_SKBPRIO
	./scripts/config --module CONFIG_NET_SCH_CHOKE
	./scripts/config --module CONFIG_NET_SCH_QFQ
	./scripts/config --module CONFIG_NET_SCH_CODEL
	./scripts/config --module CONFIG_NET_SCH_FQ_CODEL
	./scripts/config --module CONFIG_NET_SCH_CAKE
	./scripts/config --module CONFIG_NET_SCH_FQ
	./scripts/config --module CONFIG_NET_SCH_HHF
	./scripts/config --module CONFIG_NET_SCH_PIE
	./scripts/config --module CONFIG_NET_SCH_FQ_PIE
	./scripts/config --module CONFIG_NET_SCH_PLUG
	./scripts/config --module CONFIG_NET_SCH_ETS

	#
	# Classification
	#
	./scripts/config --module CONFIG_NET_CLS_BASIC
	./scripts/config --module CONFIG_NET_CLS_ROUTE4
	./scripts/config --module CONFIG_NET_CLS_FW
	./scripts/config --module CONFIG_NET_CLS_U32
	./scripts/config --enable CONFIG_CLS_U32_PERF
	./scripts/config --enable CONFIG_CLS_U32_MARK
	./scripts/config --module CONFIG_NET_CLS_RSVP
	./scripts/config --module CONFIG_NET_CLS_RSVP6
	./scripts/config --module CONFIG_NET_CLS_FLOW
	./scripts/config --enable CONFIG_NET_CLS_CGROUP
	./scripts/config --module CONFIG_NET_CLS_BPF
	./scripts/config --module CONFIG_NET_CLS_FLOWER
	./scripts/config --module CONFIG_NET_CLS_MATCHALL
	./scripts/config --enable CONFIG_NET_EMATCH
	./scripts/config --enable CONFIG_NET_CLS_ACT
	./scripts/config --enable CONFIG_CGROUP_NET_PRIO
	./scripts/config --enable CONFIG_VSOCKETS

	#
	# IEEE 1394 (FireWire) support
	#
	./scripts/config --module CONFIG_DUMMY
	./scripts/config --module CONFIG_WIREGUARD
	./scripts/config --module CONFIG_MACVLAN
	./scripts/config --module CONFIG_MACVTAP
	./scripts/config --module CONFIG_IPVLAN
	./scripts/config --module CONFIG_IPVTAP
	./scripts/config --module CONFIG_VXLAN
	./scripts/config --enable CONFIG_VETH
	./scripts/config --enable CONFIG_VIRTIO_NET

	./scripts/config --module CONFIG_OVERLAY_FS
	./scripts/config --module CONFIG_BTRFS_FS
	./scripts/config --enable CONFIG_BTRFS_FS_POSIX_ACL
	./scripts/config --disable CONFIG_RAID6_PQ_BENCHMARK

	./scripts/config --enable CONFIG_CRYPTO_AEAD
	./scripts/config --module CONFIG_CRYPTO_GCM
	./scripts/config --module CONFIG_CRYPTO_SEQIV
	./scripts/config --module CONFIG_CRYPTO_GHASH

	echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig"
	make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig
else
	echo "make ARCH=riscv CROSS_COMPILE=${CC} defconfig"
	make ARCH=riscv CROSS_COMPILE=${CC} defconfig

	./scripts/config --enable CONFIG_PCIE_MICROCHIP_HOST

	./scripts/config --enable CONFIG_OF_OVERLAY

	./scripts/config --enable CONFIG_I2C
	./scripts/config --enable CONFIG_EEPROM_AT24
	./scripts/config --enable CONFIG_I2C_MICROCHIP_CORE

	./scripts/config --enable CONFIG_SPI_MICROCHIP_CORE
	./scripts/config --enable CONFIG_SPI_MICROCHIP_CORE_QSPI
	./scripts/config --module CONFIG_SPI_SPIDEV

	./scripts/config --enable CONFIG_GPIO_SYSFS

	./scripts/config --enable CONFIG_HW_RANDOM_POLARFIRE_SOC

	./scripts/config --enable CONFIG_USB_MUSB_HDRC
	./scripts/config --enable CONFIG_NOP_USB_XCEIV
	./scripts/config --enable CONFIG_USB_MUSB_POLARFIRE_SOC
	./scripts/config --enable CONFIG_USB_MUSB_DUAL_ROLE

	./scripts/config --enable CONFIG_MAILBOX
	./scripts/config --enable CONFIG_POLARFIRE_SOC_MAILBOX
	./scripts/config --disable CONFIG_SUN6I_MSGBOX

	./scripts/config --enable CONFIG_REMOTEPROC
	./scripts/config --enable CONFIG_REMOTEPROC_CDEV

	./scripts/config --enable CONFIG_POLARFIRE_SOC_SYS_CTRL

	./scripts/config --enable CONFIG_USB_GADGET
	./scripts/config --enable CONFIG_USB_CONFIGFS
	./scripts/config --enable CONFIG_CONFIGFS_FS
	./scripts/config --enable CONFIG_USB_CONFIGFS_SERIAL
	./scripts/config --enable CONFIG_USB_CONFIGFS_ACM
	./scripts/config --enable CONFIG_USB_CONFIGFS_OBEX
	./scripts/config --enable CONFIG_USB_CONFIGFS_NCM
	./scripts/config --enable CONFIG_USB_CONFIGFS_ECM
	./scripts/config --enable CONFIG_USB_CONFIGFS_ECM_SUBSET
	./scripts/config --enable CONFIG_USB_CONFIGFS_RNDIS
	./scripts/config --enable CONFIG_USB_CONFIGFS_EEM
	./scripts/config --enable CONFIG_USB_CONFIGFS_PHONET
	./scripts/config --enable CONFIG_USB_CONFIGFS_MASS_STORAGE
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_LB_SS
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_FS
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC1
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UAC2
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_MIDI
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_HID
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_UVC
	./scripts/config --enable CONFIG_USB_CONFIGFS_F_PRINTER

	./scripts/config --module CONFIG_MEDIA_SUPPORT
	./scripts/config --enable CONFIG_MEDIA_SUPPORT_FILTER
	./scripts/config --enable CONFIG_MEDIA_SUBDRV_AUTOSELECT
	./scripts/config --enable CONFIG_MEDIA_CAMERA_SUPPORT
	./scripts/config --module CONFIG_VIDEO_IMX219

	./scripts/config --module CONFIG_IIO

	#Cleanup large DRM...
	./scripts/config --disable CONFIG_DRM
	./scripts/config --disable CONFIG_DRM_RADEON
	./scripts/config --disable CONFIG_DRM_NOUVEAU
	./scripts/config --disable CONFIG_DRM_SUN4I

	#Optimize:
	./scripts/config --enable CONFIG_IP_NF_IPTABLES
	./scripts/config --enable CONFIG_NETFILTER_XTABLES
	./scripts/config --enable CONFIG_NLS_ISO8859_1
	./scripts/config --enable CONFIG_BLK_DEV_DM

	echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig"
	make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} olddefconfig
fi

echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

if [ ! -f ./arch/riscv/boot/Image ] ; then
	echo "Build Failed"
	exit 2
fi

KERNEL_UTS=$(cat "${wdir}/linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

if [ -d "${wdir}/deploy/tmp/" ] ; then
	rm -rf "${wdir}/deploy/tmp/"
fi
mkdir -p "${wdir}/deploy/tmp/"

make -s ARCH=riscv CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH="${wdir}/deploy/tmp"

if [ -f "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" ] ; then
	rm -rf "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" || true
fi
echo "Compressing ${KERNEL_UTS}-modules.tar.gz..."
echo "${KERNEL_UTS}" > "${wdir}/deploy/.modules"
cd "${wdir}/deploy/tmp" || true
tar --create --gzip --file "../${KERNEL_UTS}-modules.tar.gz" ./*
cd "${wdir}/linux/" || exit
rm -rf "${wdir}/deploy/tmp" || true

if [ -f arch/riscv/configs/mpfs_defconfig ] ; then
	cp -v ./.config ../patches/linux/mpfs_defconfig
	cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire.dts ../patches/linux/dts/mpfs-beaglev-fire.dts
	cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire-fabric.dtsi ../patches/linux/dts/mpfs-beaglev-fire-fabric.dtsi
else
	cp -v ./.config ../patches/linux/mainline/defconfig
	cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire.dts ../patches/linux/mainline/dts/mpfs-beaglev-fire.dts
	cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire-fabric.dtsi ../patches/linux/mainline/dts/mpfs-beaglev-fire-fabric.dtsi
fi
if [ ! -d ../deploy/input/ ] ; then
	mkdir -p ../deploy/input/ || true
fi
cp -v ./arch/riscv/boot/Image ../deploy/input/
cp -v ./arch/riscv/boot/dts/microchip/mpfs-beaglev-fire.dtb ../deploy/input/

cd ../

cp -v ./patches/linux/beaglev_fire.its ./deploy/input/
cd ./deploy/input/
gzip -9 Image -c > Image.gz
if [ -f ../../u-boot/tools/mkimage ] ; then
	../../u-boot/tools/mkimage -f beaglev_fire.its beaglev_fire.itb
fi
#
