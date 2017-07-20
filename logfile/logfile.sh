#!/bin/bash
#
##########################################################################################
# YOU MUST KEYIN SOME PARAMETERS HERE!!
# 底下的资料是您必须要填写的！
email=""		# logfile 寄给的 e-mail 地址
				                # 可以使用底下的格式寄给多个 e-mail 地址：
				                # email="root@localhost,yourID@hostname"
				                # 每个 email 用逗号，不要加空格！

basedir="/home/hazza/logfile"	# logfile.sh 放置的目录
funcdir="/home/hazza/logfile"

outputall="yes"		# 是否要将所有的登录档內容都打印出來？
			        # 对于一般新手而言，只要看汇总的内容即可，
			        # 所以这里选择 "no" ，如果想要知道所有的登录信息，则可以设定为 "yes" 

##########################################################################################
# 底下的代码不需要更改，如果有其他的额外要求，可以进行进一步的修改
export email basedir outputall funcdir
[ ! -d $basedir ] && mkdir $basedir


##########################################################################################
# 0. 检查basedir 是否存在
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
#LANG=en_US.UTF-8
LANG=C  # LANG=C是最早最简单的C语言环境（标准ASCII码）
export PATH LANG LANGUAGE LC_TIME
localhostname=$(hostname)

# 修改使用者邮件位址！
temp=$(echo $email | cut -d '@' -f2)
if [ "$temp" == "localhost" ]; then
	email=$(echo $email | cut -d '@' -f1)\@"$localhostname"
fi

# 测验 awk,sed,egrep等会使用到的命令是否存在
errormesg=""
programs="awk sed egrep ps cat cut tee netstat df uptime journalctl"
for profile in $programs
do
	which $profile > /dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo -e "您的系统沒有包含 $profile 命令；(Your system do not have $profile )"
		errormesg="yes"
	fi
done
if [ "$errormesg" == "yes" ]; then
	echo "您的系统缺乏本程序执行所需要的系統命令， $0 将停止工作"
	exit 1
fi

# 检测 syslog 是否有启动！
temp=$(ps -aux 2> /dev/null | grep systemd-journal | grep -v grep)
if [ "$temp" == "" ]; then
	echo -e "您的系系统沒有启动 systemd-journald 这个 daemon ，"
	echo -e "本程序主要针对 systemd-journald 产生的 logfile 來分析，"
	echo -e "因此，沒有 systemd-journald 则本程序无法执行。"
	exit 0
fi

# 检测暂存目录是否存在！
if [ ! -d "$basedir" ]; then
	echo -e "$basedir 此目录不存在，本程序 $0 无法工作！"
	exit 1
fi


##########################################################################################
# 0.1 设定版本资料，以及相关的 log files 內容表格！
lastdate="2017-07-7"
versions="Version 0.1"
hosthome=$(hostname)
logfile="$basedir/logfile_mail.txt"
declare -i datenu=$(date +%k)
if [ "$datenu" -le "6" ]; then
	date --date='1 day ago' +%b' '%e   > "$basedir/dattime"
	date --date='1 day ago' +%Y-%m-%d  > "$basedir/dattime2"
else
	date +%b' '%e   > "$basedir/dattime"
	date +%Y-%m-%d  > "$basedir/dattime2"
fi
y="`cat $basedir/dattime`"
y2="`cat $basedir/dattime2`"
export lastdate hosthome logfile y

# 0.1.1 secure file
log=$(journalctl SYSLOG_FACILITY=4 SYSLOG_FACILITY=10 --since yesterday --until today | grep -v "^\-\-")
if [ "$log" != "" ]; then
	journalctl SYSLOG_FACILITY=4 SYSLOG_FACILITY=10 --since yesterday --until today | grep -v "^\-\-" > "$basedir/securelog"
fi

# 0.1.2 maillog file
log=$(journalctl SYSLOG_FACILITY=2 --since yesterday --until today | grep -v "^\-\-")
if [ "$log" != "" ]; then
	journalctl SYSLOG_FACILITY=2 --since yesterday --until today | grep -v "^\-\-" > "$basedir/maillog"
