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

@router.get("/analytics/")
def get_trip_analytics():
    trips = list(db.trips.find())
    events = list(db.driving_events.find())

    total_trips = len(trips)

    # Total driving duration (all trips)
    total_duration = sum(
        trip.get("duration_seconds", 0)
        for trip in trips
    )

    # Trips that have distance metrics
    trips_with_distance = [
        trip for trip in trips
        if "distance_km" in trip
    ]

    # Total distance travelled
    total_distance = sum(
        float(trip.get("distance_km", 0) or 0)
        for trip in trips_with_distance
    )

    # Duration of trips with distance data
    distance_duration = sum(
        trip.get("duration_seconds", 0)
        for trip in trips_with_distance
    )

    # Average speed based on available GPS data
    average_speed = (
        total_distance / (distance_duration / 3600)
        if distance_duration > 0
        else 0.0
    )

    # Highest speed recorded across all trips
    max_speed = max(
        (
            float(trip.get("max_speed_kmh", 0) or 0)
            for trip in trips
        ),
        default=0.0,
    )

    smooth_trips = sum(
        1
        for trip in trips
        if trip.get("overall_status") == "Smooth Driving"
    )

    event_breakdown = {
        "suddenAcceleration": 0,
        "suddenBraking": 0,
        "harshTurn": 0,
    }

    for event in events:
        event_type = event.get("type")

        if event_type in event_breakdown:
            event_breakdown[event_type] += 1

    recent_trips = sorted(
        trips,
        key=lambda trip: trip.get("start_time", ""),
        reverse=True,
    )[:5]

    for trip in recent_trips:
        trip["_id"] = str(trip["_id"])

    return {
        "total_trips": total_trips,
        "total_driving_time_seconds": total_duration,
        "total_distance_km": round(total_distance, 2),
        "average_speed_kmh": round(average_speed, 1),
        "max_speed_kmh": round(max_speed, 1),
        "total_events": len(events),
        "smooth_trips": smooth_trips,
        "trips_with_events": total_trips - smooth_trips,
        "event_breakdown": event_breakdown,
        "recent_trips": recent_trips,
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

    
@router.get("/{trip_id}/events")
def get_driving_events(trip_id: str):

    trip = db.trips.find_one({"trip_id": trip_id})

    if trip is None:
        raise HTTPException(
            status_code=404,
            detail="Trip not found",
        )

    events = list(
        db.driving_events.find({"trip_id": trip_id})
    )

    for event in events:
        event["_id"] = str(event["_id"])

    return {
        "trip_id": trip_id,
        "events": events,
    }
