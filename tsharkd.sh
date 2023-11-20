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


case $1 in

        start)

        procs=""

        for i in $INTERFACES
        do
                echo $i
                nohup ${TSHRKCMD} -i $i -b "duration:3600" -b "files:24" -w /opt/SnifferSnapShot-$i.pcap  -f "${FILTER}"  2>&1 &
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

        dryrun)

                dry_run
                ;;
        clean)
                clean_all
                ;;
        *)

                echo -e " $0 <start|stop|restart|status|dryrun|clean>"
                ;;

esac
