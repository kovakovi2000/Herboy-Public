import os
import shutil
from PIL import Image
import argparse
import subprocess
import json
import hashlib

def error(message):
    print(f"\033[91m{message}\033[0m")

def read_lead_files(lead_folder):
    """Read .bmp files from the lead folder and their sizes."""
    lead_files = {}
    for filename in os.listdir(lead_folder):
        if filename.endswith('.bmp'):
            filepath = os.path.join(lead_folder, filename)
            with Image.open(filepath) as img:
                lead_files[filename] = img.size
    return lead_files

def process_skin_folders(skins_folder, lead_files, script_folder, texture_folder):
    """Check and resize .bmp files in skin folders to match the lead folder files."""
    for subfolder in os.listdir(skins_folder):
        subfolder_path = os.path.join(skins_folder, subfolder, "maps_8bit")
        print(f"Processing {subfolder_path}...")
        if os.path.isdir(subfolder_path):
            used_lead_files = set()
            for filename in os.listdir(subfolder_path):
                if filename.endswith('.bmp') and filename in lead_files:
                    used_lead_files.add(filename)
                    file_path = os.path.join(subfolder_path, filename)
                    with Image.open(file_path) as img:
                        # Ensure to close the file before attempting to write
                        img_size = img.size
                    if img_size != lead_files[filename]:
                        print(f"\rResizing {file_path} from {img_size} to {lead_files[filename]}...")
                        resize_and_save(file_path, lead_files[filename])

            unused_lead_files = set(lead_files.keys()) - used_lead_files
            if unused_lead_files:
                error("Unused lead files:")
                for unused_file in unused_lead_files:
                    error(f" - {unused_file}")
            
            print(f"packing {subfolder_path}.")
            output_path = os.path.join(texture_folder, "compiled", subfolder+".bmp")
            working_folder = os.path.join(texture_folder, subfolder_path)

            # print("----------------"+skins_folder+"-----------------")
            # print(f'py "{script_folder}\\_rearranger_.py" --disable-gui --working-folder "{working_folder}" --output-path "{output_path}" --json-path "{texture_folder}"')
            # print(f'\t--disable-gui --working-folder "{working_folder}"')
            # print(f'\t--output-path "{output_path}"')
            # print(f'\t--json-path "{texture_folder}"')
            # print("----------------------------------------")
            subprocess.run([
                'py',
                script_folder+'\_rearranger_.py',
                '--disable-gui',
                '--working-folder', working_folder,
                '--output-path', output_path,
                '--json-path', texture_folder
            ])
            print("----------------"+skins_folder+"-----------------")

def resize_and_save(file_path, new_size):
    """Resize and save the .bmp file to the specified size."""
    with Image.open(file_path) as img:
        img = img.resize(new_size, Image.ANTIALIAS)
        # Ensure the image remains 256-color BMP
        img = img.convert('P', palette=Image.ADAPTIVE, colors=256)
    # Save the image after closing the context manager
    img.save(file_path)

def generateSMDS(lead_smd, compiled_folder):
    """Generate .smd files for each .bmp file in the compiled folder."""
    with open(lead_smd, 'r') as file:
        lead_smd_content = file.read()

    for filename in os.listdir(compiled_folder):
        if filename.endswith('.bmp'):
            bmp_name = filename
            smd_name = os.path.splitext(bmp_name)[0] + '.smd'
            smd_path = os.path.join(compiled_folder, smd_name)
            new_smd_content = lead_smd_content.replace('a.bmp', bmp_name)
            with open(smd_path, 'w') as smd_file:
                smd_file.write(new_smd_content)
                print(f"Generated {smd_name}.")

