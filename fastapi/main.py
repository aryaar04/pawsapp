from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import faiss
import pickle
from sentence_transformers import SentenceTransformer
import google.generativeai as genai

# --- Load files and models ---
index = faiss.read_index("vector.index")

with open("dog_data.pkl", "rb") as f:
    dog_knowledge = pickle.load(f)

embedding_model = SentenceTransformer("intfloat/e5-small")

# Replace with your own valid Gemini API key
genai.configure(api_key="AIzaSyDaUTsEoHyrex18ofPHxuJyzLttROZPpKk")

# --- FastAPI app ---
app = FastAPI()

# --- Enable CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Pydantic models ---
class QueryInput(BaseModel):
    query: str

class PromptInput(BaseModel):
    prompt: str

# --- Retrieve relevant Q&A from knowledge base ---
def retrieve_similar_questions(query, top_k=3):
    query_embedding = embedding_model.encode([query], convert_to_numpy=True)
    distances, indices = index.search(query_embedding, top_k)
    return [dog_knowledge[idx] for idx in indices[0]]

# --- Generate Gemini response using knowledge base ---
def generate_gemini_response(user_query):
    retrieved = retrieve_similar_questions(user_query)
    context = "\n".join([f"Q: {item['question']}\nA: {item['answer']}" for item in retrieved])
    prompt = f"""
Use the following dog-related knowledge base to answer the question:

{context}

User's Question: {user_query}

Provide a helpful and friendly answer.
"""
    model = genai.GenerativeModel("gemini-2.0-flash")
    response = model.generate_content(prompt)
    return response.text

# --- Endpoint using RAG (FAISS + Gemini) ---
@app.post("/ask")
async def ask_dog_bot(input_data: QueryInput):
    try:
        response = generate_gemini_response(input_data.query)
        return {"response": response}
    except Exception as e:
        print("❌ Error in /ask endpoint:", e)
        return {"response": "Server error occurred. Please try again later."}

# --- Direct Gemini Prompt Endpoint for Disease Descriptions ---
@app.post("/gemini_prompt")
async def direct_prompt(input_data: PromptInput):
    try:
        model = genai.GenerativeModel("gemini-2.0-flash")

        # New prompt format for short disease description
        concise_prompt = f"""
You are a veterinary assistant AI. Give a **short and concise** description of the dog disease named **"{input_data.prompt}"**. 
Avoid extra explanation or general advice. Just explain what the disease is in 2-3 sentences.
"""

        response = model.generate_content(concise_prompt)
        return {"response": response.text.strip()}
    except Exception as e:
        print("❌ Error in /gemini_prompt:", e)
        return {"response": "Error generating response"}
