#argument 1 is the process name valgrind will follow eg MW_Process,APP_Process etc. 
#argument 2 is location for the log file to be saved, if not provided it defaults to /host/logs_vg.txt
#argument 3 is tool. default value is 'memcheck' others are cachegrind, callgrind, helgrind, drd, massif, dhat, lackey, none, exp-sgcheck, exp-bbv, etc. 
#if any other process needs to be skipped by valgrind added it skip_process variable
#check for command: in valgrind logs to check which children it has followed.
#mount the pendrive as /host
skip_process="*/WPP_MONITOR_Process,*/PWM_Process,*/disk_partition,*/FusionConfigImport,*/hawaiibrowser_process,*/STM_Process,*/xpower_getwakeup"

if [ "MW_Process" != "$1" ]; then
        skip_process="*/MW_Process,$skip_process"
fi

if [ "APP_Process" != "$1" ]; then
                skip_process="*/APP_Process,$skip_process"
fi

if [ "CA_Process" != "$1" ]; then
                skip_process="*/CA_Process,$skip_process"
fi

if [ "SCD_process" != "$1" ]; then
                skip_process="*/SCD_Process,$skip_process"
fi

if [[ "MW_Process" != "$1" && "APP_Process" != "$1" && "CA_Process" != "$1" && "SCD_process" != "$1" ]]; then
        echo "no process matches argument 1 of start.sh. exiting"
        exit
fi

echo "These files will be skip_processped \n $skip_process"

#mkdir /host
#mount /dev/sdb1 /host/
#----------------------------------------------------------
if [ -f /host/swapfile ] ; then
	echo "swapfile exsits"
else
	echo "creating swapfile"
	dd if=/dev/zero of=/host/swapfile bs=1024 count=1048576
fi
#----------------------------------------------------------

if [ -z "$2" ]; then
       log_loc="/host/logs_vg.txt"
       rm $log_loc
        touch $log_loc
else
log_loc="$2"
touch $log_loc
fi
echo "log file location : $log_loc"
#----------------------------------------------------------------------
if [ -z "$3" ]; then
       tool="memcheck"
else
tool="$3"
fi
echo "tool : $tool"
#---------------------------------------------------------------------------
VALGRIND_LIB=/host/valgrind/lib/valgrind
export VALGRIND_LIB
chmod 600 /host/swapfile
mkswap /host/swapfile
swapon /host/swapfile

echo  "swap details"
free
echo  "running valgrind"

/host/valgrind/bin/valgrind --log-file=$log_loc --trace-children=yes --trace-children-skip=$skip_process --tool=$tool /NDS/start.sh

