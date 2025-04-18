import subprocess
import numpy as np
from rectpack import newPacker
from PIL import Image, ImageDraw
import os
import random
from prettytable import PrettyTable
import argparse
import tkinter as tk
from tkinter import Label, Entry, Button
import json
import copy

PREDEFINED_FILES = [
    "wood.bmp",
    "lower_body.bmp",
    "forearm.bmp",
    "barrel.bmp",
    "upper_body.bmp",
    "reticle.bmp",
    "handle.bmp",
    "magazine.bmp"
]

def error(message):
    print(f"\033[91m{message}\033[0m")

class Rectangle:
    def __init__(self, width, height, x, y, rotation=False):
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.rotation = rotation

def get_image_dimensions(file_list):
    dimensions = []
    for file in file_list:
        with Image.open(file) as img:
            dimensions.append((img.width, img.height))
    return dimensions

def save_packed_image(cordinates, output_file, side_length, images):
    canvas_width, canvas_height = side_length
    canvas = Image.new("RGB", (canvas_width, canvas_height), "white")
    draw = ImageDraw.Draw(canvas)
    image_data = {}

    for img in images:
        image_data[img] = None

    if images is None:
        for rect in cordinates:
            random_color = (
                random.randint(0, 255),
                random.randint(0, 255),
                random.randint(0, 255)
            )
            draw.rectangle([rect.x, rect.y, rect.x + rect.width, rect.y + rect.height], outline="black", width=2, fill=random_color)
    else:
        used_images = [False] * len(images)

        for rect in cordinates:
            for i, image_file in enumerate(images):
                if not used_images[i]:
                    img = Image.open(image_file)
                    original_size = img.size
                    rotated_size = (img.size[1], img.size[0])

                    if original_size == (rect.width, rect.height):
                        canvas.paste(img, (rect.x, rect.y))
                        used_images[i] = True
                        image_data[image_file] = Rectangle(width=rect.width, height=rect.height, x=rect.x, y=rect.y)
                        break
                    elif rotated_size == (rect.width, rect.height):
                        img = img.rotate(90, expand=True)
                        canvas.paste(img, (rect.x, rect.y))
                        used_images[i] = True
                        image_data[image_file] = Rectangle(width=rect.width, height=rect.height, x=rect.x, y=rect.y, rotation=True)
                        break
            else:
                error(f"No matching image found for rectangle {rect.width}x{rect.height} at ({rect.x}, {rect.y})")

    temp_file = output_file + ".temp"
    palette_file = output_file + ".pal.png" 
    canvas.save(temp_file, format="BMP")
    try:
        subprocess.run(
            [
                "ffmpeg",
                "-i", temp_file,
                "-vf",
                "palettegen=max_colors=256", palette_file
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        subprocess.run(
            [
                "ffmpeg", 
                "-i", temp_file,
                "-i", palette_file,
                "-lavfi",
                "paletteuse=dither=none",
                "-y", output_file
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError as e:
        print(f"Error in ffmpeg command: {e}")
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)
        if os.path.exists(palette_file):
            os.remove(palette_file)
    
    return image_data

def pack_to_smallest(cordinates, step=16):
    original_length = len(cordinates)
    smallest_length = None
    smallest_pack = None
    smallest_sum = 262144
    possible_smallest_width = max(width for width, height in cordinates)
    possible_smallest_height = max(height for width, height in cordinates)

    for width in range(possible_smallest_width, 1025, step):
        for height in range(possible_smallest_height, 1025, step):
            sum = width * height
            if sum > 262144:
                continue

            bins = [(width, height)]
            packer = newPacker()

            for r in cordinates:
                packer.add_rect(*r)

            for b in bins:
                packer.add_bin(*b)

            packer.pack()

            if len(packer[0]) == original_length and smallest_sum >= sum:
                smallest_sum = sum
                smallest_length = (width, height)
                smallest_pack = packer[0]
    
    return smallest_pack, smallest_length

def display_gui(scaling):
    root = tk.Tk()
    root.title("Rectangle Details")
    root.geometry("300x200+0+0")

    label_file = Label(root, text="File:")
    label_file.pack()

    text_file = Label(root, text="")
    text_file.pack()

    scale_width_entry = Entry(root)
    scale_height_entry = Entry(root)
    scale_offset_width_entry = Entry(root)
    scale_offset_height_entry = Entry(root)
    rotation_entry = Entry(root)

    scale_width_entry.pack()
    scale_height_entry.pack()
    scale_offset_width_entry.pack()
    scale_offset_height_entry.pack()
    rotation_entry.pack()

    scaling_length = len(scaling)
    current_index = [0]

    def update_fields():
        if current_index[0] >= scaling_length:
            print("All files have been viewed. Exiting GUI.")
            root.destroy()
            return

        file_name = list(scaling.keys())[current_index[0]]
        values = scaling[file_name]

        text_file.config(text=os.path.basename(file_name))
        scale_width_entry.delete(0, tk.END)
        scale_height_entry.delete(0, tk.END)
        scale_offset_width_entry.delete(0, tk.END)
        scale_offset_height_entry.delete(0, tk.END)
        rotation_entry.delete(0, tk.END)

        scale_width_entry.insert(0, f"{values[0]:.5f}")
        scale_height_entry.insert(0, f"{values[1]:.5f}")
        scale_offset_width_entry.insert(0, f"{values[2]:.5f}")
        scale_offset_height_entry.insert(0, f"{values[3]:.5f}")
        rotation_entry.insert(0, values[4])

    def next_file():
        current_index[0] += 1
        update_fields()

    button_next = Button(root, text="Next File", command=next_file)
    button_next.pack()

    update_fields()
    root.mainloop()

def calculate_scaling(image_data, image_length):
    table = PrettyTable()
    table.field_names = ["Image", "Size (WxH)", "Offset (X, Y)", "Scale modify (%)", "Move offset (%)", "Rotation"]
    scaling = {}

    for image, rect in image_data.items():
        scale_width = (rect.width / image_length[0])
        scale_height = (rect.height / image_length[1])
        offset_x = (rect.x / image_length[0])
        offset_y = (rect.y / image_length[1])

        table.add_row([
            os.path.basename(image),
            f"{rect.width}x{rect.height}",
            f"x-{rect.x}, y-{rect.y}",
            f"{scale_width:.5f}%, {scale_height:.5f}%",
            f"{offset_x:.5f}%, {offset_y:.5f}%",
            "-90°" if rect.rotation else "No"
        ])

        scaling[image] = (scale_width, scale_height, offset_x, offset_y, rect.rotation)
    return scaling

def bigify(image_files):
    rectangles = get_image_dimensions(image_files)

    rearranged, _ = pack_to_smallest(rectangles)
    scale_factor = 1.0
    if rearranged is None:
        print("Could not pack image.")

    print("Scaling up images to find smallest rectangle...")
    temp_rectangles = rectangles.copy()
    temp_rearranged = copy.deepcopy(rearranged)
    temp_smallest_length = None
    while True:
        scale_factor += 0.01
        temp_rectangles = [(int(width * scale_factor), int(height * scale_factor)) for width, height in rectangles]
        temp_rearranged, temp_smallest_length = pack_to_smallest(temp_rectangles)
        if temp_smallest_length is not None:
            print(f"Smallest rectangle found: {temp_smallest_length[0]}x{temp_smallest_length[1]} at scale factor {scale_factor:.2f}        ", end="\r")
        if temp_rearranged is None:
            scale_factor -= 0.01
            break

    print()
    # Scale up all images by the final scale factor
    if(scale_factor != 1.0):
        
        print(f"Final scale factor: {scale_factor:.2f}")
        scaled_images = []
        for image_file in image_files:
            with Image.open(image_file) as img:
                new_width = int(img.width * scale_factor)
                new_height = int(img.height * scale_factor)
                new_img = img.resize((new_width, new_height), Image.ANTIALIAS)
                scaled_images.append(new_img)

        # Save the scaled images
        for i, img in enumerate(scaled_images):
            output_path = os.path.join(args.working_folder, os.path.basename(image_files[i]))
            img.save(output_path)
            print(f"Saved scaled image: {output_path}")

    rectangles = get_image_dimensions(image_files)
    rearranged, smallest_length = pack_to_smallest(rectangles, step=1)
    print(f"Smallest rectangle found: {smallest_length[0]}x{smallest_length[1]} Density: {smallest_length[0] * smallest_length[1] / 262144.0 * 100.0:.2f}%")

    return rearranged, smallest_length

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Rectangle Packing Script")
    parser.add_argument("--disable-gui", default=False, action="store_true", help="Disable GUI")
    parser.add_argument("--working-folder", type=str, default=os.path.dirname(os.path.realpath(__file__)), help="Folder containing input images")
    parser.add_argument("--output-path", type=str, default="packed_result.png", help="Output file path (including file name)")
    parser.add_argument("--json-path", type=str, default=".", help="Path to the materials.json file")
    
    debug = False

    args = parser.parse_args()

    if debug:
        args.working_folder = "D:/herboy_skins/modeling/howtodopic/input/scripting/default_scout_0/lead"
        args.output_path = "a.bmp"
        args.json_path = "../"
        args.disable_gui = True

    os.chdir(args.working_folder)

    json_path = os.path.join(args.json_path, "materials.json")
    if not os.path.exists(json_path):
        error(f"materials.json not found in the working folder: {json_path}")
        exit(1)

    with open(json_path, 'r') as file:
        data = json.load(file)
    PREDEFINED_FILES = data.get("PREDEFINED_FILES", [])

    missing_files = [file for file in PREDEFINED_FILES if not os.path.exists(os.path.join(args.working_folder, file))]

    if missing_files:
        error("The following files are missing in the working folder:")
        for file in missing_files:
            full_path = os.path.join(args.working_folder, file)
            error(f"- {full_path}")
        exit(1)

    image_files = [os.path.join(args.working_folder, file) for file in PREDEFINED_FILES if os.path.exists(os.path.join(args.working_folder, file))]
    rearranged, image_length = bigify(image_files)
    image_data = save_packed_image(rearranged, args.output_path, image_length, image_files)
    scaling = calculate_scaling(image_data, image_length)

    if not args.disable_gui:
        display_gui(scaling)