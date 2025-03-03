import boto3

def lambda_handler(event, context):
    rds = boto3.client('rds')
    primary_db_instance_id = event['detail']['SourceIdentifier']
    secondary_db_instance_id = event['detail']['SourceArn'].split(':')[-1]

    # Promote the secondary RDS to primary
    rds.promote_read_replica(
        DBInstanceIdentifier=secondary_db_instance_id
    )

    return {
        'statusCode': 200,
        'body': 'Secondary RDS promoted to primary'
    }