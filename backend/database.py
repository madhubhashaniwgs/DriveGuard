import os

from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")
DATABASE_NAME = os.getenv("MONGODB_DATABASE", "driveguard")

if not MONGODB_URL:
    raise ValueError("MONGODB_URL is not configured")

client = MongoClient(MONGODB_URL)

db = client[DATABASE_NAME]