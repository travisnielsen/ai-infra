#!/usr/bin/env python3
"""
Simple test script for the FastAPI hello world application
"""
import requests
import time
import subprocess
import sys
import signal
import os

def test_api():
    """Test the FastAPI application endpoints"""
    base_url = "http://localhost:8000"
    
    print("Testing FastAPI endpoints...")
    
    try:
        # Test root endpoint
        response = requests.get(f"{base_url}/")
        print(f"GET / -> Status: {response.status_code}, Response: {response.json()}")
        
        # Test health endpoint
        response = requests.get(f"{base_url}/health")
        print(f"GET /health -> Status: {response.status_code}, Response: {response.json()}")
        
        # Test catch-all endpoint
        response = requests.get(f"{base_url}/some/random/path")
        print(f"GET /some/random/path -> Status: {response.status_code}, Response: {response.json()}")
        
        print("\nAll tests passed! ✓")
        
    except requests.exceptions.ConnectionError:
        print("Error: Could not connect to the API. Make sure it's running on http://localhost:8000")
        return False
    except Exception as e:
        print(f"Error testing API: {e}")
        return False
    
    return True

if __name__ == "__main__":
    # Start the FastAPI server in the background
    print("Starting FastAPI server...")
    proc = subprocess.Popen([
        sys.executable, "-c", 
        "import uvicorn; from main import app; uvicorn.run(app, host='0.0.0.0', port=8000)"
    ], cwd=os.path.dirname(os.path.abspath(__file__)))
    
    try:
        # Wait for server to start
        time.sleep(3)
        
        # Run tests
        test_api()
        
    finally:
        # Clean up
        print("\nShutting down server...")
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()