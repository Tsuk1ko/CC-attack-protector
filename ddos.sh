#!/bin/bash
#配置
LOG_FILES="/www/wwwlogs/*.moe.log"
LIMIT_MAX_TIMES=300
LIMIT_TIMES=25
LIMIT_MAX_SIZE=52428800    #50MiB
SCKEY=""

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
    #当前行IP访问量
    CUR_TIMES=`echo $LIST_LINE | awk '{print $1}'`
    #如果访问量大于设定最大量直接Ban
    if [ $CUR_TIMES -ge $LIMIT_MAX_TIMES ]; then
        echo $LIST_LINE  | awk '{print $2}' >> $TMP_LIST
    #如果访问量大于设定次大量则判断流量
    elif [ $CUR_TIMES -ge $LIMIT_TIMES ]; then
        TOTAL_FLOW=0
        #某IP的单条流量记录
        for LINE_LOG_FLOW in `grep -h $LIST_LINE $TMP_LOG | awk '{print $10}'`
        do
            TOTAL_FLOW=$((TOTAL_FLOW+LINE_LOG_FLOW))
        done
        #如果流量大于设定的最大流量值则Ban
        if [ $TOTAL_FLOW -ge $LIMIT_MAX_SIZE ]; then
            echo $LIST_LINE  | awk '{print $2}' >> $TMP_LIST
        fi
    fi
done
IFS=$IFS_old

#Ban他妈的
TIME_FLAG=1
if [ -n "`cat $TMP_LIST`" ]; then
    PWDIR="$( cd "$( dirname "$0" )" && pwd )"
    IP_LIST="";
    for TMP_LINE in `cat $TMP_LIST`
    do
        TEST_R=`iptables -L INPUT -n --line-numbers | grep 'DROP' | grep "$TMP_LINE"`
        if [ -z "$TEST_R" ]; then
            if [ $TIME_FLAG -eq 1 ]; then
                echo -e "\033[033m`date`\033[0m"
                TIME_FLAG=0
            fi
            bash "$PWDIR"/ban.sh -b $TMP_LINE
            IP_LIST=%{IP_LIST}" $TMP_LINE"
        fi
    done
    if [ -n "$SCKEY" ]; then
    	curl -d "text=CC攻击警报&desp=$IP_LIST" "https://sc.ftqq.com/$SCKEY.send"
    fi
fi

#删除临时文件
rm $TMP_IP_LIST
rm $TMP_LOG
rm $TMP_LIST