#!/bin/awk -f 
BEGIN { FS=","}
{ #cut milliseconds in date string field and converts it to timestamp
  #split($1,tmp,":")
  #$1=tmp[1]":"tmp[2]":"tmp[3]
  #cmd="date -d \""$1"\" +%s"
  #cmd | getline $1
  #close(cmd)

  #split($2,tmp,":")
  #$2=tmp[1]":"tmp[2]":"tmp[3]
  #cmd="date -d \""$2"\" +%s"
  #cmd | getline $2
  #close(cmd)
   
  if (NR==1) {
	#starttime=$1
	#endtime=$2
        compression=$3
        messagesize=$4
        batchsize=$5
        totaldatasentinMB=$6
        MBsec=$7
        totaldatasentinnMsg=$8
        nMsgsec=$9
	topic=$10
  }
  if (NR>=2) { 
	#if ($1<starttime)
	#	starttime=$1
	#if ($2>endtime)
	#	endtime=$2
        messagesize+=$4
        batchsize+=$5
	totaldatasentinMB+=$6
	MBsec+=$7
	totaldatasentinnMsg+=$8		
	nMsgsec+=$9
	topic=$10
  }
  
}
END{ print NR, compression, messagesize/NR, batchsize/NR, totaldatasentinMB/NR, MBsec/NR, totaldatasentinnMsg, nMsgsec, topic
}
