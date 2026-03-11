import pytest
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from app import app as flask_app

@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client

def test_home(client):
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert "message" in data
    assert data["message"] == "Hello from DevOps Project!"

def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"

def test_info(client):
    response = client.get("/info")
    assert response.status_code == 200
    data = response.get_json()
    assert "stack" in data
    assert "Flask" in data["stack"]
