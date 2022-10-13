def read_s3(s3_client, bucket, file):
    response = s3_client.get_object(Bucket=bucket, Key=file)
    data = response["Body"].read().decode("utf-8")
    return data


def write_s3(s3_resource, bucket, file, data):
    Bucket = s3_resource.Bucket(bucket)
    Bucket.put_object(
        Key=file,
        Body=data,
        ContentType="text/html",
    )


def read_local(file):
    with open(file) as f:
        data = f.read()
    return data


def write_local(file, data):
    with open(file, "w") as f:
        f.write(data)
