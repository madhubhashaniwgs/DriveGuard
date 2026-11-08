
from datetime import datetime

from pydantic import BaseModel


class TripCreate(BaseModel):
    trip_id: str
    start_time: datetime
    end_time: datetime
    duration_seconds: int
    distance_km: float = 0.0
    average_speed_kmh: float = 0.0
    max_speed_kmh: float = 0.0
    overall_status: str
    event_count: int
