from datetime import datetime

from pydantic import BaseModel


class DrivingEventCreate(BaseModel):
    type: str
    timestamp: datetime
    value: float