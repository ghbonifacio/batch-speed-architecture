from pyspark.sql import SparkSession
from pyspark.sql.functions import DataFrame
import pyspark.sql.functions as F
import time, boto3
from datetime import datetime, timedelta, date
from delta.tables import *


def build_hive_ddl(
        table_name, object_schema, symlink_location, partition_cols=[], verbose=False):
    """
    :param table_name: the name of the table you want to register in the Hive metastore    
    :param object_schema: an instance of pyspark.sql.Dataframe.schema
    :param location: the storage location for this data (and S3 or HDFS filepath)
    :param partition_schema: an optional instance of pyspark.sql.Dataframe.schema that stores the
    columns that are used for partitioning on disk
    :param verbose:
    :return: None
    """
    columns = (
        ','.join(
            [field.simpleString() for field in object_schema if field.name not in partition_cols]
        )
    ).replace(':', ' ')
    
    partition_schema = (
    ','.join(
        [field.simpleString() for field in object_schema if field.name in partition_cols]
        )
    ).replace(':', ' ')
    
    ddl = 'CREATE EXTERNAL TABLE '+table_name+' ('\
        + columns + ')'\
        + (
              f" PARTITIONED BY ({partition_schema}) "
              if partition_schema else ''
          )\
        + " ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' " \
        + " STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.SymlinkTextInputFormat'" \
        + " OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'" \
        + f" LOCATION '{symlink_location}'"
    if verbose:
        print('Generated Hive DDL:\n'+ddl)
    return ddl


def run_athena_query(db_name, workgroup, query):

    response = athena.start_query_execution(
        QueryString=query,
        QueryExecutionContext={
            "Database": db_name,
            "Catalog": "AwsDataCatalog",
        },
        ResultConfiguration={
            'OutputLocation': 's3://bucket_name/for/outputs'
        },
        WorkGroup=workgroup
    )

    timout = 60
    while timout > 0:
        time.sleep(0.1)
        timout -= 0.1
        result = athena.get_query_execution(
            QueryExecutionId=response["QueryExecutionId"]
        )
        if result["QueryExecution"]["Status"]["State"] == "SUCCEEDED":
            break

    if result["QueryExecution"]["Status"]["State"] == "SUCCEEDED":
        output = athena.get_query_results(QueryExecutionId=response["QueryExecutionId"])
        return output
    else:
        print(result)
        raise "Not possible to run athena query"

def add_delta_2_athena(bucket_name, delta_path, db_name, workgroup, table_name, partition_cols = []):
    if len(
            run_athena_query(db_name,workgroup,f"SHOW TABLES LIKE '{table_name}';")['ResultSet']['Rows']
        ) > 0:
        print('Table already existis!')
        return
    else:
        
        delta_df = DeltaTable.forPath(
            spark, f's3a://{bucket_name}/{delta_path}'
        ).toDF()
            
        ddl = build_hive_ddl(
            f'{db_name}.{table_name}',
            delta_df.schema,
            f's3://{bucket_name}/{delta_path}/_symlink_format_manifest/',
            partition_cols
        )
        #print(ddl)
        run_athena_query(db_name,workgroup,ddl)
        # Repair Table
        run_athena_query(db_name,workgroup,f"MSCK REPAIR TABLE {table_name};")
        print('SUCCESS !!!!')


bucket_name = 'bronze-zone'
dbname = 'KPI-analyst_team'
workgroup = 'primary'


table_path = 'KPI/analyst_team/'
table_name = 'KPI-OCF' #Operating cash flow

full_load_path = f's3a://{bucket_name}/{table_path}'



stagingData = DeltaTable.forPath(spark, f's3a://{bucket_name}/{table_path}')
stagingData.generate("symlink_format_manifest")
add_delta_2_athena(bucket_name, table_path, dbname, workgroup, table_name)