def finalize(lead_smd, output_folder, lead_folder, compiled_folder, working_folder):
    """Finalize the process by copying and renaming files."""

    # Load predefined files from materials.json
    json_path = os.path.join(working_folder, 'materials.json')
    with open(json_path, 'r') as file:
        data = json.load(file)
        PREDEFINED_FILES = data.get("PREDEFINED_FILES", [])

    # Copy non-bmp and non-lead_smd files from lead_folder to output_folder
    for filename in os.listdir(lead_folder):
        if filename != os.path.basename(lead_smd) and filename not in PREDEFINED_FILES:
            src_path = os.path.join(lead_folder, filename)
            dst_path = os.path.join(output_folder, filename)
            if os.path.isdir(src_path):
                shutil.copytree(src_path, dst_path)
            else:
                shutil.copy2(src_path, dst_path)

    # Copy and rename files from compiled_folder to output_folder
    current_letter = -1
    current_second_letter = -1
    file_map = []

    for filename in os.listdir(compiled_folder):
        if filename.endswith('.smd'):
            bmp_name = os.path.splitext(filename)[0] + '.bmp'
            if bmp_name in os.listdir(compiled_folder):
                preset = "abcdefghijklmnopqrstuvwxyz0123456789"
                current_letter += 1
                if current_letter >= len(preset):
                    current_second_letter += 1
                    current_letter = 0
                new_name = ("" if current_second_letter == -1 else preset[current_second_letter]) + preset[current_letter]

                # Copy and rename .smd file
                smd_src_path = os.path.join(compiled_folder, filename)
                smd_dst_path = os.path.join(output_folder, os.path.splitext(filename)[0] + '.smd')
                with open(smd_src_path, 'r') as smd_file:
                    smd_content = smd_file.read().replace(bmp_name, new_name + '.bmp')
                with open(smd_dst_path, 'w') as smd_file:
                    smd_file.write(smd_content)

                # Copy and rename .bmp file
                bmp_src_path = os.path.join(compiled_folder, bmp_name)
                bmp_dst_path = os.path.join(output_folder, new_name + '.bmp')
                shutil.copy2(bmp_src_path, bmp_dst_path)

                # Add to file map
                print(f'studio "{os.path.splitext(filename)[0]}"')
                file_map.append(f'\tstudio "{os.path.splitext(filename)[0]}"')

    return file_map

def update_rc_file(file_map, working_folder):
    """Update the .rc file with the new file map."""
    qc_file_path = None
    for filename in os.listdir(working_folder):
        if filename.endswith('.qc'):
            qc_file_path = os.path.join(working_folder, filename)
            break

    if qc_file_path is None:
        error("No .rc file found in: " + working_folder)
        return
    if os.path.exists(qc_file_path):
        with open(qc_file_path, 'r') as rc_file:
            rc_content = rc_file.read()

        # Find the $bodygroup "weapon" { ... } section and replace its content
        start_index = rc_content.find('$bodygroup "weapon"')
        if start_index != -1:
            start_brace_index = rc_content.find('{', start_index)
            end_brace_index = rc_content.find('}', start_brace_index)
            if start_brace_index != -1 and end_brace_index != -1:
                new_bodygroup_content = '$bodygroup "weapon"\n{\n' + '\n'.join(file_map) + '\n}\n'
                rc_content = rc_content[:start_index] + new_bodygroup_content + rc_content[end_brace_index + 1:]
        else:
            error("No $bodygroup \"weapon\" section found in: " + qc_file_path)
            exit(1)

        # Write the updated content back to the .rc file
        with open(qc_file_path, 'w') as rc_file:
            rc_file.write(rc_content)

        return qc_file_path

def convert_qc_to_mdl(qc_file, output_folder, working_folder, current_folder, file_map, output_location):
    """Convert the .qc file to .mdl format using an external tool."""

    # Create a hash from file_map and store the first 6 characters
    file_map_str = ''.join(file_map)
    hash_object = hashlib.md5(file_map_str.encode())
    hash = hash_object.hexdigest()[:6]

    last_folder_name = os.path.basename(os.path.normpath(args.working_folder))
    print(f"Last folder name of the working folder: {last_folder_name}")

    # Delete all existing .mdl files from the output folder
    for filename in os.listdir(output_folder):
        if filename.endswith('.mdl'):
            mdl_path = os.path.join(output_folder, filename)
            os.remove(mdl_path)

    
    subprocess.run([
        current_folder+'\\studiomdl.exe',  # Replace with the actual command or tool you use for conversion
        qc_file
    ], cwd=output_folder)
    
    output_name = "v_" + last_folder_name + "_" + hash

    # Move the .mdl file to the output folder
    for filename in os.listdir(output_folder):
        if filename.endswith('.mdl'):
            mdl_src_path = os.path.join(output_folder, filename)
            mdl_dst_path = os.path.join(output_location, output_name + '.mdl')
            shutil.move(mdl_src_path, mdl_dst_path)
            break

    # Write file_map to a text file
    file_map_path = os.path.join(output_location, output_name + '.map')
    with open(file_map_path, 'w') as file_map_file:
        file_map_file.write(f'{output_name}.mdl\n')
        for line in file_map:
            file_map_file.write(line + '\n')

