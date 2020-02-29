from s3contents import S3ContentsManager

c = get_config()

c.NotebookApp.contents_manager_class = S3ContentsManager
c.S3ContentsManager.bucket = "DEPLOYMENT_NAME-infra-notebooks"
c.S3ContentsManager.prefix = "jupyter"

c.NotebookApp.token = ''
