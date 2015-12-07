#!/bin/sh

# IGUANA Benchmark in a Docker container

# Startscript to prepare and start iguana benchmarking for each given store
# This file can executed directly or via Docker (look README)
# ------------------------
# Procedure
#   - get stores from loader container environment variable STORE_... (see README)
#   - may add user defined config.xml/queries.txt from /iguana/config/ 
#   - replace  %STORES%, %CHOOSE% and queires.txt in config.xml with our store-configuration (uri, user etc)
#   - run benchmark
# ------------------------

if [[ $# -lt 3 ]] ; then
	echo "Too less arguments. Usage: $0 jars-lib-folder config-file queries-files"
	exit 1
fi

LIBDIR=$1
CONFIG=$2
QUERIES=$3
CONF_DIR="./config/"
LOADER_ADDR="${LOADER_PORT_8891_TCP_ADDR}" # load address, from compose loader container
: ${CONNECTION_ATTEMPTS:=10}

# main function
main() {
	# if config dir exists,  may overwrite config/queries file
	if [ -d $CONF_DIR ] ; then
		copy_user_config
	fi

	XML_DBS=""
	XML_CHDBS=""

	# load and parse stores from env_stores
	get_stores

	# escape the xml sections for sed
	dbs_sed_esc=$(echo $XML_DBS | sed -e 's/\//\\\//g')
	chdbs_sed_esc=$(echo $XML_CHDBS | sed -e 's/\//\\\//g')
	queries_sed_esc=$(echo $QUERIES | sed -e 's/\//\\\//g')

	# tmp copy of config for sed-write access to avoid "... resource busy" Error if this file is mounted
	cp $CONFIG ./tmp-config.xml
	TMP_CONFIG="./tmp-config.xml"

	# replace %STORES%, %CHOOSE% and default queries.txt with the generated sections in config.xml
	if [[ ! -z $XML_DBS ]]; then
		sed -i "s/<!-- %STORES% -->/${dbs_sed_esc}/g" $TMP_CONFIG
		sed -i "s/<!-- %CHOOSE% -->/${chdbs_sed_esc}/g" $TMP_CONFIG
	else
		echo "[INFO] No stores as environment given! (Hopefully you placed some in your config.xml?!)"
	fi
	sed -i "s/<property name=\"queries-path\" value=\"queries.txt\"\/>/<property name=\"queries-path\" value=\"${queries_sed_esc}\"\/>/g" $TMP_CONFIG
	cp ./tmp-config.xml $CONFIG

	# if we have a loader address, wait that its finished impport
	if [[ ! -z $LOADER_ADDR ]]; then
		echo "[INFO] loader address given - waiting for loader to be finished"
		test_connection "${CONNECTION_ATTEMPTS}" "${LOADER_ADDR}"
		if [ $? -eq 2 ]; then
		    echo "[ERROR] loader seems to be not finishing"
		    exit 1
		else
			echo "[INFO] loader connection OK"
		fi
	fi

	# start iguana
	java -cp "${LIBDIR}*" org.aksw.iguana.benchmark.Main $CONFIG
	
	# copy results_* to ./results (iguana saves results in results_0, results_1, ... etc, if there ara more than one <suite> in config.xml!)
	cp -r ./results_* ./results/

} # end of main

# may overwrite config/queries file with mounted config files
copy_user_config() {
	if [ -f ${CONF_DIR}config.xml ]; then
	    echo "[INFO] found config.xml to import"
	    cp ${CONF_DIR}config.xml $CONFIG
	else
	    echo "[INFO] no config.xml to import found. I'll use default config"
	fi

	if [ -f ${CONF_DIR}queries.txt ]; then
	    echo "[INFO] found queriers.txt to import"
	    cp ${CONF_DIR}queries.txt $QUERIES
	else
	    echo "[INFO] no queries file to import found. I'll use default queries"
	fi
}

# test connection to uri with curl
test_connection () {
    if [[ -z $1 || -z $2 ]]; then
        echo "[ERROR] missing argument: retry attempts or host"
        exit 1
    fi

    t=$1
    host=$2
    
    curl --output /dev/null --silent --head --fail "$host"
    while [[ $? -ne 0 ]] ;
    do
        echo -n "..."
        sleep 2
        echo -n $t
        let "t=$t-1"
        if [ $t -eq 0 ]
        then
            echo "...timeout"
            return 2
        fi
        curl --output /dev/null --silent --head --fail "$host"
    done
    echo ""
}

# echo uri 
uri_store_matching() {
    uri=$1
    if [[ "$uri" =~ %[A-Za-z]+% ]] ; then
         # may get uri from linked docker container
        match=$BASH_REMATCH
        append=${uri//$match/} # may appended port/path
        store_id=${match//\%/} # replace %% from beginning and end
        store_id="${store_id^^}_PORT_22_TCP_ADDR" # uppercase store_tcp_22 ip-address
        uri=${!store_id}${append}
    fi
    echo $uri
}

# get config (URI, TYPE, USER, PWD) from string
get_store_config () {
    if [[ -z $1 ]]; then
        echo "[ERROR] missing argument: store variable"
        exit 1
    fi
    store=$1

    for str in $store
    do
        # split string at delimiter '=>'
        arr=(${str//=>/ })
        key=${arr[0]}
        val=${arr[1]}

        # echo "${key} = ${val}"
        case "$key" in
            "uri" ) 
                URI=$(uri_store_matching $val)
                ;;
            "type" )
                TYPE=$val
                ;;
            "user" )
                USER=$val
                ;;
            "pwd" ) 
                PWD=$val
                ;;
        esac    
    done
}

# load and parse stores from env_stores
get_stores() {	
	i=1
	stores="STORE_${i}"
	while [ -n "${!stores}" ]
	do
	    store=${!stores}
	    echo "[INFO] read store $i config: '${store}'"

	    URI=""
	    TYPE=""
	    USER=""
	    PWD=""

	    get_store_config "$store"

	    #echo "type: $TYPE , uri: $URI , user: $USER , pwd: $PWD"
	    if [ -z "$URI" ] ; then
	        echo "[ERROR] uri of store $i not given"
	        exit 1
	    fi  

	    echo "[INFO] waiting for store to come online"
	    test_connection "${CONNECTION_ATTEMPTS}" "${URI}"
	    if [ $? -eq 2 ]; then
	        echo "[ERROR] store $STORE_ADDR_TEST not reachable. Skip benchmark and continue..."
	        let "i=$i+1"
    		stores="STORE_${i}"
	        continue
	    else
	        echo "[INFO] store connection OK"
	    fi  

	    # generate database section
	    xml_db="<database id=\"store_${TYPE}_${i}\" type=\"impl\">
	            <endpoint uri=\"${URI}\" />
	            <user value=\"${USER}\" />
	            <pwd value=\"${PWD}\" />
	        </database>\n"
	    XML_DBS="${XML_DBS}${xml_db}"
	    
	    # generate choose element
	    xml_chdb="<db id=\"store_${TYPE}_${i}\" />\n"
	    XML_CHDBS="${XML_CHDBS}${xml_chdb}"
	    
	    let "i=$i+1"
    	stores="STORE_${i}"
	done
}

# start main
main