def process_mdl_files(working_folder):
    # Define the folder and executable paths
    skins_folder = working_folder+"/skins"
    decompmdl_executable = "../decompmdl.exe"

    # Load predefined files from materials.json
    json_path = os.path.join(working_folder, 'materials.json')
    with open(json_path, 'r') as file:
        data = json.load(file)
        PREDEFINED_FILES = data.get("PREDEFINED_FILES", [])

    # Check if the skins folder exists
    if not os.path.isdir(skins_folder):
        print(f"Error: Folder '{skins_folder}' does not exist.")
        return
    
    # Delete every folder inside skins_folder
    for item in os.listdir(skins_folder):
        item_path = os.path.join(skins_folder, item)
        if os.path.isdir(item_path):
            print(f"Deleting folder {item_path}...")
            for root, dirs, files in os.walk(item_path, topdown=False):
                for name in files:
                    os.remove(os.path.join(root, name))
                for name in dirs:
                    os.rmdir(os.path.join(root, name))
            os.rmdir(item_path)

    # Iterate through files in the folder
    for filename in os.listdir(skins_folder):
        # Check if the file has a .mdl extension
        if filename.endswith(".mdl"):
            file_path = os.path.join(skins_folder, filename)
            try:
                # Run the decompmdl command
                print(f"Processing {file_path}...")
                subprocess.run([decompmdl_executable, file_path, skins_folder], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

                # Get the file name without the extension
                file_name_without_ext = os.path.splitext(filename)[0]
                maps_8bit_folder = os.path.join(skins_folder, file_name_without_ext, "maps_8bit")

                # Check if the maps_8bit folder exists
                if not os.path.isdir(maps_8bit_folder):
                    error(f"Folder '{maps_8bit_folder}' does not exist.")
                    continue

                # Check for each predefined file in the maps_8bit folder
                for predefined_file in PREDEFINED_FILES:
                    predefined_file_path = os.path.join(maps_8bit_folder, predefined_file)
                    if not os.path.isfile(predefined_file_path):
                        error(f"Missing file: {predefined_file_path}")

            except subprocess.CalledProcessError as e:
                print(f"Error processing {file_path}: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Resizer Script")
    parser.add_argument("--working-folder", type=str, default=os.path.dirname(os.path.realpath(__file__))+"\\d_awp_0", help="Folder containing input folder struct")
    parser.add_argument("--working-folder-full", type=str, help="Folder containing input folder struct (full path)")
    parser.add_argument("--output-folder", type=str, help="Folder to output the final models and map")

    args = parser.parse_args()

    if args.working_folder_full is not None:
        args.working_folder = args.working_folder_full
    if not os.path.exists(args.working_folder):
        print(f"Error: Folder '{args.working_folder}' does not exist.")
        exit(1)

    if args.output_folder is None:
        args.output_folder = args.working_folder
    elif args.output_folder is not None and not os.path.exists(args.output_folder):
        print(f"Error: Folder '{args.output_folder}' does not exist.")
        exit(1)

    current_folder = os.path.dirname(os.path.realpath(__file__))

    os.chdir(args.working_folder)

    lead_folder = os.path.join(args.working_folder, "lead") 
    skins_folder = os.path.join(args.working_folder, "skins") 
    compiled_folder = os.path.join(args.working_folder, "compiled") 
    output_folder = os.path.join(args.working_folder, "output")
    lead_smd = None

    # Create compiled folder
    if not os.path.exists(compiled_folder):
        os.makedirs(compiled_folder)
    else:
        shutil.rmtree(compiled_folder)
        os.makedirs(compiled_folder)

    # Create output folder
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    else:
        shutil.rmtree(output_folder)
        os.makedirs(output_folder)

    if not os.path.exists(lead_folder):
        print(f"Lead folder '{lead_folder}' does not exist.")
    elif not os.path.exists(skins_folder):
        print(f"Skins folder '{skins_folder}' does not exist.")
    else:
        process_mdl_files(args.working_folder)

        for filename in os.listdir(lead_folder):
            if filename.endswith('_default.smd'):
                lead_smd = os.path.join(lead_folder, filename)
                break

        lead_files = read_lead_files(lead_folder)
        process_skin_folders(skins_folder, lead_files, current_folder, args.working_folder)

        # Generate .smd files
        if lead_smd is None:
            error("No file ending with '_default.smd' found in the lead folder.")
        else:
            generateSMDS(lead_smd, os.path.join(args.working_folder, compiled_folder))
        
        # Finalize the process in the output folder
        print(f"Copying compiled files to '{output_folder}' folder...")
        file_map = finalize(lead_smd, output_folder, lead_folder, compiled_folder, args.working_folder)
        qc_file = update_rc_file(file_map, os.path.join(args.working_folder, output_folder))
        convert_qc_to_mdl(qc_file, output_folder, args.working_folder, current_folder, file_map, args.output_folder)


    print("Processing complete.")
