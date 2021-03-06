#! /bin/sh
### BEGIN INIT INFO
# Provides:          skeleton
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Example initscript
# Description:       This file should be used to construct scripts to be
#                    placed in /etc/init.d.
### END INIT INFO

# Author: Foo Bar <foobar@baz.org>
#
# Please remove the "Author" lines above and replace them
# with your own name if you copy and modify this script.

# Do NOT "set -e"

#rails config
#BUNDLE_PATH=/home/kyon2326/.rbenv/shims/bundle
BUNDLE_PATH=/home/kyon2326/.rbenv/versions/2.5.1/bin/bundle
RAILS_ENV=development
USER=kyon2326
RAILS_ROOT_DIR="/home/kyon2326/workspace/suzukitsukurepo"
URL_PATH=/suzukitsukurepo
DESC="suzukitsukurepo"
NAME=""

#
PIDFILE=${RAILS_ROOT_DIR%/}/tmp/pids/unicorn.pid
UNICORN_CONF=${RAILS_ROOT_DIR%/}/config/unicorn.rb
UNICORN_ALIVE=`ps aux|grep '${UNICORN_CONF}'|grep -v grep|wc -l`

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DAEMON="${BUNDLE_PATH} exec unicorn_rails"
DAEMON_ARGS="-D -c ${UNICORN_CONF} -E ${RAILS_ENV} --path ${URL_PATH}"

# Exit if the package is not installed
#[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
#[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
#. /lib/init/vars.sh
VARBOSE=yes

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    start-stop-daemon --start --quiet --chuid $USER --chdir $RAILS_ROOT_DIR --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
        || return 1
    start-stop-daemon --start --quiet --chuid $USER --chdir $RAILS_ROOT_DIR --pidfile $PIDFILE --exec $DAEMON -- \
        $DAEMON_ARGS \
        || return 2
    cd ${RAILS_ROOT_DIR}
    RAILS_ENV=$RAILS_ENV ${BUNDLE_PATH} exec ${RAILS_ROOT_DIR%/}/bin/delayed_job -n 1 start
    # Add code here, if necessary, that waits for the process to be ready
    # to handle requests from services started subsequently which depend
    # on this one.  As a last resort, sleep for some time.
}

#
# Function that stops the daemon/service
#
do_stop()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    start-stop-daemon --stop --quiet --signal QUIT --retry=TERM/30/KILL/5 --pidfile $PIDFILE
    RETVAL="$?"
    [ "$RETVAL" = 2 ] && return 2
    # Wait for children to finish too if this is a daemon that forks
    # and if the daemon is only ever run from this initscript.
    # If the above conditions are not satisfied then add some other code
    # that waits for the process to drop all resources that could be
    # needed by services started subsequently.  A last resort is to
    # sleep for some time.
    start-stop-daemon --stop --quiet --signal QUIT --oknodo --retry=0/30/KILL/5 --pidfile $PIDFILE
    [ "$?" = 2 ] && return 2
    # Many daemons don't delete their pidfiles when they exit.
    #rm -f $PIDFILE
    cd ${RAILS_ROOT_DIR}    
    RAILS_ENV=$RAILS_ENV ${BUNDLE_PATH} exec ${RAILS_ROOT_DIR%/}/bin/delayed_job stop
    return "$RETVAL"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
        #
        # If the daemon can reload its configuration without
        # restarting (for example, when it is sent a SIGHUP),
        # then implement that here.
        #
        start-stop-daemon --stop --signal USR2 --pidfile $PIDFILE
        return 0
}

case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
    do_start
    case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
    ;;
  stop)
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    do_stop
    case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
    ;;
  status)
    status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
    ;;
  restart|reload|force-reload)
    #
    # If do_reload() is not implemented then leave this commented out
    # and leave 'force-reload' as an alias for 'restart'.
    #
    log_daemon_msg "Reloading $DESC" "$NAME"
    do_reload
    log_end_msg $?
    ;;
  #restart|force-reload)
    #
    # If the "reload" option is implemented then remove the
    # 'force-reload' alias
    #
    #log_daemon_msg "Restarting $DESC" "$NAME"
    #do_stop
    #case "$?" in
    #      0|1)
    #    do_start
    #    case "$?" in
    #        0) log_end_msg 0 ;;
    #        1) log_end_msg 1 ;; # Old process is still running
    #        *) log_end_msg 1 ;; # Failed to start
    #        esac
    #    ;;
    #      *)
    #    # Failed to stop
    #    log_end_msg 1
    #    ;;
    #    esac
    #;;
  *)
    #echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
    echo "Usage: ${0##*/} {start|stop|status|restart|force-reload}" >&2
    exit 3
    ;;
esac

:
