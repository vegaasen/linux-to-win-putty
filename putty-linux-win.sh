#!/bin/bash
## 
## Simple utility that just exports all kinds of stuff related to Putty on a Linux machine. From Linux => Windows :-). 
## Tested using:
## 	- Ubuntu
##	- RHEL 6+7
##
## @author <a href="vegaasen@gmail.com">Vegard Aasen</a>
## @version 0.1-SNAPSHOT
##

DEFAULT_SESSIONS=~/.putty/sessions/;
DEFAULT_HOST_KEYS=~/.putty/sshhostkeys;
REGISTERY_DEFAULT_HEADER="Windows Registry Editor Version 5.00"
REGISTERY_DEFAULT_PATH="HKEY_CURRENT_USER\\Software\\SimonTatham\\PuTTY\\";
REGISTERY_HOST_KEYS="SshHostKeys";
REGISTERY_SESSIONS="Sessions";
FILE_NAME_SESSIONS=putty-sessions.reg
FILE_NAME_HOST_KEYS=putty-ssh-host-key.reg

function log() {
	WHAT=$1;
	LEVEL=$2;
	if [ -z "$LEVEL" ]; then
		LEVEL="INFO"
	fi
	LEVEL="[$LEVEL] ";
	echo "$LEVEL$WHAT";

}

function logInfo() {
	log "$1" "INFO";
}

function logWarning() {
	log "$1" "WARN";
}

function logError() {
	log "$1" "ERROR";
}

function logInfoWithHeader() {
	logInfo "########################################";
	logInfo "$1";
	logInfo "########################################";
}

function fileExists() {
	file=$1;
	if [ ! -e $file ]; then
		logError "Cannot find file $1.";
		exit -1;
	fi
}

function appendLineBreak() {
	fileName=$1;
	fileExists $fileName;
	printf "\n" >> $fileName;
}

function appendRegisteryHeaderComponents() {
	fileName=$1;
	fileExists $fileName;
	printf "$REGISTERY_DEFAULT_HEADER" >> $fileName;
	appendLineBreak $fileName;
}

function appendRegisteryComponent() {
	reference=$1;
	fileName=$2;
	if [ -z "$reference" ]; then
		logError "No reference provided. Grats.";
		exit -1;
	fi
	fileExists $fileName;
	echo "[$REGISTERY_DEFAULT_PATH$reference]" >> $fileName;
	appendLineBreak $fileName;
}

function resetFile() {
	fileName=$1;
	if [ -z "$fileName" ]; then
		logError "Errr. Param FileName was not present. This is expected. Wtf.";
		exit -1;
	fi
	if [ -e "$fileName" ]; then
		logInfo "Old version found. Removing this.";
		rm -f $fileName;
	fi
	touch $fileName;
}

function exportHostKeys() {
	path=$1
	if [ -z "$path" ]; then
		logInfo "Using defaults {$DEFAULT_HOST_KEYS}";
		path=$DEFAULT_HOST_KEYS;
	fi
	fileExists $path
	resetFile $FILE_NAME_HOST_KEYS;
	appendRegisteryHeaderComponents $FILE_NAME_HOST_KEYS;
	appendRegisteryComponent "$REGISTERY_HOST_KEYS" $FILE_NAME_HOST_KEYS;
	cat $path | while read line
	do
		key="$( cut -d ' ' -f 1 <<< $line )";
		value="$( cut -d ' ' -f 2- <<< $line )";
		echo "\"$key\"=\"$value\"" >> $FILE_NAME_HOST_KEYS
	done
	logInfo "Ssh Host Keys has been exported.";
}

function exportSessions() {
	path=$1
	if [ -z "$path" ]; then
		logInfo "Using defaults {$DEFAULT_SESSIONS}";
		path=$DEFAULT_SESSIONS;
	fi
	fileExists $path
	resetFile $FILE_NAME_SESSIONS;
	appendRegisteryHeaderComponents $FILE_NAME_SESSIONS;
	appendRegisteryComponent "$REGISTERY_SESSIONS" $FILE_NAME_SESSIONS;
	appendLineBreak $FILE_NAME_SESSIONS;
	ls $path | while read filee
	do
		appendRegisteryComponent "$REGISTERY_SESSIONS\\$filee" $FILE_NAME_SESSIONS;
		cat $path$filee | while read line
		do
			key="$( cut -d '=' -f 1 <<< $line )";
			value="$( cut -d '=' -f 2- <<< $line )";
			numeric='^[0-9]+$';
			alphas='^[a-zA-Z\,\-\_\.\%\\:\= \/(0-9)+]+$';
			if [[ $value =~ $numeric ]] ; then
				value="$( echo 'obase=16; '$value'' | bc )";
				length="${#value}";
				if [ $length -lt 8 ]; then
					missing=$((8 - $length));
					pointless=0;
					value="$( printf %0"$missing"d "$pointless" )$value";
				fi
				value="dword:$value";
			else
				if [[ $value =~ $alphas ]] ; then
					value="\"$value\"";
				fi
			fi
			echo "\"$key\"=$value" >> $FILE_NAME_SESSIONS;
		done
		echo "Successfully wrote $filee";
		appendLineBreak $FILE_NAME_SESSIONS;
		appendLineBreak $FILE_NAME_SESSIONS;
	done
	logInfo "Ssh Host Keys has been exported.";
}

function countSessions() {
	path=$1
	if [ -z "$path" ]; then
		logInfo "Using defaults {$DEFAULT_SESSIONS}";
		path=$DEFAULT_SESSIONS;
	fi
	fileExists $path;
	ls $path | wc -l;
}

function countHostKeys() {
	path=$1
	if [ -z "$path" ]; then
		logInfo "Using defaults {$DEFAULT_HOST_KEYS}";
		path=$DEFAULT_HOST_KEYS;
	fi
	fileExists $path;
	cat $path | grep "rsa2" | wc -l;
}

logInfoWithHeader "Putty Sessions + Keys Exporter v0.1-SNAPSHOT. Linux=>Windows variant.";

case $1 in
	export-sessions)
		logInfo "Exporting sessions";
		exportSessions $2;
	;;
	export-hostkeys)
		logInfo "Exporting ssh-host-keys";
		exportHostKeys $2;
	;;
	count-sessions)
		logInfo "Counting all sessions";
		countSessions $2;
	;;
	count-hostkeys)
		logInfo "Counting all ssh-host-keys";
		countHostKeys $2;
	;;
	*)
		logInfo "Unknown command $1. Supported commands is one of {export-sessions (opt) <path>, export-hostkeys (opt) <path>, count-sessions (opt) <path>, count-hostkeys (opt) <path>}"
		exit 1
	;;
esac
