import os
import shutil
from PIL import Image
import argparse
import subprocess
import json
import hashlib

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compiler Script")
    parser.add_argument("--working-folder", type=str, default=os.path.dirname(os.path.realpath(__file__)), help="Folder containing input folder struct")
    parser.add_argument("--working-folder-full", type=str, help="Folder containing input folder struct (full path)")
    parser.add_argument("--output-folder", type=str, default="\\_compiled", help="Folder to output the final models and map")

    args = parser.parse_args()

    if args.working_folder_full is not None:
        args.working_folder = args.working_folder_full
    if not os.path.exists(args.working_folder):
        print(f"Error: Folder '{args.working_folder}' does not exist.")
        exit(1)

    args.output_folder = args.working_folder + args.output_folder


    for model_folder in os.listdir(args.working_folder):
        model_folder_path = os.path.join(args.working_folder, model_folder)
        if os.path.isdir(model_folder_path):
            subprocess.run([
                'py',
                os.path.dirname(os.path.realpath(__file__)) + '\\_resizer.py',
                '--working-folder', model_folder_path,
                '--output-folder', args.output_folder
            ])