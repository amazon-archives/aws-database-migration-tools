#! /bin/sh
_SetEnv()
{
  SQLPLUS=/usr/lib/oracle/11.2/client64/bin/sqlplus
  AWS=/usr/bin/aws
  PSQL=/usr/bin/psql
}

_Check_If_SQL_Client_Files_Exist_And_Install()
{
 if [ $(whoami) = "ec2-user" ]; then
   if ! [[ -f /tmp/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm && -f /tmp/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm && -f /tmp/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm ]]; then
      echo "Oracle client files are needed under /tmp location."
      echo "Required files are :"
      echo "1. oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm"
      echo "2. oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm"
      echo "3. oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm"
      echo "Download these files from http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html and upload to /tmp directory of this ec2 instance. Please note that you need to sign up to OTN to download these sql client files."
      echo "******** Exiting the setup script......"
      exit 0
   else
      cd /tmp/
      sudo rpm -Uvh oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
      sudo rpm -Uvh oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm
      sudo rpm -Uvh oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
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
    rm ~/.bashrc
    touch ~/.bashrc
    echo "export ORACLE_HOME=/usr/lib/oracle/11.2/client64/" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib" >> ~/.bashrc
    echo "export TNS_ADMIN=/usr/lib/oracle/11.2/client64/network/admin" >> ~/.bashrc
    echo "export PATH=/usr/sbin:$PATH:/usr/lib/oracle/11.2/client64/bin" >> ~/.bashrc
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

_InstallAndConfigureCPANAndInstallModules()
{
  if [ $(whoami) = "ec2-user" ]; then
    sudo yum install -y perl-CPAN
    sudo yum install -y perlbrew
    export PERL_MM_USE_DEFAULT=1
    export PERL_INSTALL_ROOT=/usr/lib64/perl5;
    echo "export PERL_MM_USE_DEFAULT=1" >> ~/.bashrc
    echo "export PERL_INSTALL_ROOT=/usr/lib64/perl5" >> ~/.bashrc
    source ~/.bashrc
    sudo yum -y install perl-DBI
    sudo yum -y install perl-YAML
    sudo yum -y install gcc
    source ~/.bashrc
    sudo yum install -y postgresql-server
    sudo yum install -y postgresql-devel
    sudo yum install -y perl-DBD-Pg

    echo "export POSTGRES_HOME=/usr/lib64/pgsql92/" >> ~/.bashrc
    echo "export POSTGRES_INCLUDE=/usr/include/pgsql92/" >> ~/.bashrc
    source ~/.bashrc
  fi
}

_Download_And_Install_OracleModule()
{
  if [ $(whoami) = "ec2-user" ]; then
    cd;
    sudo wget -P /home/ec2-user/ http://search.cpan.org/CPAN/authors/id/P/PY/PYTHIAN/DBD-Oracle-1.74.tar.gz
    cd
    sudo tar xzf DBD-Oracle-1.74.tar.gz
    cd DBD-Oracle-1.74/
    export ORACLE_HOME=/usr/lib/oracle/11.2/client64/
    export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib
    export TNS_ADMIN=/usr/lib/oracle/11.2/client64/network/admin
    export PERL_INSTALL_ROOT=/usr/lib64/perl5
    sudo -E bash -c 'echo $ORACLE_HOME'
    sudo -E bash -c 'echo $LD_LIBRARY_PATH'
    sudo -E perl Makefile.PL -V 11.2.0
    sudo -E make
    sudo -E make install
  fi
}
####MAIN#######

if [ "$#" -ne 2 ]; then
  echo "usage: setting_ora2pg_host_step1.sh <RDS_ORACLE_END_POINT> <ORA_DB_USER> "
  exit 1
fi

ORA_USERNAME="awsorauser"
ORA_PASSWORD="awsorauser"
RDS_ORACLE_END_POINT="${1}"
ORA_TNS_SID="${2}"

_SetEnv

_Check_If_SQL_Client_Files_Exist_And_Install
_Check_If_AWS_CLI_Is_Configured
_SetUp_Oracle_Env_Settings
_InstallAndConfigureCPANAndInstallModules