import gradio as gr
import skops.io as sio
from skops.io import get_untrusted_types
import os

# Load the trained model
model_path = "./Model/drug_pipeline.skops"
if not os.path.exists(model_path):
    # Fallback for local development
    model_path = "../Model/drug_pipeline.skops"
if not os.path.exists(model_path):
    # Last fallback
    model_path = "./drug_pipeline.skops"

print(f"Looking for model at: {model_path}")
print(f"Current working directory: {os.getcwd()}")
print(f"Files in current directory: {os.listdir('.')}")

if os.path.exists(model_path):
    print(f"✅ Model found at: {model_path}")
    try:
        unknown_types = get_untrusted_types(file=model_path)
        print("Trusted types we're loading:", unknown_types)
        pipe = sio.load(model_path, trusted=unknown_types)
        print("✅ Model loaded successfully!")
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        pipe = None
else:
    print(f"❌ Model NOT found at: {model_path}")
    # List available paths for debugging
    for root, dirs, files in os.walk('.'):
        for file in files:
            if file.endswith('.skops'):
                print(f"Found .skops file: {os.path.join(root, file)}")
    pipe = None

def predict_drug(age, sex, blood_pressure, cholesterol, na_to_k_ratio):
    """
    Prediksi jenis obat berdasarkan karakteristik pasien
    """
    if pipe is None:
        return "❌ Error: Model tidak tersedia. Silakan cek log untuk detail."
    
    try:
        features = [age, sex, blood_pressure, cholesterol, na_to_k_ratio]
        predicted_drug = pipe.predict([features])[0]
        confidence = pipe.predict_proba([features])[0]
        max_confidence = max(confidence)
        
        label = f"🔬 Prediksi Obat: {predicted_drug}"
        confidence_text = f"📊 Confidence: {max_confidence:.2%}"
        
        return f"{label}\n{confidence_text}"
    except Exception as e:
        return f"❌ Error dalam prediksi: {str(e)}"

# Define input components
inputs = [
    gr.Slider(15, 74, step=1, value=30, label="🎂 Umur (Age)"),
    gr.Radio(["M", "F"], value="M", label="👤 Jenis Kelamin (Sex)"),
    gr.Radio(["HIGH", "NORMAL", "LOW"], value="NORMAL", label="🩸 Tekanan Darah (Blood Pressure)"),
    gr.Radio(["HIGH", "NORMAL"], value="NORMAL", label="🧪 Kolesterol (Cholesterol)"),
    gr.Slider(6.2, 38.2, step=0.1, value=15.4, label="⚖️ Rasio Na_to_K"),
]

outputs = [gr.Textbox(label="Hasil Prediksi", lines=3)]

# Example cases for testing
examples = [
    [30, "M", "HIGH", "NORMAL", 15.4],
    [35, "F", "LOW", "NORMAL", 20.5],
    [50, "M", "HIGH", "HIGH", 34.0],
    [25, "F", "NORMAL", "HIGH", 25.3],
    [60, "M", "LOW", "NORMAL", 12.8],
]

title = "🏥 Sistem Klasifikasi Obat - MLOps CI/CD Practice"
description = """
### 📋 Cara Penggunaan:
Masukkan karakteristik pasien di bawah ini untuk mendapatkan prediksi jenis obat yang sesuai.

**Fitur Input:**
- **Umur**: 15-74 tahun
- **Jenis Kelamin**: M (Male) atau F (Female)  
- **Tekanan Darah**: HIGH, NORMAL, atau LOW
- **Kolesterol**: HIGH atau NORMAL
- **Rasio Na_to_K**: 6.2-38.2
"""

article = """
### 🚀 Tentang Aplikasi Ini
Aplikasi ini merupakan implementasi **MLOps CI/CD Pipeline** untuk klasifikasi obat menggunakan:
- **Machine Learning**: RandomForest Classifier
- **CI/CD**: GitHub Actions untuk otomatisasi
- **Deployment**: Hugging Face Spaces
- **Model Format**: scikit-learn dengan skops

**Pipeline Otomatis:**
1. 📊 Data Processing & Training
2. 🧪 Model Testing & Validation  
3. 🚀 Automatic Deployment
4. 📈 Monitoring & Updates

Dibuat sebagai bagian dari pembelajaran **Machine Learning Operations (MLOps)**.
"""

# Create and launch the interface
iface = gr.Interface(
    fn=predict_drug,
    inputs=inputs,
    outputs=outputs,
    examples=examples,
    title=title,
    description=description,
    article=article,
    theme=gr.themes.Soft(),
    analytics_enabled=False,
)

if __name__ == "__main__":
    iface.launch()