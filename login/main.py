from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from database import user_collection, cart_collection, adopt_collection
from models import UserSignup, UserLogin, CartItem, AdoptDog

app = FastAPI()

# CORS for frontend connection
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========== AUTH ==========
@app.post("/signup")
def signup(user: UserSignup):
    if user_collection.find_one({"name": user.name}):
        raise HTTPException(status_code=400, detail="User already exists")
    user_collection.insert_one(user.dict())
    return {"message": "Signup successful"}

@app.post("/login")
def login(user: UserLogin):
    existing_user = user_collection.find_one({"name": user.name})
    if not existing_user or existing_user["password"] != user.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return {"message": "Login successful"}

# ========== CART ==========
@app.post("/add-to-cart")
def add_to_cart(item: CartItem):
    if cart_collection.find_one({"name": item.name}):
        raise HTTPException(status_code=400, detail="Item already in cart")
    cart_collection.insert_one(item.dict())
    return {"message": "Item added to cart"}

@app.get("/cart")
def get_cart():
    items = list(cart_collection.find({}, {"_id": 0}))
    return {"cart": items}

@app.delete("/remove-from-cart/{name}")
def remove_from_cart(name: str):
    result = cart_collection.delete_one({"name": name})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"message": "Item removed from cart"}

# ========== ADOPTION ==========
@app.post("/adopt/upload")
def upload_dog(dog: AdoptDog):
    if adopt_collection.find_one({"name": dog.name}):
        raise HTTPException(status_code=400, detail="Dog already listed")
    adopt_collection.insert_one(dog.dict())
    return {"message": "Dog added to adoption list"}

@app.get("/adopt/list")
def get_adopt_list():
    dogs = list(adopt_collection.find({}, {"_id": 0}))
    return {"dogs": dogs}

@app.delete("/adopt/{name}")
def adopt_dog(name: str):
    result = adopt_collection.delete_one({"name": name})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Dog not found")
    return {"message": "Dog adopted successfully"}
