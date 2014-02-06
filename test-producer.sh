#!/bin/bash

#ENV
set_defaults(){

    #PATHS
    ROOT_DIR=${ROOT_DIR-"./benchmark/`date +%d-%m-%Y_%s`"}
    TMP=${TMP-"/tmp/partial_Kafka_bench_`date +%s`"}
    ZK_CLI="/opt/zookeeper/bin/zkCli.sh"
    KAFKA_DIR=${KAFKA_DIR-"/root/kafka-0.8.0-src/"}

    #SERVERS
    [ -z $PRODUCERS_LIST ] && PRODUCERS_LIST=( "PRODUCER1" "PRODUCER2" "PRODUCER3" "PRODUCER4" "PRODUCER5" "PRODUCER6" "PRODUCER7" "PRODUCER8" "PRODUCER9" "PRODUCER10" )
    MAX_PRODUCERS=${MAX_PRODUCERS-10}
    MAX_TOPICS=${MAX_TOPICS-10}
    MESSAGES_DEFAULT=${MESSAGES_DEFAULT-1000000}
    TOPICS_DEFAULT=${TOPIC_DEFAULT-"PERF"}
    MSG_SIZE_DEFAULT=${MSG_SIZE_DEFAULT-500}
    BATCH_SIZE_DEFAULT=${BATCH_SIZE_DEFAULT-200}
    NUM_ACKS_DEFAULT=${NUM_ACKS_DEFAULT-1}
    REPLICAS=${REPLICAS-1}
    PARTITIONS=${PARTITIONS-1}
    COMPRESSION_LIST=${COMPRESSION_LIST-"0 1 2"}

    #AUX
    CMD=$KAFKA_DIR/bin/kafka-producer-perf-test.sh
    AWK_MERGER="/root/merge.awk"
    HEADER_TEXT="producers compression messagesize batchsize totaldatasentinMB MBsec totaldatasentinnMsg nMsgsec topic_max replicas partitions brokers"
    unset BROKERS_PORT_DEFAULT
    for broker in $BROKERS_LIST; do BROKERS_PORT_DEFAULT+=" ${broker}:9092";done
    ARRAY_BROKERS=($BROKERS_LIST)
}

remote_call(){
    kafka_server "start"
    PRODUCERS=$1
    COMPRESSION=$2
    BROKERS="$3"
    TOPICS="$4"
    for topic in ${TOPICS}; do kafka_server create_topic ${topic} ${REPLICAS} ${PARTITIONS}; done
    sleep 5
    for topic in ${TOPICS}; do TOPIC_MAX=$topic; done
    MESSAGES="$5"
    MSG_SIZE="$6"
    BATCH_SIZE=$7
    NUM_ACKS=$8
    TEST_FILE_OUT=$9
    for producer in `seq 0 $(( $PRODUCERS - 1 ))`; do
	ssh ${PRODUCERS_LIST[$(($producer % ${#PRODUCERS_LIST[@]}))]} $CMD --compression-codec $COMPRESSION --broker-list $BROKERS \
	  --topics $TOPICS --messages $(( $MESSAGES / $PRODUCERS )) --message-size $MSG_SIZE --batch-size $BATCH_SIZE --request-num-acks \
	  $NUM_ACKS --hide-head | grep -v "WARN Property reconnect.interval" | sed -e "s/$/, ${TOPIC_MAX} ${REPLICAS} ${PARTITIONS} ${#ARRAY_BROKERS[*]}/">>$TMP &
    done
    wait
    cat $TMP | awk -f $AWK_MERGER >> ${TEST_FILE_OUT}
    rm -f $TMP
    kafka_server "clean"
}

test_producers(){
    MESSAGES=$MESSAGES_DEFAULT
    BROKERS_PORT=$BROKERS_PORT_DEFAULT
    MSG_SIZE=$MSG_SIZE_DEFAULT
    BATCH_SIZE=$BATCH_SIZE_DEFAULT
    TOPICS=$TOPICS_DEFAULT
    NUM_ACKS=$NUM_ACKS_DEFAULT
    OIFS=$IFS
    unset IT_LIST
    unset IT_PARAM
    case $1 in
	"MSG_SIZE" )
	    IT_LIST=`seq 100 500 $MSG_SIZE_DEFAULT`
	    IT_PARAM="MSG_SIZE"
	    SPLIT=$IFS
	    ;;
	"BATCH_SIZE")
	    IT_LIST=`seq 100 500 $BATCH_SIZE_DEFAULT`
	    IT_PARAM="BATCH_SIZE"
	    SPLIT=$IFS
	    ;;
	"TOPICS")
	    for num_topics in `seq 1 3 $MAX_TOPICS`; do for j in `seq 1 $num_topics`; do IT_LIST+="${TOPICS_DEFAULT}$j "; done; IT_LIST+=";"; done
	    IT_PARAM="TOPICS"
	    SPLIT=";"
	    ;;
	"NUM_ACKS")
	    IT_LIST="-1 0 1"
	    IT_PARAM="NUM_ACKS"
	    SPLIT=$IFS
	    ;;
	*)
	    echo "Invalid test: ${1}"
	    exit 1
	    ;;
    esac
    for COMPRESSION in $COMPRESSION_LIST; do
	TEST_FILE_OUT="${ROOT_DIR}/${IT_PARAM}_${COMPRESSION}"
	echo "${HEADER_TEXT}" > $TEST_FILE_OUT
	for NUM_PRODUCERS in `seq 1 3 $MAX_PRODUCERS`; do 
	    IFS=${SPLIT}
	    for it in $IT_LIST; do 
	        echo "`date` COMPRESSION=${COMPRESSION} #PRODUCERS=${NUM_PRODUCERS} PARAMETER=${IT_PARAM} VAL=${it}"
		IFS=${OIFS}
		eval ${IT_PARAM}=\"${it}\"
		remote_call "${NUM_PRODUCERS}" "${COMPRESSION}" "${BROKERS_PORT}" "${TOPICS}" "${MESSAGES}"  \
		  "${MSG_SIZE}"  "${BATCH_SIZE}" "${NUM_ACKS}" "$TEST_FILE_OUT"
	    done
	done
    done
}

