#! /bin/sh
_SetEnv()
{
  SQLPLUS=/usr/lib/oracle/12.2/client64/bin/sqlplus
  AWS=/usr/bin/aws
  LSBLK=/bin/lsblk
}
_Check_If_SQL_Client_Files_Exist_And_Install()
{
 if [ $(whoami) = "ec2-user" ]; then
   if ! [[ "$(rpm -qa | grep -i oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64)" && "$(rpm -qa | grep -i oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64)" && "$(rpm -qa | grep -i oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64)" ]]; then
     if ! [[ -f /tmp/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm && -f /tmp/oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64.rpm && -f /tmp/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm ]]; then
        echo "Oracle client files are needed under /tmp location."
        echo "Required files are :"
        echo "1. oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm"
        echo "2. oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64.rpm"
        echo "3. oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm"
        echo "Download these files from http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html and upload to /tmp directory of this ec2 instance. Please note that you need to sign up to OTN to download these sql client files."
        exit 0
     else
        cd /tmp/
        sudo rpm -Uvh oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm
        sudo rpm -Uvh oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64.rpm
        sudo rpm -Uvh oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm
     fi
   fi
 fi
}

_Check_If_AWS_CLI_Is_Configured()
{
  AWS_CONFIGURE_OUTPUT=`aws configure list | grep access_key`
  if [[  ${AWS_CONFIGURE_OUTPUT} == *"not set"* ]]; then
    echo "Need to configure AWS CLI using 'aws configure' command. Please do that. - Note that region must be us-east-1"
    echo "******** Exiting the setup script......"
    exit 0
  fi
}

_SetUp_Oracle_Env_Settings()
{
  if [ $(whoami) = "ec2-user" ]; then
    cd;
    echo "export ORACLE_HOME=/usr/lib/oracle/12.2/client64/" >> .bashrc
    echo "export LD_LIBRARY_PATH=/usr/lib/oracle/12.2/client64/lib" >> .bashrc
    echo "export TNS_ADMIN=/usr/lib/oracle/12.2/client64/network/admin" >> .bashrc
    echo "export PATH=/usr/sbin:$PATH:/usr/lib/oracle/12.2/client64/bin" >> .bashrc
    source ~/.bashrc
    if [ ! -d $ORACLE_HOME/network/admin ]; then
      sudo mkdir -p $ORACLE_HOME/network/admin
    fi
    cd $ORACLE_HOME/network/admin
    sudo touch tnsnames.ora
    sudo chmod -R 757 tnsnames.ora
    sudo echo "${ORA_TNS_SID}=(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = ${RDS_ORACLE_END_POINT})(PORT = 1521))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = ${ORA_TNS_SID})))" > tnsnames.ora
  fi
}

_Create_Directory_Structure_In_Oracle_User()
{
  if [ $(whoami) = "ec2-user" ]; then
      cd;
      mkdir -p data-loading/log-files
      mkdir -p data-loading/control-files
      mkdir -p data-loading/sqlldr-fields
      mkdir -p data-loading/scripts
      mkdir -p data-loading/input-files/customer
      mkdir -p data-loading/input-files/supplier
      mkdir -p data-loading/create-ec2-volumes
  fi
}

_DownLoadRequiredScriptsFromS3Location()
{
  if [ $(whoami) = "ec2-user" ]; then
      ${AWS} s3 cp s3://${SCRIPTS_S3_BUCKET}/data-loading/scripts/ /home/ec2-user/data-loading/scripts/ --recursive
      ${AWS} s3 cp s3://${SCRIPTS_S3_BUCKET}/data-loading/input-files/ /home/ec2-user/data-loading/input-files/ --recursive
      ${AWS} s3 cp s3://${SCRIPTS_S3_BUCKET}/data-loading/sqlldr-fields/ /home/ec2-user/data-loading/sqlldr-fields/ --recursive
  fi
}

