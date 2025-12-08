from fastapi import FastAPI
from fastapi.responses import JSONResponse
import uvicorn

app = FastAPI(title="Hello World API", description="A simple FastAPI that returns hello world", version="1.0.0")

@app.get("/")
async def root():
    """Root endpoint that returns hello world"""
    return {"message": "hello world"}

@app.get("/{path:path}")
async def catch_all(path: str):
    """Catch-all endpoint that returns hello world for any GET request"""
    return {"message": "hello world", "path": path}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "message": "hello world"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)