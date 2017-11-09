export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class

#Creating a directory for input data.
hadoop fs -mkdir /user/username/wordcount
hadoop fs -mkdir /user/username/wordcount/input
hadoop fs -copyFromLocal file01 /user/username/wordcount/input/file01
hadoop fs -copyFromLocal file02 /user/username/wordcount/input/file02

#Running the code
hadoop jar wc.jar WordCount /user/username/wordcount/input /user/username/wordcount/output

#Checking the output
hadoop fs -ls /user/username/wordcount/output/
hadoop fs -cat /user/username/wordcount/output/part-r-00000
hadoop fs -rmdir /user/username/wordcount/output
hadoop fs -rmr /user/username/wordcount/output