_Create_EC2Volumes_From_Snapshots_For_CLOB_Files()
{
  if [ $(whoami) = "ec2-user" ]; then
      ${AWS} ec2 create-volume --region us-east-1 --availability-zone ${EC2_INSTANCE_AVAILABILTY_ZONE} --snapshot-id snap-0f408cf70ec812229 --volume-type io1 --iops 1200 --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=oracle-client-for-rds-oracle-restored-volume1}]' --query VolumeId > oracle-client-for-rds-oracle-restored-volume1.volumeid
      wget http://169.254.169.254/latest/meta-data/instance-id
      VOL1=`cat oracle-client-for-rds-oracle-restored-volume1.volumeid|tr -d '"'`
      INSTANCE_ID=`cat instance-id`
      sudo mkdir /local/mnt6
      sleep 20
      ${AWS} ec2 attach-volume --volume-id ${VOL1} --instance-id ${INSTANCE_ID} --device /dev/xvdb
      sleep 20
      ${LSBLK} --noheadings --raw | awk '{print substr($0,0,4)}' | uniq -c | grep 1 | awk '{print "/dev/"$2}' > unmounted_volumes.txt
      cat unmounted_volumes.txt
      i=6
      for unmountedvolume in `cat unmounted_volumes.txt | sort`
      do
        sudo mount ${unmountedvolume} /local/mnt${i}
        sudo /bin/su -c "echo '${unmountedvolume} /local/mnt${i} ext4 defaults,nofail 0 2' >> /etc/fstab"
        i=$((i+1))
      done
      sudo mount -a
  fi
}

_Set_Archive_Supplemental_Logging()
{
  source ~/.bashrc
  LOG_LOCATION="enable_archive_supplemental_logging.out"
  touch ${LOG_LOCATION}
  SQL_CON=`${SQLPLUS} -s ${ORA_ROOT_USERNAME}/${ORA_ROOT_PASSWORD}@${ORA_TNS_SID} <<< "exec rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours',72);"`
  ARCGIVE_LOG_MODE=`${SQLPLUS} -s ${ORA_ROOT_USERNAME}/${ORA_ROOT_PASSWORD}@${ORA_TNS_SID} <<< "exec rdsadmin.rdsadmin_util.show_configuration;"`
  echo $ARCGIVE_LOG_MODE > ${LOG_LOCATION}
  SUPP_LOG_MODE=`${SQLPLUS} -s ${ORA_ROOT_USERNAME}/${ORA_ROOT_PASSWORD}@${ORA_TNS_SID} <<< "exec rdsadmin.rdsadmin_util.alter_supplemental_logging(p_action => 'ADD');"`
  echo $SUPP_LOG_MODE >> ${LOG_LOCATION}
}

####MAIN#######

if [ "$#" -ne 3 ]; then
  echo "usage: setting_oracle_client_host.sh <RDS_ORACLE_END_POINT> <EC2_INSTANCE_AVAILABILTY_ZONE> <DB_NAME>"
  exit 1
fi

ORA_ROOT_USERNAME="admin"
ORA_ROOT_PASSWORD="admin123"
ORA_TNS_SID="${3}"
RDS_ORACLE_END_POINT="${1}"
EC2_INSTANCE_AVAILABILTY_ZONE="${2}"
SCRIPTS_S3_BUCKET="aws-bigdata-blog/artifacts/awsora2pgblogfiles"
ORA_MIGRATION_TABLESPACE_NAME="AWSORA2PGTS"
ORA_MIGRATION_USERNAME="awsorauser"
ORA_MIGRATION_PWD="awsorauser"
CREATE_TABLE_FILE="/home/ec2-user/data-loading/scripts/create_tables.sql"

#_PreRequisites
_SetEnv
_Check_If_SQL_Client_Files_Exist_And_Install
_Check_If_AWS_CLI_Is_Configured
_SetUp_Oracle_Env_Settings
_Create_Directory_Structure_In_Oracle_User
_DownLoadRequiredScriptsFromS3Location
_Create_EC2Volumes_From_Snapshots_For_CLOB_Files
_Set_Archive_Supplemental_Logging
