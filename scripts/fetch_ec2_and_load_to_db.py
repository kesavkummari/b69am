import boto3
import mysql.connector

# AWS credentials
aws_access_key_id = 'YOUR_AWS_ACCESS_KEY_ID'
aws_secret_access_key = 'YOUR_AWS_SECRET_ACCESS_KEY'
region_name = 'us-west-2'  # Replace with your desired region

# MySQL database configuration
mysql_host = 'localhost'
mysql_user = 'your_mysql_username'
mysql_password = 'your_mysql_password'
mysql_database = 'your_mysql_database'

# Connect to AWS EC2 service
ec2_client = boto3.client('ec2', region_name=region_name,
                          aws_access_key_id=aws_access_key_id,
                          aws_secret_access_key=aws_secret_access_key)

# Fetch EC2 instances data
response = ec2_client.describe_instances()
instances = response['Reservations']

# Connect to MySQL database
mysql_connection = mysql.connector.connect(
    host=mysql_host,
    user=mysql_user,
    password=mysql_password,
    database=mysql_database
)
mysql_cursor = mysql_connection.cursor()

# Create EC2 Instances table
create_table_query = """
CREATE TABLE IF NOT EXISTS ec2_instances (
    instance_id VARCHAR(50) PRIMARY KEY,
    instance_type VARCHAR(50),
    state VARCHAR(20),
    private_ip VARCHAR(20),
    public_ip VARCHAR(20)
)
"""
mysql_cursor.execute(create_table_query)

# Insert EC2 instances data into the table
insert_query = """
INSERT INTO ec2_instances (instance_id, instance_type, state, private_ip, public_ip)
VALUES (%s, %s, %s, %s, %s)
"""
for instance in instances:
    for i in instance['Instances']:
        instance_id = i['InstanceId']
        instance_type = i['InstanceType']
        state = i['State']['Name']
        private_ip = i['PrivateIpAddress'] if 'PrivateIpAddress' in i else None
        public_ip = i['PublicIpAddress'] if 'PublicIpAddress' in i else None

        data = (instance_id, instance_type, state, private_ip, public_ip)
        mysql_cursor.execute(insert_query, data)

mysql_connection.commit()

# Close the MySQL connection
mysql_cursor.close()
mysql_connection.close()
