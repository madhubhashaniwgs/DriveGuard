from fastapi import APIRouter

from database import db
from models.trip import TripCreate

router = APIRouter(
    prefix="/trips",
    tags=["Trips"],
)


@router.post("/")
def create_trip(trip: TripCreate):
    trip_document = trip.model_dump(mode="json")

    result = db.trips.insert_one(trip_document)

    return {
        "message": "Trip created successfully",
        "trip_id": trip.trip_id,
        "database_id": str(result.inserted_id),
    }