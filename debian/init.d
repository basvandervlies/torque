#!/bin/sh
#set -x
#
# Start stop script for TORQUE
#
# Authors : Bas van der Vlies & Jaap Dijkshoorn
#	    Kilian Cavalotti
#
# SVN INFO:
#       $Id: init.d 77 2012-10-02 12:04:31Z bas $
#		$URL: https://oss.trac.surfsara.nl/torque_2_deb/svn/trunk/init.d $
#
### BEGIN INIT INFO
# Provides:          torque
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       pbs_mon, pbs_sched and pbs_server
### END INIT INFO
#
DESC="TORQUE servers"
TORQUE_DIR=/usr/sbin
DEFAULT=/etc/default/torque
SPOOLDIR=/var/spool/torque

# Some useful defaults can be overriden in the DEFAULT file
#
PBS_MOM_RESTART_OPTS='-p'
PBS_MOM_OPTS=''
PBS_SCHED_OPTS=''
PBS_SERVER_OPTS='-a t'
PBS_TRQAUTH_OPTS=""

if [ ! -f $DEFAULT ]
then
        echo "No file [$DEFAULT]"
        exit 0
fi
. $DEFAULT

## Start functions
start_server() {
        start-stop-daemon --start --quiet --exec $TORQUE_DIR/pbs_server -- $PBS_SERVER_OPTS
        echo "start pbs server"
}

start_sched() {
        start-stop-daemon --start --quiet --exec $TORQUE_DIR/pbs_sched -- $PBS_SCHED_OPTS
        echo "start pbs sched"
}

start_mom() {
        start-stop-daemon --start --quiet --exec $TORQUE_DIR/pbs_mom -- $PBS_MOM_OPTS
        echo "start pbs mom"
}

start_trqauth() {
        start-stop-daemon --start --quiet --background --exec $TORQUE_DIR/trqauthd -- $PBS_TRQAUTH_OPTS
        echo "start pbs trqauth"
}

start_daemons() {
    check_perms 

    ## Always start trqauth daemon
    #
    start_trqauth

    if [ "$PBS_SERVER" = "1" ] 
    then
        start_server
    fi 
        
    if [ "$PBS_SCHED" = "1" ]
    then
        start_sched
    fi 
        
   if [ "$PBS_MOM" = "1" ]
   then
        start_mom
   fi
}

## Stop functions

stop_server() {
        start-stop-daemon --retry 5 --stop --quiet --exec $TORQUE_DIR/pbs_server
        echo " stop pbs server"
        echo " waiting for server to shutdown"
        sleep 5
}

stop_sched() {
        start-stop-daemon --retry 5 --stop --quiet --exec $TORQUE_DIR/pbs_sched
        echo "stop pbs sched"
}

stop_mom() {
        start-stop-daemon --retry 5 --stop --quiet --exec $TORQUE_DIR/pbs_mom
        echo "stop pbs mom"
}

stop_trqauth() {
        start-stop-daemon --retry 5 --stop --quiet --exec $TORQUE_DIR/trqauthd
        echo "stop pbs trqauth"
}

stop_daemons() {
        if [ "$PBS_SERVER" = "1" ]
        then
                stop_server
        fi 
        
        if [ "$PBS_SCHED" = "1" ]
        then
                stop_sched
        fi 
        
        if [ "$PBS_MOM" = "1" ]
        then
                stop_mom
        fi

        stop_trqauth
}

## Check permissions and directories
check_perms() {

    check_dir() {
        if [ ! -d "$1" ]; then
            mkdir -m 1777 "$1"
        else
            chmod 1777 "$1"
        fi
    }

    check_dir $SPOOLDIR/spool
    check_dir $SPOOLDIR/undelivered
}


## Main
case "$1" in
        start)
                echo "Starting $DESC: "
                start_daemons
        ;;

        stop)
                echo "Stopping $DESC: "
                stop_daemons
        ;;

        restart)
                echo "Restarting $DESC: "
                stop_daemons
                sleep 1
                PBS_MOM_OPTS="$PBS_MOM_RESTART_OPTS"
                start_daemons
        ;;

        stop-mom)
                echo "Stopping pbs_mom: "
                stop_mom 
        ;;

        stop-sched)
                echo "Stopping pbs_sched: "
                stop_sched
        ;;

        stop-server)
                echo "Stopping pbs_mom: "
                stop_server
        ;;

        stop-trqauth)
                echo "Stopping pbs trqauthr: "
                stop_trqauth
        ;;

        restart-mom)
                echo "Restarting pbs_mom: "
                stop_mom 
                sleep 1 
                PBS_MOM_OPTS="$PBS_MOM_RESTART_OPTS"
                start_mom
        ;;

        restart-sched)
                echo "Restarting pbs_sched: " 
                stop_sched 
                sleep 1
                start_sched
        ;;


        restart-server)
                echo "Restarting pbs_server: "
                stop_server
                sleep 1
                start_server
        ;;

        restart-trqauth)
                echo "Restarting pbs trqauthr: "
                stop_trqauth
                sleep 1
                start_trqauth
        ;;

        *)
                echo "Usage: $0 restart|start|stop|restart-<mom|server|sched|trqauth>|stop_<mom|server|sched|trqauth>"
                exit 1
        ;;
esac

exit 0