kafka_server(){
    cmd=$1
    shift
    case $cmd in
	"stop")
	    for host in $BROKERS_LIST; do ssh $host "$KAFKA_DIR/bin/kafka-server-stop.sh>/dev/null";done
	    ;;
	"start")
	    for host in $BROKERS_LIST; do ssh -f $host "$KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties>/dev/null" ;done
	    sleep 5
	    ;;
	"clean")
	    kafka_server "stop"
	    for i in $TOPICS_ONLINE; do kafka_server "delete_topic" ${i}; done
	    ;;
	"create_topic")
	    echo "CREATING TOPIC ${1}"
	    $KAFKA_DIR/bin/kafka-create-topic.sh --zookeeper $ZK_SERVERS --topic $1 --replica $2 --partition $3 &>"/dev/null"
	    TOPICS_ONLINE+=" $1"
	    ;;
	"delete_topic")
	    echo "DELETING TOPIC ${1}"
	    for host in $BROKERS_LIST; do ssh $host "rm -rf /tmp/kafka-logs/${1}-*"; done
	    ${ZK_CLI} -server ${ZK_SERVERS} rmr /brokers/topics/${1} &>"/dev/null"
	    TOPICS_ONLINE=`echo ${TOPICS_ONLINE} | sed "s/${1}//"`
	    ;;	    
    esac
}

