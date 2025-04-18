import os
import json
import paramiko
import tkinter as tk
from tkinter import messagebox
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import winshell  # To create shortcuts
import sys
from threading import Timer

# Load config file and set default values
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
DEFAULT_LANGS_PATH = os.path.normpath(os.path.join(SCRIPT_DIR, "../Langs"))
CONFIG_PATH = os.path.join(SCRIPT_DIR, "config.json")

# Default server path for language files
LANG_SERVER_PATH = "/cstrike/addons/amxmodx/data/lang/"

# Check and update the config file with `local_langs` if missing
if not os.path.exists(CONFIG_PATH):
    raise FileNotFoundError(f"Config file not found: {CONFIG_PATH}")

with open(CONFIG_PATH, "r") as f:
    config = json.load(f)

# Add default `local_langs` if it doesn't exist in the config
if "local_langs" not in config:
    config["local_langs"] = DEFAULT_LANGS_PATH
    with open(CONFIG_PATH, "w") as f:
        json.dump(config, f, indent=4)

MONITORED_FOLDER = config["monitored_folder"]  # Folder to monitor for `.amxx` files
LOCAL_LANGS = config["local_langs"]  # Folder to monitor for language files
ENSURE_WAIT_TIME = config.get("ensure_wait_time", 3)  # Default waiting time for "ensure" servers

STARTUP_FOLDER = os.path.join(os.environ["APPDATA"], "Microsoft\\Windows\\Start Menu\\Programs\\Startup")


def is_in_startup():
    """Check if the program is in the startup folder."""
    script_path = sys.argv[0]
    startup_script = os.path.join(STARTUP_FOLDER, os.path.basename(script_path).replace(".py", ".lnk"))
    return os.path.exists(startup_script)


def add_to_startup():
    """Add the program to the Windows startup folder."""
    script_path = sys.argv[0]
    shortcut_path = os.path.join(STARTUP_FOLDER, os.path.basename(script_path).replace(".py", ".lnk"))
    
    with winshell.shortcut(shortcut_path) as shortcut:
        shortcut.path = sys.executable
        shortcut.arguments = f'"{script_path}"'
        shortcut.working_directory = SCRIPT_DIR
        shortcut.description = "Auto start script for monitoring and uploading files"


def ask_to_add_startup():
    """Prompt the user to add the program to startup if not already added."""
    if not is_in_startup():
        root = tk.Tk()
        root.withdraw()  # Hide the main window
        if messagebox.askyesno("Add to Startup", "Do you want to add this program to auto startup?"):
            add_to_startup()
            messagebox.showinfo("Added to Startup", "The program has been added to auto startup.")
        root.destroy()


