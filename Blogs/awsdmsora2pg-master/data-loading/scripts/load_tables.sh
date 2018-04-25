#! /bin/sh
_setEnv()
{
    SCRIPTS_HOME="/home/ec2-user/data-loading"
    MAILX=/bin/mailx
    RM="/bin/rm -rf"
    SQLLOADER=/usr/lib/oracle/12.2/client64/bin/sqlldr
    AWS=/usr/bin/aws
    S3_COPY="s3 cp"
    OUTPUT_FILE="${SCRIPTS_HOME}/log-files/${TABLE_NAME}_`date '+%Y-%m-%d-%H-%M-%S'`.out"
    CONTROL_FILE="CONTROL_FILE.CTL"
}

_insertIntoOracleTable()
{
        CONTROL_FILE=${SCRIPTS_HOME}/control-files/${TABLE_NAME}_${CONTROL_FILE}
        echo "LOAD DATA" > ${CONTROL_FILE}
        echo INFILE "'"${FILE_TO_LOAD}"'" >> ${CONTROL_FILE}
        echo APPEND INTO TABLE ${TABLE_NAME} >> ${CONTROL_FILE}
        echo FIELDS TERMINATED BY "'|'" >> ${CONTROL_FILE}

        if [ -f ${SCRIPTS_HOME}/sqlldr-fields/${TABLE_NAME}_table_fields.txt ]; then
            cat ${SCRIPTS_HOME}/sqlldr-fields/${TABLE_NAME}_table_fields.txt >> ${CONTROL_FILE}
        else
            exit
        fi
	      source ~/.bashrc
        ${SQLLOADER} ${ORA_USERNAME}/${ORA_PASSWORD}@${ORA_TNS_SID} control=${CONTROL_FILE} log=${SCRIPTS_HOME}/log-files/sqlldr_${TABLE_NAME}.log

        if [ "$?" = "0" ]; then
           echo "`date '+%Y-%m-%d-%H-%M-%S'` : File : Insert completed for the file : ${FILE_TO_LOAD}" >> ${OUTPUT_FILE}
           echo "=========================================================================" >> ${OUTPUT_FILE}
      	else
      	   echo "=====================================================================" >> ${OUTPUT_FILE}
      	   echo "******************* ERROR ::: NEW ROWS INSERTS FAILED ***************" >> ${OUTPUT_FILE}
      	   echo "=====================================================================" >> ${OUTPUT_FILE}
        fi
        CONTROL_FILE="CONTROL_FILE.CTL"
}

####MAIN#######

if [ "$#" -ne 5 ]; then
  echo "usage: load_tables.sh TABLE_NAME FILE_TO_LOAD ORA_USERNAME ORA_PASSWORD ORA_TNS_SID > load_tables_customer_tbl.100rows.log"
  exit 1
fi
TABLE_NAME="${1}"
FILE_TO_LOAD="${2}"
ORA_USERNAME="${3}"
ORA_PASSWORD="${4}"
ORA_TNS_SID="${5}"

_setEnv

echo "Staring Loading the data into oracle table"
_insertIntoOracleTable
echo "Completed Loading the data into oracle table"
