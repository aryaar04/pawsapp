import os
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["pawsdb"]

user_collection = db["users"]
cart_collection = db["cart"]
adopt_collection = db["adopt"]
