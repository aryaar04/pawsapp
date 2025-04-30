from pydantic import BaseModel

class UserSignup(BaseModel):
    name: str
    password: str

class UserLogin(BaseModel):
    name: str
    password: str

class CartItem(BaseModel):
    name: str
    price: str
    image: str

class AdoptDog(BaseModel):
    name: str
    image: str  # base64 encoded image string
