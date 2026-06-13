import sys
from PIL import Image

def remove_magenta(filepath):
    try:
        img = Image.open(filepath).convert("RGBA")
        data = img.getdata()
        
        new_data = []
        for item in data:
            # Check for pure magenta (or very close)
            # Magenta is R=255, G=0, B=255
            # We'll allow a tiny bit of tolerance for compression, e.g., R>240, G<15, B>240
            if item[0] > 240 and item[1] < 15 and item[2] > 240:
                new_data.append((0, 0, 0, 0)) # Transparent
            else:
                new_data.append(item)
                
        img.putdata(new_data)
        img.save(filepath, "PNG")
        print(f"Successfully processed {filepath}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    remove_magenta(sys.argv[1])
