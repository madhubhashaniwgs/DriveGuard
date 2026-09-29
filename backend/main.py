from fastapi import FastAPI

app = FastAPI(title="DriveGuard API")


@app.get("/")
def root():
    return {
        "message": "DriveGuard API is running!"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }