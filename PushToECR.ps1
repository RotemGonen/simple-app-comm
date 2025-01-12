# Get AWS ECR credentials and login
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/v7s7u2x0

# Build the frontend app
docker build -t simple_cluster_frontend ./frontend

# Build the backend app
docker build -t simple_cluster_backend ./backend

# Tag the frontend app
docker tag simple_cluster_frontend public.ecr.aws/v7s7u2x0/simple_cluster:frontend

# Tag the backend app
docker tag simple_cluster_backend public.ecr.aws/v7s7u2x0/simple_cluster:backend

# Push the frontend app to ECR
docker push public.ecr.aws/v7s7u2x0/simple_cluster:frontend

# Push the backend app to ECR
docker push public.ecr.aws/v7s7u2x0/simple_cluster:backend