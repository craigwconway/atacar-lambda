# Atacar Lambda

Generated static website with serverless admin module.

## Infrastructure Deployment

AWS infrastructure is created and maintained using [terraform](https://www.terraform.io/). 

Prerequisite for initial creation is an S3 bucket named ```atacar-terraform``` to use as the [backend](https://www.terraform.io/language/settings/backends/s3) for the terraform state file. (Bucket name is defined in ```providers.tf```)  

Configuration vairables including AWS [profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) are defined in ```variables.tf```.

To deploy the cloud infrastructure for the first time, the following commands are entered manually: 

```
terraform init
terraform plan
terraform apply
```

## Website generation

Static pages are generated from `data` and `templates` with the `admin.py` script.

```
python admin.py generate
```

## Code Deployment

After generating the website, copy the contents of the `static` folder to the S3 website bucket. 
Copy the contents of the `data` and `templates` folders to the S3 data bucket.

## Additional Configuration

In S3, change the metadata of `login.html` to redirect to the lambda endpoint.

```
x-amz-website-redirect-location: https://[lambda-endpoint]
```

## Data transformation

Existing database SQL dump data is converted to JSON with the `transform` script.

```
python transform.py
```