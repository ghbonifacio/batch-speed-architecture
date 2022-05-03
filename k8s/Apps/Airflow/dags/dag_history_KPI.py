# IMPORT LIBRARIES
from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.cncf.kubernetes.sensors.spark_kubernetes import SparkKubernetesSensor
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator

# DEFAULT SETTINGS APPLIED TO ALL TASKS
default_args = {
    "owner": "apFurlan",
    "depends_on_past": False,
    "start_date": datetime(2022, 4, 7),
    "email": ["airflow@airflow.com"],
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 0,
    "retry_delay": timedelta(minutes=5)
}

## DAG Crawler
with DAG(
    dag_id="dag_history_KPI",
    default_args=default_args,
    schedule_interval="0 1 7 * *", 
    tags=['sparkoperator', 'pipeline', 'cleaning'],
    catchup=True,
    description="Pipeline for Business time - Historical data"
) as dag:
        spark_app = SparkKubernetesOperator(
            task_id='call_spark_script',
            kubernetes_conn_id='connector_k8s_cluster',
            namespace='namespace_for_airflow_on_k8s',
            application_file='ConfigSpark-history.yaml',
            do_xcom_push=True
        )

        monitor_spark_app = SparkKubernetesSensor(
            task_id='monitor_spark_script',
            kubernetes_conn_id='connector_k8s_cluster',
            namespace='namespace_for_airflow_on_k8s',
            attach_log=True,
            application_name="{{ task_instance.xcom_pull(task_ids='call_spark_script')['metadata']['name'] }}",
        )

spark_app >> monitor_spark_app