fi

# 0.1.3 messages file
journalctl SYSLOG_FACILITY=0 SYSLOG_FACILITY=1 SYSLOG_FACILITY=3 SYSLOG_FACILITY=5 \
      SYSLOG_FACILITY=6 SYSLOG_FACILITY=7 SYSLOG_FACILITY=8 SYSLOG_FACILITY=11 SYSLOG_FACILITY=16 \
      SYSLOG_FACILITY=17 SYSLOG_FACILITY=18 SYSLOG_FACILITY=19 SYSLOG_FACILITY=20 SYSLOG_FACILITY=21 \
      SYSLOG_FACILITY=22 SYSLOG_FACILITY=23 --since yesterday --until today | grep -v "^\-\-" > "$basedir/messageslog"
touch "$basedir/securelog"
touch "$basedir/maillog"
touch "$basedir/messageslog"

# The following lines are detecting your PC live?
  timeset1=`uptime | grep day`
  timeset2=`uptime | grep min`
  if [ "$timeset1" == "" ]; then
        if [ "$timeset2" == "" ]; then
                UPtime=`uptime | awk '{print $3}' | sed 's/,//g'`
        else
                UPtime=`uptime | awk '{print $3 " " $4}' | sed 's/,//g'`
        fi
  else
        if [ "$timeset2" == "" ]; then
                UPtime=`uptime | awk '{print $3 " " $4 " " $5}' | sed 's/,//g'`
        else
                UPtime=`uptime | awk '{print $3 " " $4 " " $5 " " $6}' | sed 's/,//g'`
        fi
  fi

# 显示ip
IPs=$(echo $(ifconfig | grep 'inet '| awk '{print $2}' | grep -v '127.0.0.'))


##########################################################################################
# 1. 建立欢迎画面通知，以及系统的资料整理！
echo "" > $logfile
/sbin/restorecon -Rv $logfile
echo "=============== system summary =================================" >> $logfile
echo "Linux kernel  :  $(cat /proc/version | \
	awk '{print $1 " " $2 " " $3 " " $4}')" 			>> $logfile
echo "CPU informatin: $(cat /proc/cpuinfo |grep 'model name' | sed 's/model name.*://' | \
	uniq -c | sed 's/[[:space:]][[:space:]]*/ /g')"			>> $logfile
echo "CPU speed     : $( cat /proc/cpuinfo | grep "cpu MHz" | \
	sort | tail -n 1 | cut -d ':' -f2-) MHz" 			>> $logfile
echo "hostname is   :  $(hostname)" 					>> $logfile
echo "Network IP    :  ${IPs}"						>> $logfile
echo "Check time    :  $(date +%Y/%B/%d' '%H:%M:%S' '\(' '%A' '\))" 	>> $logfile
echo "Summary date  :  $(cat $basedir/dattime)"				>> $logfile
echo "Up times      :  $(echo $UPtime)" 				>> $logfile
echo "Filesystem summary: "						>> $logfile
df -Th	| sed 's/^/       /'				>> $logfile
if [ -x /opt/MegaRAID/MegaCli/MegaCli64 ]; then
	cd /root
	echo 								>> $logfile
	echo "Test the RAID card Volumes informations:"			>> $logfile
	/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -LALL -aAll | \
	grep -E '^Name|^Size|^State'					>> $logfile
	echo 								>> $logfile
	echo "Test RAID devices"					>> $logfile
	/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aAll | \
	grep -E '^Firmware|^Slot|^Media Error|^Other Error'		>> $logfile
	cd -
fi
echo " "						>> $logfile
echo " "						>> $logfile

# 1.1 Port 分析
if [ -f $funcdir/function/ports ]; then
	source $funcdir/function/ports
fi