class FileChangeHandler(FileSystemEventHandler):
    def __init__(self, root, upload_file_callback):
        super().__init__()
        self.root = root
        self.upload_file_callback = upload_file_callback
        self.timers = {}  # Dictionary to store timers for each file
        self.stabilization_time = 1  # Time to wait for additional modifications (in seconds)

    def on_modified(self, event):
        """Handle file modification events."""
        if event.is_directory:
            return

        filepath = event.src_path
        filename = os.path.basename(filepath)

        if filepath.startswith(MONITORED_FOLDER) and filename.endswith(".amxx"):
            print(f"Modification detected for .amxx file: {filepath}")
            self.schedule_upload(filepath, amxx=True)
        elif filepath.startswith(LOCAL_LANGS):
            print(f"Modification detected for language file: {filepath}")
            self.schedule_upload(filepath, amxx=False)

    def schedule_upload(self, filepath, amxx):
        """Schedule the upload after a stabilization delay."""
        if filepath in self.timers:
            self.timers[filepath].cancel()

        timer = Timer(self.stabilization_time, self.handle_stable_file, [filepath, amxx])
        self.timers[filepath] = timer
        timer.start()

    def handle_stable_file(self, filepath, amxx):
        """Handle file after stabilization."""
        print(f"File stabilized: {filepath}")

        if filepath in self.timers:
            del self.timers[filepath]

        if amxx:
            self.root.after(0, self.ask_upload_confirmation, filepath)
        else:
            # Automatically upload language files to all servers
            for server in config["servers"]:
                self.upload_file_callback(filepath, server, LANG_SERVER_PATH)

    def ask_upload_confirmation(self, filepath):
        """Prompt user for upload confirmation for `.amxx` files."""
        filename = os.path.basename(filepath)

        # Calculate window height based on the number of servers
        window_height = 100 + len(config["servers"]) * 60
        selection_window = tk.Toplevel(self.root)
        selection_window.title("Select Server")
        selection_window.geometry(f"400x{window_height}")
        selection_window.attributes('-topmost', True)

        label = tk.Label(selection_window, text=f"Do you want to upload {filename}?", font=("Arial", 14))
        label.pack(pady=10)

        def create_server_button(server):
            def on_click():
                selection_window.destroy()
                if server.get("ensure", False):
                    self.root.after(0, self.show_ensure_window, filepath, server)
                else:
                    self.root.after(0, self.upload_file_callback, filepath, server, server["upload_path"])

            button = tk.Button(selection_window, text=server["name"], font=("Arial", 12, "bold"), command=on_click)
            button.pack(pady=10)

        for server in config["servers"]:
            create_server_button(server)

    def show_ensure_window(self, filepath, server):
        """Display a custom window with a countdown before upload."""
        popup = tk.Toplevel(self.root)
        popup.title("Upload Confirmation")
        popup.geometry("500x350")
        popup.attributes("-topmost", True)

        warning_label = tk.Label(popup, text="ARE YOU SURE?", fg="red", font=("Arial", 24, "bold"))
        warning_label.pack(pady=20)

        file_label = tk.Label(popup, text=f"File: {os.path.basename(filepath)}", font=("Arial", 14))
        file_label.pack(pady=10)

        server_label = tk.Label(popup, text=f"Server: {server['name']}", font=("Arial", 14, "bold"))
        server_label.pack(pady=10)

        countdown_label = tk.Label(popup, text=f"Please wait {ENSURE_WAIT_TIME} seconds...", font=("Arial", 16, "bold"))
        countdown_label.pack(pady=10)

        upload_button = tk.Button(popup, text="Upload", state=tk.DISABLED, font=("Arial", 14))
        upload_button.pack(pady=20)

        def countdown(time_left):
            if time_left > 0:
                countdown_label.config(text=f"Please wait {time_left} seconds...")
                popup.after(1000, countdown, time_left - 1)
            else:
                countdown_label.config(text="You can now upload!")
                upload_button.config(state=tk.NORMAL)

        countdown(ENSURE_WAIT_TIME)

        def confirm_upload():
            popup.destroy()
            self.upload_file_callback(filepath, server, server["upload_path"])

        upload_button.config(command=confirm_upload)

        cancel_button = tk.Button(popup, text="Cancel", command=popup.destroy, font=("Arial", 14))
        cancel_button.pack(pady=10)


def upload_file(filepath, server, upload_path):
    """Upload the file to the specified server path."""
    try:
        sftp_address = server["address"]
        sftp_port = server["port"]
        username = server["username"]
        password = server["password"]

        filename = os.path.basename(filepath)

        transport = paramiko.Transport((sftp_address, sftp_port))
        transport.connect(username=username, password=password)

        sftp = paramiko.SFTPClient.from_transport(transport)

        remote_path = os.path.join(upload_path, filename)
        print(f"Uploading {filename} to {remote_path} on {server['name']}")

        sftp.put(filepath, remote_path)

        sftp.close()
        transport.close()
        print(f"Uploaded {filename} to {server['name']}")

    except Exception as e:
        print(f"Failed to upload {filepath} to {server['name']}. Error: {str(e)}")


# Setup file monitoring
if __name__ == "__main__":
    root = tk.Tk()
    root.withdraw()

    ask_to_add_startup()

    handler = FileChangeHandler(root, upload_file)
    observer = Observer()
    observer.schedule(handler, MONITORED_FOLDER, recursive=False)
    observer.schedule(handler, LOCAL_LANGS, recursive=True)
    observer.start()

    try:
        root.mainloop()
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
