# Sonic Racing CrossWorlds - Union Mod Manager (UMM)

A lightweight, easy-to-use mod manager for **Sonic Racing CrossWorlds**. Manage your mods, install/uninstall them easily, and launch your game all from one simple interface.

> ⚠ Note: The Config Editor is currently **non-functional**. Mods must have a `config.ini` manually created for metadata display.

---

## Features

- **Mod Management:**  
  - Lists all mods in your storage folder.  
  - Displays mod metadata (Author and Version) from `config.ini` (must be created manually).  
  - Checkbox interface to select mods for installation/uninstallation.  
- **Install/Uninstall Mods:** Automatically copy or remove mods from the game's mod folder.  
- **Game Launching:**  
  - Launch the game executable directly (**Offline Game**).  
  - Launch the Steam version of the game (**Online Game**).  
- **File Browser Integration:** Easily select the storage folder, game mods folder, and game executable.  
- **Persistent Settings:** Saves paths so you don’t have to set them each time.

---

## Requirements

- Windows or Linux
- Sonic Racing CrossWorlds installed  
- Mods stored in a folder on your PC  

---

## Quick Start

1. **Download the mod manager:** Get `UnionModManager.exe`.  
2. **Launch it:** Double-click the `.exe` to open the manager.  
3. **Setup paths on first launch:**  
   - **Storage Path:** Folder containing your downloaded mods.  
   - **Game Mods Path:** Folder where mods should be installed for the game.  
   - **Game Executable:** Path to the game `.exe`.  
4. Click **Save Settings** to store your configuration.  

---

## Using Mods

- **Installing/Updating Mods:**  
  - Check the mods you want to install.  
  - Click **Install/Update Mods**.  
  - Selected mods will be copied to the game folder.  
  - Unchecked mods will be removed from the game folder if they exist.

- **Config.ini Format:**  
  Since the Config Editor isn’t working yet, create a `config.ini` manually in each mod folder to display metadata:

```ini
[Mod]
Author="Cyn, Matt Crafts"
Version="1.0"
