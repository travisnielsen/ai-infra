# Hello World FastAPI

A simple FastAPI application that returns "hello world" on any GET request.

## Features

- Returns "hello world" message on the root endpoint (`/`)
- Catches all GET requests to any path and returns "hello world"
- Health check endpoint at `/health`
- Containerized with Docker
- **Multi-platform support**: Available for both AMD64 and ARM64 architectures

## Running the Application

### Local Development

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the application:
   ```bash
   python main.py
   ```
   
   Or using uvicorn directly:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

3. Access the application:
   - API: http://localhost:8000
   - Interactive docs: http://localhost:8000/docs
   - Alternative docs: http://localhost:8000/redoc

### Docker

#### Single Platform Build (Local)

1. Build the image:
   ```bash
   docker build -t hello-world-api .
   ```

2. Run the container:
   ```bash
   docker run -p 8000:8000 hello-world-api
   ```

#### Multi-Platform Build

This application supports both AMD64 and ARM64 architectures. You can build for multiple platforms using Docker Buildx:

1. Create a buildx builder (one-time setup):
   ```bash
   docker buildx create --use --name multiarch
   ```

2. Build and push multi-platform image:
   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 -t your-username/hello-world-api:latest --push .
   ```

3. Build for specific platform only:
   ```bash
   # For AMD64 only (most cloud environments)
   docker buildx build --platform linux/amd64 -t your-username/hello-world-api:amd64 --push .
   
   # For ARM64 only
   docker buildx build --platform linux/arm64 -t your-username/hello-world-api:arm64 --push .
   ```

#### Using Pre-built Images

The application is available on Docker Hub with multi-platform support:

```bash
# Pull and run the latest multi-platform image
docker pull trniel/hello-world-api:latest
docker run -p 8000:8000 trniel/hello-world-api:latest

# Pull and run AMD64-specific image
docker pull trniel/hello-world-api:amd64
docker run -p 8000:8000 trniel/hello-world-api:amd64
```

## Platform Support

This application is built to support multiple architectures:

- **linux/amd64**: Intel/AMD 64-bit processors (most common in cloud environments)
- **linux/arm64**: ARM 64-bit processors (Apple Silicon, ARM-based cloud instances)

The multi-platform support ensures the application can run on various deployment targets including:
- Azure Container Apps
- Azure Kubernetes Service (AKS)
- AWS ECS/EKS
- Google Cloud Run/GKE
- Local development environments (Intel/AMD/Apple Silicon)

## Deployment

### Azure Container Registry

The image can be imported into Azure Container Registry for use with Azure services:

```bash
az acr import --name your-registry-name --source docker.io/trniel/hello-world-api:latest --image hello-world-api:latest
```

### Azure Container Apps

Use in Azure Container Apps with automatic platform selection:

```terraform
resource "azurerm_container_app" "hello_world" {
  # ... other configuration ...
  
  template {
    container {
      name  = "hello-world"
      image = "your-registry.azurecr.io/hello-world-api:latest"
      # ... other container configuration ...
    }
  }
}
```

## API Endpoints

- `GET /` - Returns hello world message
- `GET /{any-path}` - Returns hello world message for any path
- `GET /health` - Health check endpoint

## Example Responses

```json
{
  "message": "hello world"
}
```

For paths other than root:

```json
{
  "message": "hello world",
  "path": "some/path"
}
```