##########################################################################################
# 2 开始测试需要进行的命令
# 2.1 测试 ssh 是否存在？
input=`cat $basedir/netstat.tcp.output |egrep '(22|sshd)'`
if [ "$input" != "" ]; then
	source $funcdir/function/ssh
	funcssh
	echo " "	>> $logfile
fi

# 2.2 测试 FTP 是否存在 
input=`cat $basedir/netstat.tcp.output |egrep '(21|ftp)'`
if [ "$input" != "" ]; then
	if [ -f /etc/ftpaccess ]; then
		source $funcdir/function/wuftp
		funcwuftp
	fi
	proftppro=`which proftpd 2> /dev/null`
	if [ "$proftppro" != "" ]; then
		source $funcdir/function/proftp
		funcproftp
	fi
fi

# 2.3 pop3 测试
input=`cat $basedir/netstat.tcp.output |grep 110`
if [ "$input" != "" ]; then
	dovecot=`cat $basedir/netstat.tcp.output | grep dovecot`
	if [ "$dovecot" != "" ]; then
		source $funcdir/function/dovecot
		funcdovecot
		echo " " >> $logfile
	else
		source $funcdir/function/pop3
		funcpop3
		echo " "	>> $logfile
	fi
fi

# 2.4 Mail 测试
input=`cat $basedir/netstat.tcp.output $basedir/netstat.tcp.local 2> /dev/null |grep 25`
if [ "$input" != "" ]; then
	postfixtest=`netstat -tlnp 2> /dev/null |grep ':25'|grep master`
	#sendmailtest=`ps -aux 2> /dev/null |grep sendmail| grep -v 'grep'`
	if [ "$postfixtest" != "" ] ;  then
		source $funcdir/function/postfix
		funcpost
	else
		source $funcdir/function/sendmail
		funcsendmail
	fi
	procmail=`/bin/ls /var/log| grep procmail| head -n 1`
	if [ "$procmail" != "" ] ; then
		source $funcdir/function/procmail
		funcprocmail
	fi

	openwebmail=`ls /var/log | grep openwebmail | head -n 1`
	if [ "$openwebmail" != "" ]; then
		source $funcdir/function/openwebmail
		funcopenwebmail
	fi
fi

# 2.5 samba 测试
input=`cat $basedir/netstat.tcp.output  2> /dev/null |grep 139|grep smbd`
if [ "$input" != "" ]; then
	source $funcdir/function/samba
	funcsamba
fi

#####################################################################
# 10. 列出全部资讯 
if [ "$outputall" == "yes" ] || [ "$outputall" == "YES" ] ; then
	echo "  "                                  				>> $logfile
	echo "================= 全部的登录档咨询汇整 ======================="	>> $logfile
	echo "1. 重要的登录记录档 ( Secure file )"           >> $logfile
	echo "   说明：已经取消了 pop3 的咨询！"	     >> $logfile
	grep -v 'pop3' $basedir/securelog 		     >> $logfile 
	echo " "                                             >> $logfile
	echo "2. 使用 last 这个指令输出的结果"               >> $logfile
	last -20                                             >> $logfile
	echo " "                                             >> $logfile
	echo "3. 列出重要的 /var/log/messages"  >> $logfile
	cat $basedir/messageslog 			     >> $logfile
	echo " "					     >> $logfile
	if [ -f /var/log/knockd.log ]; then
		echo "4. 开始分析 knockd 这个服务的相关资料" >> $logfile
		echo "4.1 正常登入主机的指令运作"	     >> $logfile
		grep "$y2" /var/log/knockd.log | grep 'iptables'     >> $logfile
		echo ""
		echo "4.2 因为某些原因，导致无法登入的 IP 与状态！"  >> $logfile
		grep "$y2" /var/log/knockd.log | grep 'sequence timeout' >> $logfile
	fi
fi

# At last! we send this mail to you!
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
if [ -x /usr/bin/uuencode ]; then
	uuencode $logfile logfile.html | mail -s "$hosthome logfile analysis results" $email 
else
	mail -s "$hosthome logfile analysis results" $email < $logfile
fi

