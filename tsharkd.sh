#!/bin/bash

FILTER='tcp port 80 or tcp port 8080 or udp port 53'
INTERFACES="eth0"
PIDDIR="/var/run/"
PIDFILE="tsharkd.pid"
STORAGEDIR="/opt/"
FILEPATTERN="SnifferSnapShot-"
TSHRKCMD="/usr/bin/tshark"

function clean_all(){

  x=`find ${STORAGEDIR} -maxdepth 1 -name '*.pcap'  -type f -print`

  for i in $x
    do
        rm -f $i
  done
}

function dry_run(){
        echo "cntl -c to stop... "
        echo ${TSHRKCMD} -i ${INTERFACES} -f "${FILTER}"
        ${TSHRKCMD} -i ${INTERFACES} -f "${FILTER}"
}

function help(){

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

	p=`cat ${PIDDIR}${PIDFILE}`

	for i in $p 
	do 
		echo $i 
	done
}


case $1 in

        start)

        procs=""

        for i in $INTERFACES
        do
                echo $i
                nohup ${TSHRKCMD} -i $i -b "duration:3600" -b "files:24" -w /opt/SnifferSnapShot-${i}.pcap  -f "${FILTER}"  2>&1 &
                procs=" $procs $!"
        done
        echo $procs > ${PIDDIR}${PIDFILE}

        ;;

        stop)
                PIDS=`cat /var/run/$PIDFILE`

                for i in $PIDS
                do
                        kill $i
                done
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
		help
		;;
        *)
                echo -e " $0 <help|start|stop|restart|status|dryrun|clean>"
                ;;

esac
