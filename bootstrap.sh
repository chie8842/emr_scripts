#!/bin/bash

today=`date '+%Y%m%d'`

sudo pip-3.4 install jupyter
sudo pip-3.4 install numpy

mkdir -p /home/hadoop/.jupyter

cat << EOS >> /home/hadoop/.jupyter/jupyter_notebook_config.py
c = get_config()
c.NotebookApp.ip = '*'
c.NotebookApp.port = 8080  # ポート番号
c.NotebookApp.token = 'test'  # ログイン時のパスワード
EOS

cat << EOS >> /home/hadoop/start-pyspark-jupyter.sh
#!/bin/bash

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook' pyspark
pyspark --conf 'spark.debug.maxToStringFields=1000' --conf 'spark.yarn.executor.memoryOverhead=1G' --packages com.databricks:spark-avro_2.11:4.0.0
EOS

# TODO: s3-dist-cpの--destで指定するプレフィックスにクラスタ名を入れる
cat << EOS >>  /mnt/var/lib/instance-controller/public/shutdown-actions/shutdown_action.sh
#!/bin/bash
set -e
s3-dist-cp --src /var/log/spark/apps --dest s3://bucket_name/sparkhistory/${today}
EOS

# sudo yum -y install gcc-c++ fuse fuse-devel libcurl-devel libxml2-devel openssl-devel git automake
# git clone https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs-fuse
# 
# cd /tmp/s3fs-fuse/
# ./autogen.sh
# ./configure --prefix=/usr
# sudo make install
# 
# mkdir /home/hadoop/s3fs
# 
# echo "***:***" | sudo tee -a /etc/passwd-s3fs
# sudo chmod 640 /etc/passwd-s3fs
# 
# sudo /usr/bin/s3fs bucket_name /home/hadoop/s3fs -o rw,allow_other,uid=hadoop,gid=hadoop,default_acl=public-read
exit 0

