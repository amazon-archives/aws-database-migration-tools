import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job


args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
employees = glueContext.create_dynamic_frame.from_catalog(database = "hrdb", table_name = "glue_hrdata_employees", transformation_ctx = "datasource0")
departments = glueContext.create_dynamic_frame.from_catalog(database = "hrdb", table_name = "glue_hrdata_departments", transformation_ctx = "datasource1")
employees_departments = employees.join( ["DEPARTMENT_ID"],["DEPARTMENT_ID"], departments, transformation_ctx = "join")
print "Count Joined: ", employees_departments.count()

glueContext.write_dynamic_frame.from_jdbc_conf(frame = employees_departments,
catalog_connection = "rds-aurora-blog-conn",
connection_options = {"dbtable": "EMPLOYEES_DEPARTMENTS", "database": "HRDATA"})

job.commit()
