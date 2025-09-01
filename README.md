# Unreal Mod Manager (UMM) for Godot

A lightweight, easy-to-use mod manager built in **Godot 4.x**, designed to manage and install mods for your games. Manage local mod storage, configure mod settings, and launch your game directly from the manager.

---

## Features

- **Setup Guide on First Launch:** Automatically prompts you to configure paths for storage, game mods, and the game executable.  
- **Mod Management:**  
  - Lists all mods in your storage directory.  
  - Displays mod metadata (author and version) from `config.ini`.  
  - Checkbox interface to select mods for installation/uninstallation.  
- **Install/Uninstall Mods:** Automatically copy or remove mods from the game's mod directory.  
- **Game Launching:**  
  - Launch the game executable directly from the manager.  
  - Launch a Steam game via a `steam://launch/ID` link.  
- **File Browser Integration:** Easy selection of storage folder, game mods folder, and game executable.  
- **Persistent Settings:** Saves paths to `UMMSettings.json` so you don’t have to set them each time.  

---

## Requirements

- Godot 4.x  
- Target game with a local mods folder (or similar structure)  
- Windows (for `.exe` launching)  

---

## Setup

1. Clone or download this repository.  
2. Open the project in **Godot 4.x**.  
3. Run the project. On first launch, the **Setup Guide** will appear:  
   - **Storage Path:** Directory containing all your downloaded mods.  
   - **Game Mods Path:** Directory where the mods should be installed for the game.  
   - **Game Executable:** Path to the game `.exe`.  
4. Click **Save Settings** to store your configuration in `UMMSettings.json`.  

---

## How It Works

1. **Loading Mods:**  
   - The manager reads all directories in the storage path.  
   - Each mod directory should have a `config.ini` file containing `Author` and `Version`.  
   - Mods are displayed in a list with checkboxes indicating installed status.  

2. **Installing Mods:**  
   - Check the mods you want to install.  
   - Click **Install/Update Mods**.  
   - Selected mods are copied recursively from storage to the game mods folder.  
   - Unchecked mods are removed from the game mods folder if they exist.  

3. **Editing Mod Metadata:**  
   - Click the **Config Editor** button for a mod to create or edit its `config.ini`.  
   - Enter `Author` and `Version`, then save.
  
  **Example:**

```ini
[Mod]
Author="Cyn, Matt Crafts"
Version="1.0"

4. **Launching the Game:**  
   - Click **Launch Offline Game** to run the `.exe` directly.  
   - Click **Launch Game** to open the Steam version.  

---

## Notes

- Mods must each have a separate folder inside the storage directory.  
- `config.ini` is optional but recommended for metadata display.  
- Only works with games that allow local folder-based mod installation.  

---


