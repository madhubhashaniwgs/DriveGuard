from fastapi import APIRouter, HTTPException

from database import db
from models.driving_event import DrivingEventCreate
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

@router.get("/")
def get_trips():
    trips = list(db.trips.find())

    for trip in trips:
        trip["_id"] = str(trip["_id"])

    return {
        "trips": trips
    }


@router.get("/{trip_id}")
def get_trip(trip_id: str):
    trip = db.trips.find_one({"trip_id": trip_id})

    if trip is None:
        raise HTTPException(
            status_code=404,
            detail="Trip not found",
        )

    trip["_id"] = str(trip["_id"])

    return trip


@router.post("/{trip_id}/events")
def create_driving_event(
    trip_id: str,
    event: DrivingEventCreate,
):
    trip = db.trips.find_one({"trip_id": trip_id})

    if trip is None:
        raise HTTPException(
            status_code=404,
            detail="Trip not found",
        )

    event_document = event.model_dump(mode="json")
    event_document["trip_id"] = trip_id

    result = db.driving_events.insert_one(event_document)

    db.trips.update_one(
        {"trip_id": trip_id},
        {"$inc": {"event_count": 1}},
    )

    return {
        "message": "Driving event created successfully",
        "event_id": str(result.inserted_id),
        "trip_id": trip_id,
    }