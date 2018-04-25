#! /bin/sh
_SetEnv()
{
  SQLPLUS=/usr/lib/oracle/11.2/client64/bin/sqlplus
  AWS=/usr/bin/aws
  PSQL=/usr/bin/psql
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

_Download_And_Install_Ora2Pg()
{
  if [ $(whoami) = "ec2-user" ]; then

    sudo wget -P /home/ec2-user/ https://github.com/darold/ora2pg/archive/v18.1.tar.gz
    cd
    sudo gunzip v18.1.tar.gz
    sudo tar xvf v18.1.tar
    cd ora2pg-18.1/
    sudo perl Makefile.PL
    sudo sudo make
    sudo make install
  fi
}

_Setup_PostgreSQL_Environments()
{
  if [ $(whoami) = "ec2-user" ]; then
    cd;
    echo "export POSTGRES_HOME=/usr/lib64/pgsql92/" >> ~/.bashrc
    echo "export POSTGRES_INCLUDE=/usr/include/pgsql92/" >> ~/.bashrc
    source ~/.bashrc
  fi
}

_Check_Oracle_Sql_Connection()
{
  SQL_CON=`${SQLPLUS} -s ${ORA_USERNAME}/${ORA_PASSWORD}@${ORA_TNS_SID} <<< "select CURRENT_TIMESTAMP from dual;"`
  if ! [[  ${SQL_CON} == *"CURRENT_TIMESTAMP"* ]]; then
    echo "SQL Connection to Oracle database is NOT successful."
    echo "******** Exiting the setup script......"
    exit 0
  else
    echo "SQL Connection to Oracle database is successful....Continuing"
  fi
}

_Check_PostgreSql_Connection()
{
  export PGPASSWORD=${PG_PASSWORD}
  PSQL_CON=`${PSQL} --host=${PG_RDS_END_POINT} --port=5432 --username=${PG_USERNAME} --dbname=${PG_DBNAME} -c 'select current_timestamp'`
  if ! [[  ${PSQL_CON} == *"now"* ]]; then
    echo "SQL Connection to Postgresql database is NOT successful."
    echo "******** Exiting the setup script......"
    exit 0
  else
    echo "SQL Connection to Postgresql database is successful....Continuing"
  fi
}

_Create_User_And_Role_In_PostgreSQL()
{
  echo "Creating Postgres user/role "
  export PGPASSWORD=${PG_PASSWORD}
  PSQL_CON=`${PSQL} --host=${PG_RDS_END_POINT} --port=5432 --username=${PG_USERNAME} --dbname=${PG_DBNAME} -c "
  create role ${PG_MIGRATION_USER} with login password '${PG_MIGRATION_PASSWORD}';
  Grant ${PG_MIGRATION_USER} to ${PG_USERNAME};
  create schema ${PG_MIGRATION_SCHEMA};
  create schema ${PG_CONTROL_SCHEMA};
  grant all privileges on schema ${PG_MIGRATION_SCHEMA} to ${PG_MIGRATION_USER};
  grant all privileges on database ${PG_DBNAME} to ${PG_MIGRATION_USER};
  grant all privileges on schema ${PG_CONTROL_SCHEMA} to ${PG_MIGRATION_USER};"`
}

_Create_Ora2pg_Config_File_For_Schema()
{
  ORA2PG_CONF_FOR_SCHEMA="ora2pg_for_schema.conf"
  cd; touch ${ORA2PG_CONF_FOR_SCHEMA}
  echo "ORACLE_HOME     /usr/lib/oracle/11.2/client64" > ${ORA2PG_CONF_FOR_SCHEMA}
  echo "ORACLE_DSN      dbi:Oracle:sid=${ORA_TNS_SID}" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "ORACLE_USER     ${ORA_USERNAME}" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "ORACLE_PWD      ${ORA_PASSWORD}" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "DEBUG           1" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "EXPORT_SCHEMA   1" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "SCHEMA          ${ORA_USERNAME}" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "CREATE_SCHEMA   0" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "COMPILE_SCHEMA  0" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "PG_SCHEMA       ${PG_MIGRATION_SCHEMA}" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "TYPE            TABLE" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "OUTPUT          output_schema.sql" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "PG_DSN          dbi:Pg:dbname=${PG_DBNAME};host=${PG_RDS_END_POINT};port=5432" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "PG_USER         ${PG_MIGRATION_USER}" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "PG_PWD          ${PG_MIGRATION_PASSWORD}" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "BZIP2" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "DATA_LIMIT      400" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "BLOB_LIMIT      100" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "LONGREADLEN	6285312" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "LOG_ON_ERROR" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "JOBS            3" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "ORACLE_COPIES   3" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "PARALLEL_TABLES 1" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "DEFINED_PK      customer:c_custkey orders:o_orderkey region.r_regionkey nation.n_nationkey supplier.s_suppkey" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "DROP_INDEXES    1" >> ${ORA2PG_CONF_FOR_SCHEMA}
  echo "WITH_OID        1" >> ${ORA2PG_CONF_FOR_SCHEMA}

}

_Create_Ora2pg_Config_File_For_Copy()
{
  TABS=`for table in "$*"; do echo "$table"; done`
  echo ${TABS}
  FILE_TABS=`echo ${TABS// /_}`
  ORA2PG_CONF_FOR_COPY="ora2pg_for_copy_${FILE_TABS}.conf"
  cd; touch ${ORA2PG_CONF_FOR_COPY}
  echo "ORACLE_HOME     /usr/lib/oracle/11.2/client64" > ${ORA2PG_CONF_FOR_COPY}
  echo "ORACLE_DSN      dbi:Oracle:sid=${ORA_TNS_SID}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "ORACLE_USER     ${ORA_USERNAME}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "ORACLE_PWD      ${ORA_PASSWORD}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "DEBUG           1" >> ${ORA2PG_CONF_FOR_COPY}
  echo "EXPORT_SCHEMA   1" >> ${ORA2PG_CONF_FOR_COPY}
  echo "SCHEMA          ${ORA_USERNAME}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "CREATE_SCHEMA   0" >> ${ORA2PG_CONF_FOR_COPY}
  echo "COMPILE_SCHEMA  0" >> ${ORA2PG_CONF_FOR_COPY}
  echo "PG_SCHEMA       ${PG_MIGRATION_SCHEMA}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "TYPE            COPY" >> ${ORA2PG_CONF_FOR_COPY}
  echo "PG_DSN          dbi:Pg:dbname=${PG_DBNAME};host=${PG_RDS_END_POINT};port=5432" >> ${ORA2PG_CONF_FOR_COPY}
  echo "ALLOW           ${TABS}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "PG_USER         ${PG_MIGRATION_USER}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "PG_PWD          ${PG_MIGRATION_PASSWORD}" >> ${ORA2PG_CONF_FOR_COPY}
  echo "BZIP2" >> ${ORA2PG_CONF_FOR_COPY}
  echo "DATA_LIMIT      400" >> ${ORA2PG_CONF_FOR_COPY}
  echo "BLOB_LIMIT      100" >> ${ORA2PG_CONF_FOR_COPY}
  echo "LONGREADLEN	6285312" >> ${ORA2PG_CONF_FOR_COPY}
  echo "LOG_ON_ERROR" >> ${ORA2PG_CONF_FOR_COPY}
  echo "JOBS            3" >> ${ORA2PG_CONF_FOR_COPY}
  echo "ORACLE_COPIES   3" >> ${ORA2PG_CONF_FOR_COPY}
  echo "PARALLEL_TABLES 1" >> ${ORA2PG_CONF_FOR_COPY}
  echo "DEFINED_PK      customer:c_custkey orders:o_orderkey region.r_regionkey nation.n_nationkey supplier.s_suppkey" >> ${ORA2PG_CONF_FOR_COPY}
  echo "DROP_INDEXES    1" >> ${ORA2PG_CONF_FOR_COPY}
  echo "WITH_OID        1" >> ${ORA2PG_CONF_FOR_COPY}
}
_Generate_Schema_Structure()
{
  cd; source ~/.bashrc
  /usr/local/bin/ora2pg -c ~/ora2pg_for_schema.conf –d
  cat output_schema.sql | grep -v "CONSTRAINT" > ~/postgresql_schema.sql
}
_Create_Schema_In_PostgreSQL_Database()
{
  export PGPASSWORD=${PG_PASSWORD}
  PSQL_EXE=`${PSQL} --host=${PG_RDS_END_POINT} --port=5432 --username=${PG_USERNAME} --dbname=${PG_DBNAME} -f ~/postgresql_schema.sql`
  for tbl in `/usr/bin/psql -qAt --host=${PG_RDS_END_POINT} --port=5432 --username=${PG_USERNAME} --dbname=${PG_DBNAME} -c \
  "SELECT table_name  FROM information_schema.tables WHERE table_schema='${PG_MIGRATION_SCHEMA}' AND table_type='BASE TABLE'"`; \
  do  \
  S=`/usr/bin/psql --host=${PG_RDS_END_POINT} --port=5432 --username=${PG_USERNAME} --dbname=${PG_DBNAME} -c "alter table ${PG_MIGRATION_SCHEMA}.$tbl owner to ${PG_MIGRATION_USER}"`; \
  done
}
_Get_Current_SCN_From_Source_Oracle_DB()
{
  SCN_FILE="scn_information_from_source.out"
  touch ${SCN_FILE}
  SQL_CON=`${SQLPLUS} -s ${ORA_USERNAME}/${ORA_PASSWORD}@${ORA_TNS_SID} <<< "exec rdsadmin.rdsadmin_util.switch_logfile;"`
  SCN=`${SQLPLUS} -s ${ORA_USERNAME}/${ORA_PASSWORD}@${ORA_TNS_SID} <<< "select current_scn from v\\$database;"`
  SCN_NUM=`echo $SCN | awk '{print $3}'`
  echo "||******************************************************************************************||" >> ${SCN_FILE}
  echo "||******************************* Current SCN Number from RDS Oracle is : ${SCN_NUM} ***********||" > ${SCN_FILE}
  EXEC_SQL=`${SQLPLUS} -s ${ORA_USERNAME}/${ORA_PASSWORD}@${ORA_TNS_SID} <<< "select to_char(scn_to_timestamp($SCN_NUM)-(15/1440), 'YYYY-MM-DD HH24:MI:SS') as T from dual;"`
  TZ=`${SQLPLUS} -s ${ORA_USERNAME}/${ORA_PASSWORD}@${ORA_TNS_SID} <<< "select EXTRACT(TIMEZONE_HOUR FROM SYSTIMESTAMP)||':'|| EXTRACT(TIMEZONE_MINUTE FROM SYSTIMESTAMP) as TimeZone FROM dual;"`
  S=`echo ${EXEC_SQL}| awk '{print $3 " " $4}'`
  D=`date -d "${S}" "+%s000"`
  echo "||************Timestamp value affter subtracting 15 minutes is : ${S} *******||" >> ${SCN_FILE}
  echo ""
  echo "||******************************************************************************************||" >> ${SCN_FILE}
  echo "||******************************************************************************************||" >> ${SCN_FILE}
  echo "||********* TIME STAMP VALUE IN MILLISECONDS TO USE FOR DMS TASKS IS  : ${D} ******||" >> ${SCN_FILE}
  echo "||******************************************************************************************||" >> ${SCN_FILE}
  #echo $TZ >> ${SCN_FILE}
}

_Copy_Data_From_RDS_Oracle_To_RDS_PostgreSQL()
{
  nohup  time /usr/local/bin/ora2pg -c ~/ora2pg_for_copy_customer.conf  > ora2pg_aws_rds_oracle_to_pg_customer_blog.out &
  pid=$!
  echo "CUSTOMER TABLE COPY PID IS : "$pid >> ${SCN_FILE}

  nohup  time /usr/local/bin/ora2pg -c ~/ora2pg_for_copy_part.conf  > ora2pg_aws_rds_oracle_to_pg_part_blog.out &
  pid=$!
  echo "PART TABLE COPY PID IS : "$pid >> ${SCN_FILE}

  nohup  time /usr/local/bin/ora2pg -c ~/ora2pg_for_copy_supplier.conf  > ora2pg_aws_rds_oracle_to_pg_supplier_blog.out &
  pid=$!
  echo "SUPPLIER TABLE COPY PID IS : "$pid >> ${SCN_FILE}

  nohup  time /usr/local/bin/ora2pg -c ~/ora2pg_for_copy_region_nation.conf  > ora2pg_aws_rds_oracle_to_pg_region_nation_blog.out &
  pid=$!
  echo "REGION AND NATION TABLE COPY PID IS : "$pid >> ${SCN_FILE}

}
####MAIN#######

if [ "$#" -ne 10 ]; then
  echo "usage: setting_ora2pg_host_step2.sh <RDS_ORACLE_END_POINT> <ORA_TNS_SID> <PG_RDS_END_POINT> <PG_MASTER_USERNAME> <PG_MASTER_PASSWORD> <PG_DATABASE_NAME> <PG_MIGRATION_USER> \
       <PG_MIGRATION_PASSWORD>  <PG_MIGRATION_SCHEMA> <PG_CONTROL_SCHEMA>"
  exit 1
fi

ORA_USERNAME="awsorauser"
ORA_PASSWORD="awsorauser"
RDS_ORACLE_END_POINT="${1}"
ORA_TNS_SID="${2}"
PG_RDS_END_POINT="${3}"
PG_USERNAME="${4}"
PG_PASSWORD="${5}"
PG_DBNAME="${6}"
PG_MIGRATION_USER="${7}"
PG_MIGRATION_PASSWORD="${8}"
PG_MIGRATION_SCHEMA="${9}"
PG_CONTROL_SCHEMA="${10}"


_SetEnv
_Download_And_Install_Ora2Pg
_Setup_PostgreSQL_Environments
_Check_Oracle_Sql_Connection
_Check_PostgreSql_Connection
_Create_User_And_Role_In_PostgreSQL

_Create_Ora2pg_Config_File_For_Schema
# For CLOB table 1 - customer
_Create_Ora2pg_Config_File_For_Copy customer
# For CLOB table 2 - part
_Create_Ora2pg_Config_File_For_Copy part
# For table that is getting continuous transaction - supplier
_Create_Ora2pg_Config_File_For_Copy supplier
# For tables that are not getting any transactions (region & nation)
_Create_Ora2pg_Config_File_For_Copy region nation

_Generate_Schema_Structure
_Create_Schema_In_PostgreSQL_Database
_Get_Current_SCN_From_Source_Oracle_DB
_Copy_Data_From_RDS_Oracle_To_RDS_PostgreSQL