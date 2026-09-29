from fastapi import FastAPI

from database import client

app = FastAPI(title="DriveGuard API")


@app.get("/")
def root():
    return {
        "message": "DriveGuard API is running!"
    }


@app.get("/health")
def health_check():
    try:
        client.admin.command("ping")

        return {
            "status": "healthy",
            "database": "connected"
        }

    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }