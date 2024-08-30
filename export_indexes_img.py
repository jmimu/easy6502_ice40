from PIL import Image

def export_color_indexes(image_path, output_path):
    img = Image.open(image_path)
    if img.mode != 'P':
        raise ValueError("Image is not in indexed mode")
    pixels = img.load()
    width, height = img.size
    with open(output_path, "w") as f:
        for y in range(height):
            for x in range(width):
                index = pixels[x, y]
                hex_index = f"{index:02X}"
                f.write(f"{hex_index} ")
            f.write("\n")

image_path = 'logo1.png'
output_path = 'indexes.txt'
export_color_indexes(image_path, output_path)

