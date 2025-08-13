#!/bin/bash

FILTER='tcp port 443'
INTERFACES="wlo1"
PIDDIR="/var/run/"
PIDFILE="tsharkd.pid"
STORAGEDIR="/opt/"
FILEPATTERN="SnifferSnapShot-"
TSHRKCMD="/usr/bin/tshark"

function clean_all(){

  local x i 
  x=`find ${STORAGEDIR} -maxdepth 1 -name "${FILEPATTERN}*.pcap" -type f -print`

  for i in $x
    do
	echo -ne "Removing file ${i} ...\n"
        rm -f "$i"
  done
}

function dry_run(){
        echo "cntl -c to stop... "
        echo ${TSHRKCMD} -i ${INTERFACES} -f "${FILTER}"
        ${TSHRKCMD} -i ${INTERFACES} -f "${FILTER}"
}

function do_help(){

	local cmd
	cmd=`basename $0`

	echo -ne "\n\n"
	echo -ne " ${cmd}: \n"
	echo -ne "\n"
	echo -ne "\tThis script will run a rotating backgrounded tshark trace to capture \n"
	echo -ne "\tnetwork events for later analysis.\n"
	echo -ne "\t\n"
	echo -ne "\ttarget commands:\n\n"
	echo -ne "\thelp: this message\n\n"
	echo -ne "\tstart: runs the current invocation in the backgroun\n\n"
	echo -ne "\tstop:  stops the current invocation\n\n"
	echo -ne "\trestart: runs the current invocation in the backgroun\n\n"
	echo -ne "\tstatus: print some details about the running job\n\n"
	echo -ne "\tdryrun: run the tshark command interactively as a test\n\n"
	echo -ne "\tclean: clean the pcap files in the configured storage directory: $STORAGEDIR\n\n"
	echo -ne "\t\n"
	echo -ne "\t\n"
	echo -ne "\t\n"
	echo -ne "\t\n"

}

function get_status(){

	if [[ ! -e "${PIDDIR}${PIDFILE}" ]]; then 
		echo -e " Does not appear that there is a file: ${PIDDIR}${PIDFILE}"
		return 
	fi

	local p i process check
	p=`cat ${PIDDIR}${PIDFILE}`

       for i in $p 
       do 
	       process=`ps -p ${i} -fh `
	       #echo $process 
	       check=`echo $process | awk '{print $5}'`
	       #echo $check 
	       if [[ "$check" == "$TSHRKCMD" ]]; then 
		       echo " Process ID ${i} is $check and RUNNING "
	       else 
		       echo " Process ID ${i} is $check and is NOT A TSHARK INSTANCE"
	       fi

       done
}

function do_kill(){

	if [[ ! -e "${PIDDIR}${PIDFILE}" ]]; then 
		echo -e " Does not appear that there is a file: ${PIDDIR}${PIDFILE}"
		return 
	fi

	local p i process check
	p=`cat ${PIDDIR}${PIDFILE}`

       for i in $p 
       do 
	       process=`ps -p ${i} -fh `
	       #echo $process 
	       check=`echo $process | awk '{print $5}'`
	       #echo $check 
	       if [[ "$check" == "$TSHRKCMD" ]]; then 
		       echo " Killing process ID ${i}"
		       kill ${i}
	       else 
		       echo " Process ID ${i} is $check and is NOT A TSHARK INSTANCE"
	       fi
       done
	rm -f ${PIDDIR}${PIDFILE} 
}


function do_start(){

        local procs i procs
	local procs i
	procs=" "

	for i in $INTERFACES
	do
		echo $i
		nohup ${TSHRKCMD} -i $i -b "duration:3600" -b "files:24" -w /opt/SnifferSnapShot-${i}.pcap  -f "${FILTER}"  2>&1 &
		procs=" $procs $!"
	done
	echo $procs >> ${PIDDIR}${PIDFILE}
}


case $1 in

        start)
		do_start
        	;;

        stop)
		do_kill
                ;;

        restart)
                $0 stop
                $0 start
                ;;

	status) 
		get_status 
		;;

        dryrun)
                dry_run
                ;;
        clean)
                clean_all
                ;;
	help)
		do_help
		;;
        *)
                echo -e " $0 <help|start|stop|restart|status|dryrun|clean>"
                ;;

esac
