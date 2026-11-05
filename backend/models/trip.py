from datetime import datetime

from pydantic import BaseModel


class TripCreate(BaseModel):
    trip_id: str
    start_time: datetime
    end_time: datetime
    duration_seconds: int
    overall_status: str
    event_count: int