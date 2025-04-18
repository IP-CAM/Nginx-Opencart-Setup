#!bin/sh
 
set -e 
 
ls -l $(which sh)
echo "\nWhat shell? : $SHELL\n" 

INCLUDESARELOADED=1

# mydomain=$1    # e.g.reallymydomain.site
#: ${mydomain:=$1}
#: ${sourceurl:=$2}
#: ${sourceroot:=$3}

: ${MYREPOURL:="https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/"}
: ${currentscript:="includes.sh"}
echo '# 👣 Running $currentscript in cloud-init:\n' >> $HOME/log.txt
printf "\n 👣 Running $currentscript in cloud-init:\n"

# MYTMPDIR="$(mktemp -d)"
: ${MYTMPDIR:="$(mktemp -d)"}
printf "\n Using temporal directory $MYTMPDIR\n"

if sh -c ": >/dev/tty" >/dev/null 2>/dev/null; then
: "${SIG_NONE=0}"
: "${SIG_HUP=1}"
: "${SIG_INT=2}"
: "${SIG_QUIT=3}"
: "${SIG_KILL=9}"
: "${SIG_TERM=15}"
 trap 'rm -rf -- "$MYTMPDIR"' 0 $SIG_NONE $SIG_HUP $SIG_INT $SIG_QUIT $SIG_TERM
else
 trap 'rm -rf -- "$MYTMPDIR"' EXIT
fi



help_actions() {
      printf "
	  Available arguments:
	   --domain or -d : your domain, e.g.'reallymydomain.site'
       Installation related:	   
	    --url or -u : url to zip with OC source, e.g. 'https://github.com/xxx/yyy/archive/refs/heads/1.2.x.zip'
        --ziproot or -z : root for sources inside the zip (normally 'xxx/upload')	 
       Database reinstallation related:	 
        --dbpwd or -dbp      :  password for dbroot 
		--dbuser or -dbu     :  dbroot user name (normally 'root')
		--db2drop or -db2d   : database to drop by reinstallation (previous one)
	    --user2drop or -u2d  : db(and oc)-user to drop by reinstallation (previous one)	
	   --action or -a : script name to execute, e.g. 'reinstall-opencart'
	    Available optons:
		  -a reinstall-opencart : creates new OC-database (evtl drops previous ons) and whole OC
	      -a install-opencart   : installs OC, creates new database
		  -a install-lemp       : installs LEMP
		  -a install-ioncube    : installs ioCube Loader
		  -a setup              : setups aall environment and installs OC
		  -a check-conf         : checks configuration (is a part of setup)
		  -a ss-init            : initialize SSL (is a part of setup)
		  -a certbot            : installs and run  SSL Lets Encrypt bot (is a part of setup)
		--cli or -c  : runs OC install automatically with cli_install, any not null value allowed e.g. yes  
        --help or -h : shows this help		  
	  "  
}

downloadnrun() {
 unset scripturl scriptname
 scripturl="$MYREPOURL""$1"	
 scriptname="${scripturl##*/}"
 printf '..%s\n' "scripturl=$scripturl scriptname=$scriptname"

 random="$(mktemp -p "$MYTMPDIR" "$scriptname"-XXXXX)"
 printf '..%s\n' "random=$random"
 #random=$scriptname."$(pwgen -1 -s 5)"

 curl -s $scripturl  -o $random
 chmod a+x $random
 echo "👣👣👣 running $random ..."

 first_arg="$1"
 shift
 echo First argument: "$first_arg"
 echo 👣 with arguments: "$@"
# for bash just use # "${@:2}" instead of above
 . $random  "$@"
# echo "$mydomain $dry_run" | . $random
 echo "👣👣👣 just exited from $random !"
 rm -f $random
################################################ 
}

read_args_by_name() {
#echo "# arguments includes called with ---->  ${@}"
 while [ $# -gt 0 ]; do
  case "$1" in
    --domain*|-d*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      mydomain="${1#*=}"
      ;;  
    --url*|-u*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      sourceurl="${1#*=}"
      ;;
    --ziproot*|-z*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      sourceroot="${1#*=}"
      ;;	
    --dbpwd*|-dbp*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      dbrootpassword="${1#*=}"
      ;;	
    --dbuser*|-dbu*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      dbrootusername="${1#*=}"
      ;;	
    --db2drop*|-db2d*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      db2drop="${1#*=}"
      ;;	
    --user2drop*|-u2d*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      user2drop="${1#*=}"
      ;;
    --cli*|-c*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      cliinstall="${1#*=}"
      ;;		  
    --action*|-a*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      action="${1#*=}"
	  echo "\n action=#action\n"
      ;;		  
    --help|-h)
	  printf "${INFO}
      help_actions # Flag argument
	  printf "${NC}
      exit 0
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
 done
}

set_colors() {
 OK=$(tput setaf 2)"\n 👌: " 	# green
 ERR=$(tput setaf 1)"\n 💩: " 	# red
 WARN=$(tput setaf 3)"\n 👽: " 	# yellow
 INFO=$(tput setaf 4)" 👣: " 	# blue
 NC=$(tput sgr0)"\n"  			# unset
 BELL=$(tput bel)  				# play a bell
}

# set mydomain variable as e.g. reallymydomain.site
check_mydomain_set() {
 if [ -z ${mydomain+x} ] ; then  
   printf "${INFO}Setting var mydomain to '$mydomain' ${NC}"
   mydomain=$1
 else
   printf "${INFO}Supposing var mydomain as '$mydomain' ${NC}"
 fi
 if [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
   printf "${ERR}You need to set YOUR own domain mydomain. Exiting..${NC}" 
   exit 1 
 fi
  webroot="/var/www/$mydomain/public"
}

# this intended to be used in scripts that might be run alone without runner.sh:  
set_opencart_source() {
 # Opencart source related
 if [ -z ${sourceurl+x} ] ; then sourceurl=$2; fi
 if [ -z ${sourceroot+x} ] ; then sourceroot=$3; fi
}

# this intended to be used in scripts that might be run alone without runner.sh:  
set_dbreqs() {
 # Database related
 if [ -z ${dbrootpassword+x} ] ; then dbrootpassword=$4; fi
 if [ -z ${dbrootusername+x} ] ; then dbrootusername=$5; fi
 if [ -z ${db2drop+x} ] ; then  db2drop=$6; fi
 if [ -z ${user2drop+x} ] ; then  user2drop=$7; fi
}


headermsg() { 
 #me=$(basename "$0")
 printf "${INFO} 
 * Starting to execute '$scriptname'-script with 'set -e'(exit on error switch)
    from folder ${0%/*}
 * Installation details will be in file $HOME/log.txt
 * DO NOT DELETE THIS FILE BEFORE COPYING THE DATA ${NC}
 "
}


footermsg() { 
 if [[ $? == 0 ]]; then
  printf "${OK}${BELL} 
   * We have reached end of '$scriptname'-script with 'set -e'(exit on error switch), 
      so all seems to be OK${NC}"
 else
  printf "${ERR}${BELL} 
   * It seems to be some error (error code $?)${NC}" 
 fi 
   printf "${INFO}
   * Installation details are in file $HOME/log.txt
   * DO NOT DELETE THIS FILE BEFORE COPYING THE DATA ${NC}"
}

set_colors
headermsg
