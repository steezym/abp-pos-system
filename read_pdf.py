import sys
try:
    import fitz
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "PyMuPDF"])
    import fitz

def extract():
    pdf_path = r"C:\Users\mazmu\Downloads\ensemble.pdf"
    output_path = r"C:\Users\mazmu\Downloads\ensemble_text_fitz.txt"
    
    try:
        doc = fitz.open(pdf_path)
        with open(output_path, "w", encoding="utf-8") as f:
            for i, page in enumerate(doc):
                f.write(f"--- Page {i+1} ---\n")
                f.write(page.get_text() + "\n")
        print(f"Successfully extracted text to {output_path}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    extract()
