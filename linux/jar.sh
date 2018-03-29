#!/bin/bash
currenttime=$(date +%Y%m%d%H%M%S)
logfile="$1_${currenttime}.log"
jarfile="$1.jar"
command="java -Duser.timezone=Asia/Shanghai -Djava.security.egd=file:/dev/./urandom -Xms128m -Xmx512m -jar ${jarfile}"
 
start(){
    echo "INFO: Starting $jarfile ..."
    if [ "$logfile" != "" ]; then
        exec nohup $command > $logfile 2>&1 &
    else
        exec nohup $command &
    fi
    if [ "$1" == "nlog" ]; then
      echo "INFO: $jarfile started!"
      sleep 1
      echo "INFO: view process(name=$command) info ..."
      ps -ef | grep "$command"
      exit
    else
      echo "INFO: view $logfile ..."
      tail -f $logfile
    fi
}
 
stop(){  
 echo "INFO: stopping $jarfile ..."
 ps -ef | grep "$command" | awk '{print $2}' | while read pid  
 do 
    C_PID=$(ps --no-heading $pid | wc -l)
    if [ "$C_PID" == "1" ]; then
        kill -9 $pid
        echo "INFO: process(PID=$pid) end!"
    else  
 		    echo "WARN: process(PID=$pid) does not exist!"
    fi 
 done
 echo "INFO: $jarfile stopped!"
}

if [ $# == 0 ]; then
    echo 'ERROR: Invalid Parameter!'    
elif [ -f "$jarfile" ]; then
    if [ $# == 2 ] && [ "$2" == "nlog" ] || [ $# == 1 ]; then
		    stop  
		    start $2
    elif [ $# == 2 ] && [ "$2" == "stop" ]; then
        stop
        exit
    else
        echo 'ERROR: Invalid Parameter!'
    fi
else
    echo "ERROR: $jarfile does not exist!"
fi
echo 'Usage: jar.sh JAR_PREFIX [OPTION]'
echo '    JAR_PREFIX    jar file name prefix’
echo '    OPTION    stop or nlog'
echo 'Examples:'
echo '    jar.sh paas-bpm         --start or restart paas-bpm.jar, display log'
echo '    jar.sh paas-bpm nlog    --start or restart paas-bpm.jar, no display log'
echo '    jar.sh paas-bpm stop    --stop paas-bpm.jar’
