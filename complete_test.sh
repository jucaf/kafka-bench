#!/bin/bash
./test-producer.sh -B "BROKER1" -t "MSG_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -O "./benchmark/MSG_1B_1replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "MSG_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -O "./benchmark/MSG_3B_3replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "MSG_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2-O "./benchmark/MSG_3B_3replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4" -t "MSG_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 2 -R 2 -O "./benchmark/MSG_4B_2replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4 BROKER5 BROKER6 BROKER7 BROKER8 BROKER9 BROKER10" -t "MSG_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2 -O "./benchmark/MSG_10B_3replica_2partition"

./test-producer.sh -B "BROKER1" -t "BATCH_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -O "./benchmark/BATCH_1B_1replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "BATCH_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -O "./benchmark/BATCH_3B_3replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "BATCH_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2-O "./benchmark/BATCH_3B_3replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4" -t "BATCH_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 2 -R 2 -O "./benchmark/BATCH_4B_2replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4 BROKER5 BROKER6 BROKER7 BROKER8 BROKER9 BROKER10" -t "BATCH_SIZE" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2 -O "./benchmark/BATCH_10B_3replica_2partition"

./test-producer.sh -B "BROKER1" -t "TOPICS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -O "./benchmark/TOPICS_1B_1replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "TOPICS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -O "./benchmark/TOPICS_3B_3replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "TOPICS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2-O "./benchmark/TOPICS_3B_3replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4" -t "TOPICS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 2 -R 2 -O "./benchmark/TOPICS_4B_2replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4 BROKER5 BROKER6 BROKER7 BROKER8 BROKER9 BROKER10" -t "TOPICS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2 -O "./benchmark/TOPICS_10B_3replica_2partition"

./test-producer.sh -B "BROKER1" -t "NUM_ACKS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -O "./benchmark/ACKS_1B_1replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "NUM_ACKS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -O "./benchmark/ACKS_3B_3replica_1partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3" -t "NUM_ACKS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2-O "./benchmark/ACKS_3B_3replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4" -t "NUM_ACKS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 2 -R 2 -O "./benchmark/ACKS_4B_2replica_2partition"
./test-producer.sh -B "BROKER1 BROKER2 BROKER3 BROKER4 BROKER5 BROKER6 BROKER7 BROKER8 BROKER9 BROKER10" -t "NUM_ACKS" -z "jcr1.jcfernandez.cediant.es:2181,jcr2.jcfernandez.cediant.es:2181,jcr3.jcfernandez.cediant.es:2181" -r 3 -R 2 -O "./benchmark/ACKS_10B_3replica_2partition"

./html_producer.sh
