#! /bin/sh

_usage()
{
    echo "sh -x /home/ec2-user/data-loading/scripts/load_tables_supplier.sh /home/ec2-user/data-loading/input-files/supplier/only_supplier_files_tbl.1.lst supplier"
}
_setEnv()
{
    SCRIPTS_HOME="/home/ec2-user/data-loading"
    FILE_LOCATION="${SCRIPTS_HOME}/input-files/supplier"
    RM="/bin/rm -rf"
    SQLLOADER=/usr/lib/oracle/12.2/client64/bin/sqlldr
    AWS=aws
    S3_COPY="s3 cp"
    OUTPUT_FILE="${SCRIPTS_HOME}/log-files/${TABLE_NAME}_`date '+%Y-%m-%d-%H-%M-%S'`.out"
    CONTROL_FILE="CONTROL_FILE.CTL"
    i=1
}

_downloadAndInsertIntoOracle()
{
    while read -r line
    do
        FULLFILENAME=${FILE_LOCATION}/${line}
        echo "`date '+%Y-%m-%d-%H-%M-%S'` : Name read from file - ${FULLFILENAME}" >> ${OUTPUT_FILE}
        CONTROL_FILE=${SCRIPTS_HOME}/control-files/${TABLE_NAME}_${CONTROL_FILE}
	      echo "LOAD DATA" > ${CONTROL_FILE}
        echo INFILE "'"${FULLFILENAME}"'" >> ${CONTROL_FILE}
        echo INFILE "'"${FILE_TO_LOAD}"'" >> ${CONTROL_FILE}
        echo APPEND INTO TABLE ${TABLE_NAME} >> ${CONTROL_FILE}
        echo FIELDS TERMINATED BY "'|'" TRAILING NULLCOLS >> ${CONTROL_FILE}
        if [ -f ${SCRIPTS_HOME}/sqlldr-fields/${TABLE_NAME}_table_fields.txt ]; then
            cat ${SCRIPTS_HOME}/sqlldr-fields/${TABLE_NAME}_table_fields.txt >> ${CONTROL_FILE}
        else
            exit
        fi
	       source ~/.bashrc
        ${SQLLOADER} ${ORA_USERNAME}/${ORA_PASSWORD}@${ORA_TNS_SID} control=${CONTROL_FILE} log=${SCRIPTS_HOME}/log-files/sqlldr_${TABLE_NAME}.log

        if [ "$?" = "0" ]; then
           echo "`date '+%Y-%m-%d-%H-%M-%S'` : File ${i} : Insert completed for the file : ${FULLFILENAME}" >> ${OUTPUT_FILE}
	      else
      	   echo "=====================================================================" >> ${OUTPUT_FILE}
      	   echo "******************* ERROR ::: NEW ROWS INSERTS FAILED ***************" >> ${OUTPUT_FILE}
      	   echo "=====================================================================" >> ${OUTPUT_FILE}
        fi
        echo "=========================================================================" >> ${OUTPUT_FILE}
        CONTROL_FILE="CONTROL_FILE.CTL"
    done < "$FILE_TO_LOAD"
}
####MAIN#######

if [ "$#" -ne 5 ]; then
  echo "usage: load_tables_supplier.sh TABLE_NAME FILE_TO_LOAD ORA_USERNAME ORA_PASSWORD ORA_TNS_SID"
  exit 1
fi

TABLE_NAME="${1}"
FILE_TO_LOAD="${2}"
ORA_USERNAME="${3}"
ORA_PASSWORD="${4}"
ORA_TNS_SID="${5}"

_setEnv
echo "Staring Loading the data into oracle table"
_downloadAndInsertIntoOracle
echo "Completed Loading the data into oracle table"
