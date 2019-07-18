This is a python-based tool which helps automate the creation of JSON file for the table mappings section of AWS DMS.

This is a standalone program. No other supporting libraries are required. Python version 2.7 is required.

It takes the input in the form of csv file(s) and generates a single JSON file with required exclude and include actioned rule components. There can be multiple input files present in a particular folder. The only input to the tool is the folder location. All the files in this folder should have their names starting with include* and/or exclude*. This include or exclude depicts the content of that particular file should be included or excluded.
The content of the file is schema name and table name on each line separated by comma.

Example:

Lets assume folder location "/Users/TestUser/CSV_Files_For_DMS" contains two files named include_tables.csv and exclude_tables.csv.

The content of include_tables.csv is:
HR,EMPLOYEES 
HR,DEPARTMENTS 
HR,JOBS 
HR,LOCATIONS 
HR,REGIONS

The content of exclude_tables.csv is:
HR,EMPLOYEES_CHG_LOG 
HR,DEPARTMENTS_TEMP 
HR,JOBS_HISTORY 
HR,LOCATIONS_ARCHIVE 
HR,REGIONS_BACKUP

When you run this python program, provide the input as "/Users/TestUser/CSV_Files_For_DMS" when asked for the folder location.