usage(){
cat << EOF
usage: $0 options

This script run different tests over a Kafka system.

OPTIONS:
  -a Acks to send. Valid values:
	-1 the producer gets an acknowledgement after all in-sync replicas have received the data [DEFAULT]
	0 the producer never waits for an acknowledgement from the broker
	1 the producer gets an acknowledgement after the leader replica has received the data
  -b Base name to use for topics creation [DEFAULT perf]
  -B List of kafka brokers [REQUIRED]
  -c Max consumers to use
  -C List of kafka consumers
  -d List of compression methods to use [DEFAULT "0 1 2"]
  -K Kafka root dir [DEFAULT /root/kafka-0.8.0-src
  -m Messages to send [DEFAULT 1000000]
  -O Output dir [DEFAULT ./benchmark]
  -p Max number of producers to use. It will be applied an increase of 3 in each loop. [DEFAULT 10]
  -P List of kafka producers.
  -r Replicates to use for each created topic [DEFAULT 1]
  -R Partitions to use for each created topic [DEFAULT 1]
  -s message size to use.If test=MSG_SIZE then indicates MAX_MESSAGE_SIZE from 100 to MAX_MESSAGE_SIZE increasing by 500 in each loop [DEFAULT 500/2100] 
  -S batch size. If test=BATH_SIZE then indicates MAX_BATCH_SIZE from 100 to MAX_BATCH_SIZE increasing by 500 in each loop [DEFAULT 100/2100]
  -t Test to run. Accepted values [REQUIRED]:
	MSG_SIZE: will loops increasing messages size.
	BATCH_SIZE: will loops increasing batch size.
	TOPICS: will loops increasing topics to send.
	ACKS: will loop using all ACKS options availables.
  -T Path dir to temporal outputs [DEFAULT /tmp]
  -z List of zookeeper servers to use [REQUIRED]
  -Z Path to zookeeper root dir [DEFAULT /opt/zookeeper]
EOF
exit 1
}

options='a:b:B:c:C:d:K:m:O:p:P:r:R:s:S:T:t:z:Z:'
while getopts $options opt; do
    case $opt in
	a)
	    NUM_ACKS=$OPTARG
	    ((NUM_ACKS == 1 || NUM_ACKS == -1 || NUM_ACKS == 0 )) || usage
	    ;;
	b)
	    TOPICS_BASE=$OPTARG
	    ;;
	B)
	    BROKERS_LIST=$OPTARG
	    ;;
	c)
	    MAX_CONSUMERS=$OPTARG
	    ;;
	C)
	    CONSUMERS_LIST="${OPTARG}"
	    ;;
	d)
	    COMPRESSION_LIST="${OPTARG}"
	    check=`echo $COMPRESSION_LIST |awk '/^[012 ]+$/{print 1}'`
	    ((check && ${#COMPRESSION_LIST} <=5)) || usage
	    ;;
	K)
	    KAFKA_DIR="$OPTARG"
	    ;;
	m)
	    MESSAGES_DEFAULT=$OPTARG
	    ((MESSAGES_DEFAULT > 0)) || usage
	    ;;
	O)
	    ROOT_DIR="$OPTARG"
	    ;;
	p)
	    MAX_PRODUCERS=$OPTARG
	    ((MAX_PRODUCERS > 0)) || usage
	    ;;
	P)
	    PRODUCERS_LIST=($OPTARG)
	    ;;
	r)
	    REPLICAS=$OPTARG
	    ((REPLICAS > 0)) || usage
	    ;;
	R)	
	    ((PARTITIONS > 0)) || usage
	    ;;
	s)
	    MSG_SIZE_DEFAULT=$OPTARG
	    ((MSG_SIZE_DEFAULT > 0)) || usage
	    ;;
	S)
	    BATCH_SIZE_DEFAULT=$OPTARG
	    ((BATCH_SIZE_DEFAULT > 0)) || usage
	    ;;
	t)
	    TEST="$OPTARG"
	    [ $TEST == "MSG_SIZE" ] || [ $TEST == "BATCH_SIZE" ] || [ $TEST == "TOPICS" ] || [ $TEST == "NUM_ACKS" ] || usage
	    [ $TEST == "MSG_SIZE" ] && [ -z "$MSG_SIZE_DEFAULT" ] && MSG_SIZE_DEFAULT=2100
	    [ $TEST == "BATCH_SIZE" ] && [ -z "$BATCH_SIZE_DEFAULT" ] && BATCH_SIZE_DEFAULT=2100
	    ;;
	T)
	    TMP=$OPTARG
	    ;;
	z)
	    ZK_SERVERS="$OPTARG"
  	    ;;
	Z)	
	    ZK_CLI="$OPTARG"
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument."
	    usage
	    exit 1
	    ;;
	?)
	    usage
	    exit 1
	    ;;
    esac
done
[ -z "$BROKERS_LIST" ] && echo "Missing required flag -B" && usage
[ -z "$TEST" ] && echo "Missing required flag -t" && usage
[ -z "$ZK_SERVERS" ] && echo "Missing required flag -z" && usage
    
set_defaults
mkdir -p $ROOT_DIR
test_producers $TEST
#kafka_server clean
#kafka_server "stop"
#kafka_server "start"
#kafka_server delete_topic PERF
#test_producers "MSG_SIZE"
#test_producers "BATCH_SIZE"
#test_producers "NUM_ACKS"
#test_producers "TOPICS"
#exit 
