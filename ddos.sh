#!/bin/bash
#配置
LOG_FILES="/www/wwwlogs/*.log"	#指定日志文件
SCKEY=""	#Server酱服务的SCKEY，用于通知CC攻击情况，https://sc.ftqq.com
LIMIT_REPEAT=20		#重复的请求次数，超过直接封
LIMIT_TIMES=50		#否则，在10秒内超过这么多连接日志数的会进入检测，并且满足下面这个条件的会被封禁
LIMIT_FLOW=62914560	#请求大小之和 62914560 = 60MiB


#开始
#取得当前时间的10秒前（舍去秒个位）
NOW_DATE=`date +"%d/%h/20%y:%T" -d "10 second ago" | head -c -2`

#临时文件
TMP_LOG=`mktemp`
TMP_IP_LIST=`mktemp`
TMP_LIST=`mktemp`

#得到部分日志
grep -h "$NOW_DATE" $LOG_FILES > $TMP_LOG
#得到IP访问量排序
grep -h "$NOW_DATE" $TMP_LOG | awk '{print $1}' | sort | uniq -c | sort -nr > $TMP_IP_LIST
#得到IP访问数据总大小'
IFS_old=$IFS
IFS=$'\n'
for LIST_LINE in `cat $TMP_IP_LIST`
do
	CUR_TIMES=`echo $LIST_LINE | awk '{print $1}'`
	CUR_IP=`echo $LIST_LINE | awk '{print $2}'`
	#判断重复请求次数
	CUR_REPEAT=`grep -h $CUR_IP $TMP_LOG | awk '{print $7}' | sort | uniq -c | sort -nr | head -1 | awk '{print $1}'`
	if [ $CUR_REPEAT -ge $LIMIT_REPEAT ]; then
		echo "$CUR_IP REPEAT:$CUR_REPEAT>=$LIMIT_REPEAT" >> $TMP_LIST
	#判断访问量
	elif [ $CUR_TIMES -ge $LIMIT_TIMES ]; then
		TOTAL_FLOW=0
		#某IP的单条流量记录
		for LINE_LOG_FLOW in `grep -h $CUR_IP $TMP_LOG | awk '{print $10}'`
		do
			TOTAL_FLOW=$((TOTAL_FLOW+LINE_LOG_FLOW))
		done
		#如果流量大于设定的最大流量值则Ban
		if [ $TOTAL_FLOW -ge $LIMIT_FLOW ]; then
			echo "$CUR_IP FLOW:$TOTAL_FLOW>=$LIMIT_FLOW" >> $TMP_LIST
		fi
	fi
done

#Ban他妈的
TIME_FLAG=1
if [ -n "`cat $TMP_LIST`" ]; then
	PWDIR="$( cd "$( dirname "$0" )" && pwd )"
	IP_LIST="";
	for TMP_LINE in `cat $TMP_LIST`
	do
		TMP_IP=`echo $TMP_LINE | awk '{print $1}'`
		TMP_REASON=`echo $TMP_LINE | awk '{print $2}'`
		TEST_R=`iptables -L INPUT -n --line-numbers | grep 'DROP' | grep "$TMP_LINE"`
		if [ -z "$TEST_R" ]; then
			if [ $TIME_FLAG -eq 1 ]; then
				echo -e "\033[033m`date`\033[0m"
				date >> "$PWDIR"/cc.log
				TIME_FLAG=0
			fi
			bash "$PWDIR"/ban.sh -b $TMP_IP $TMP_REASON &
			echo "Ban $TMP_IP because $TMP_REASON" >> "$PWDIR"/cc.log
			IP_LIST=${IP_LIST}"$TMP_IP "
		fi
	done
	if [ -n "$SCKEY" ]; then
		curl -d "text=CC攻击警报&desp=$IP_LIST" "https://sc.ftqq.com/$SCKEY.send" >& /dev/null &
	fi
fi
IFS=$IFS_old

#删除临时文件
rm $TMP_IP_LIST
rm $TMP_LOG
rm $TMP_LIST