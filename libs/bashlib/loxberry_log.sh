#only works in bash scripting 
LOGS=0
ACTIVELOG=0
declare -A ARRLOGS

function LOGDEB {
	loadvariables
	if [ "$pLOGLEVEL" -gt 6 ]
	then
	  if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME$@"
	fi
}
function LOGINF {
	loadvariables
	if [ "$pLOGLEVEL" -gt 5 ]
	then
		if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME<INFO> $@"
	fi
}
function LOGOK {
	loadvariables
	if [ "$pLOGLEVEL" -gt 4 ]
	then
		if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME<OK> $@"
	fi
}
function LOGWARN {
	loadvariables
	if [ "$pLOGLEVEL" -gt 3 ]
	then
		if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME<WARNING> $@"
	fi
}
function LOGERR {
	loadvariables
	if [ "$pLOGLEVEL" -gt 2 ]
	then
		if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME<ERROR> $@"
	fi
}
function LOGCRIT {
	loadvariables
	if [ "$pLOGLEVEL" -gt 1 ]
	then
		if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME<CRITICAL> $@"
		if [ "$pLOGLEVEL" -lt 6 ];then set ARRLOGS[$ACTIVELOG]['loglevel'] = 6; fi
	fi
}
function LOGALERT {
	loadvariables
	if [ "$pLOGLEVEL" -gt 0 ]
	then
		if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME<ALERT> $@"
		if [ "$pLOGLEVEL" -lt 6 ];then set ARRLOGS[$ACTIVELOG]['loglevel'] = 6; fi
	fi
}
function LOGEMERGE {
	loadvariables
	if [ "$pLOGLEVEL" -ge 0 ]
	then
		if [ -n "$pADDTIME" ];then CURRTIME=$(date +"%H:%M:%S ");else CURRTIME=""; fi
		WRITE "$CURRTIME<EMERGE> $@"
		if [ "$pLOGLEVEL" -lt 6 ];then set ARRLOGS[$ACTIVELOG]['loglevel'] = 6; fi
	fi
}
function LOGSTART {
	if [ -n "$FILENAME" ]
	then
		COUNTER=0
		while [  $COUNTER -lt $LOGS ]; do
			COUNTER=$((COUNTER + 1))
			TESTFN=${ARRLOGS["$COUNTER.filename"]}
			if [ "$FILENAME" = "$TESTFN" ];then FILENAME=""; COUNTER=${LOGS}; fi
		done
	fi
	if [ -n "$DBKEY" ]
	then
		LOG=(`$LBHOMEDIR/libs/bashlib/initlog.php -dbkey=$DBKEY "--message=$@"`)
	elif [ -n "$PACKAGE" ] && [ -n "$NAME" ] && ([ -n "$LOGDIR" ] || [ -n "$FILENAME" ] || [ -n "$NOFILE" ])
	then
		LOGS=$((LOGS + 1))
		PARAM=""
		if [ "$LOGS" -eq 1 ];then ACTIVELOG=1; fi
		if [ -n "$STDERR" ];then PARAM=" --stderr=1"; ARRLOGS["$LOGS.stderr"]=$STDERR; fi
		if [ -n "$APPEND" ];then PARAM=" --append=1"; ARRLOGS["$LOGS.append"]=$APPEND; fi
		if [ -n "$NOFILE" ];then
			PARAM="$PARAM --nofile=1"
			ARRLOGS["$LOGS.nofile"]=$NOFILE
		else
			if [ -n "$FILENAME" ];then PARAM="$PARAM --filename=$FILENAME"; fi
			if [ -n "$LOGDIR" ];then PARAM="$PARAM --logdir=$LOGDIR"; ARRLOGS["$LOGS.logdir"]=$LOGDIR; fi
		fi
		ARRLOGS["$LOGS.name"]=$NAME
		ARRLOGS["$LOGS.package"]=$PACKAGE
		LOG=(`$LBHOMEDIR/libs/bashlib/initlog.php --name=$NAME --package=$PACKAGE$PARAM "--message=$@"`)
		FILENAME=${LOG[0]//\"}
		ARRLOGS["$LOGS.filename"]=$FILENAME
		if [ -z "$LOGLEVEL" ];then LOGLEVEL=${LOG[1]}; fi
		ARRLOGS["$LOGS.loglevel"]=$LOGLEVEL
		ARRLOGS["$LOGS.dbkey"]=${LOG[2]};
		if [ -n "$ADDTIME" ]; then ARRLOGS["$LOGS.addtime"]=$ADDTIME; fi
		if ([ -z ${NOFILE:+x} ] && [ -z ${FILENAME:+x} ]) || [ -z ${LOGLEVEL:+x} ]
		then
			echo "Log could not be started" 1>&2
			if [ ${ARRLOGS["$LOGS.stderr"]+_} ]; then unset ARRLOGS["$LOGS.stderr"]; fi
			if [ ${ARRLOGS["$LOGS.append"]+_} ]; then unset ARRLOGS["$LOGS.append"]; fi
			if [ ${ARRLOGS["$LOGS.nofile"]+_} ]; then unset ARRLOGS["$LOGS.nofile"]; fi
			if [ ${ARRLOGS["$LOGS.logdir"]+_} ]; then unset ARRLOGS["$LOGS.logdir"]; fi
			if [ ${ARRLOGS["$LOGS.name"]+_} ]; then unset ARRLOGS["$LOGS.name"]; fi
			if [ ${ARRLOGS["$LOGS.package"]+_} ]; then unset ARRLOGS["$LOGS.package"]; fi
			if [ ${ARRLOGS["$LOGS.filename"]+_} ]; then unset ARRLOGS["$LOGS.filename"]; fi
			if [ ${ARRLOGS["$LOGS.loglevel"]+_} ]; then unset ARRLOGS["$LOGS.loglevel"]; fi
			if [ ${ARRLOGS["$LOGS.addtime"]+_} ]; then unset ARRLOGS["$LOGS.addtime"]; fi
			if [ ${ARRLOGS["$LOGS.dbkey"]+_} ]; then unset ARRLOGS["$LOGS.dbkey"]; fi
			LOGS=$((LOGS -1))
			exit 1
		fi
		if [ -n "$FILENAME" ]; then
			ARRLOGS["$LOGS.fileid"]=$((LOGS + 199))
			eval "exec ${ARRLOGS["$LOGS.fileid"]}>>$FILENAME"
		fi
	else
		echo "Log could not be set because PACKAGE and/or NAME is not given" 1>&2
		exit 1
	fi
}
function LOGEND {
	loadvariables
	if [ "$pLOGLEVEL" -ge -1 ]
	then
			if [ -z ${pNOFILE:+x} ] && [ -n "$pFILEID" ]; then
				echo "<LOGEND>$@" >&${pFILEID}
				echo "<LOGEND>"$(date +"%d.%m.%Y %H:%M:%S")" TASK FINISHED" >&${pFILEID}
			fi
			if [ -n "$STDERR" ];then
				echo "<LOGEND>$@" 1>&2
				echo "<LOGEND>"$(date +"%d.%m.%Y %H:%M:%S")" TASK FINISHED" 1>&2
			fi
	fi
}
function WRITE {
	if [ -n "$pNOFILE" ];then echo "$@"; fi
	if [ -n "$pSTDERR" ] || ([ -z ${pNOFILE:+x} ] && [ -z ${pFILEID:+x} ]);then echo "$@" 1>&2; fi
	if [ -z ${pNOFILE:+x} ] && [ -n "$pFILEID" ];then echo "$@" >&${pFILEID}; fi
}
function loadvariables {
	unset pNOFILE
	unset pSTDERR
	unset pFILENAME
	unset pFILEID
	unset pADDTIME
	unset pLOGLEVEL
	if [ ${ARRLOGS["$ACTIVELOG.name"]+_} ]; then
		if [ ${ARRLOGS["$ACTIVELOG.nofile"]+_} ]; then pNOFILE=${ARRLOGS["$ACTIVELOG.nofile"]}; fi
		if [ ${ARRLOGS["$ACTIVELOG.stderr"]+_} ]; then pSTDERR=${ARRLOGS["$ACTIVELOG.stderr"]}; fi
		if [ ${ARRLOGS["$ACTIVELOG.filename"]+_} ]; then pFILENAME=${ARRLOGS["$ACTIVELOG.filename"]}; fi
		if [ ${ARRLOGS["$ACTIVELOG.fileid"]+_} ]; then pFILEID=${ARRLOGS["$ACTIVELOG.fileid"]}; fi
		if [ ${ARRLOGS["$ACTIVELOG.addtime"]+_} ]; then pADDTIME=${ARRLOGS["$ACTIVELOG.addtime"]}; fi
		if [ ${ARRLOGS["$ACTIVELOG.loglevel"]+_} ]; then pLOGLEVEL=${ARRLOGS["$ACTIVELOG.loglevel"]}; fi
	else
		pLOGLEVEL=3
		WRITE "<ERROR> No valid logfile selected"
	fi
}
