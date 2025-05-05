import re

SYMPTOMS = ["fever", "cough", "headache", "sore throat", "chills", "fatigue"]

def extract_info(text):
    text = text.lower()
    age_match = re.search(r"(\d{1,3}) years? old", text)
    name_match = re.search(r"patient ([a-zA-Z ]+?) is", text)
    symptoms = [s for s in SYMPTOMS if s in text]

    return {
        "name": name_match.group(1).title() if name_match else "Unknown",
        "age": int(age_match.group(1)) if age_match else None,
        "symptoms": symptoms
    }
