#!/bin/bash

export SPARK_HOME=
export PYSPARK_PYTHON=
export PYTHONPATH=$(ls -a ${SPARK_HOME}/python/lib/py4j-*-src.zip):${SPARK_HOME}/python:$PYTHONPATH
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook' pyspark
export PYSPARK_SUBMIT_ARGS="--packages com.amazonaws:aws-java-sdk-pom:1.11.244,org.apache.hadoop:hadoop-aws:2.7.4
pyspark-shell"
jupyter notebook

