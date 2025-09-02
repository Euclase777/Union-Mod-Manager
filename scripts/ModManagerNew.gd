extends Control

const CONFIG_FILE: String = "UMMSettings.json"

@onready var storage_path_edit: LineEdit = $TabContainer/Settings/HBoxContainer/LineEdit
@onready var storage_browse_btn: Button = $TabContainer/Settings/HBoxContainer/Button
@onready var storage_open_btn: Button = $TabContainer/Settings/HBoxContainer/Button2
@onready var game_path_edit: LineEdit = $TabContainer/Settings/HBoxContainer2/LineEdit
@onready var game_browse_btn: Button = $TabContainer/Settings/HBoxContainer2/Button
@onready var game_open_btn: Button = $TabContainer/Settings/HBoxContainer2/Button2
@onready var ue4ss_path_edit: LineEdit = $TabContainer/Settings/HBoxContainer5/LineEdit
@onready var ue4ss_browse_btn: Button = $TabContainer/Settings/HBoxContainer5/Button
@onready var exe_path_edit: LineEdit = $TabContainer/Settings/HBoxContainer4/LineEdit
@onready var exe_browse_btn: Button = $TabContainer/Settings/HBoxContainer4/Button
@onready var save_settings_btn: Button = $TabContainer/Settings/HBoxContainer3/Button
@onready var mods_list: VBoxContainer = $TabContainer/Mods/ScrollContainer/VBoxContainer
@onready var install_button: Button = $TabContainer/Mods/HBoxContainer/Button3
@onready var refresh_button: Button = $TabContainer/Mods/HBoxContainer/Button2
@onready var launch_button: Button = $TabContainer/Mods/HBoxContainer/Button4
@onready var launch_game_online: Button = $TabContainer/Mods/HBoxContainer/Button5


var mod_context_menu: PopupMenu
var context_mod_path: String = ""
var mod_checkboxes: Dictionary[String, CheckBox] = {}
var storage_path: String = ""
var game_mods_path: String = ""
var ue4ss_mods_path: String = ""  
var game_exe: String = ""

func _ready() -> void:
	var config_path = get_config_path()
	if not FileAccess.file_exists(config_path):
		# First boot – open setup guide
		show_setup_guide()
	else:
		# Normal flow
		load_settings()
	# Load saved paths (if any) and build UI
	load_settings()
	refresh_mod_list()

	# Connect signals
	storage_browse_btn.pressed.connect(_on_browse_storage)
	game_browse_btn.pressed.connect(_on_browse_game)
	exe_browse_btn.pressed.connect(_on_browse_exe)
	ue4ss_browse_btn.pressed.connect(_on_browse_ue4ss)
	save_settings_btn.pressed.connect(_on_save_settings)
	install_button.pressed.connect(_on_install_pressed)
	refresh_button.pressed.connect(refresh_mod_list)
	launch_button.pressed.connect(_on_launch_pressed)
	launch_game_online.pressed.connect(_on_online_launch_pressed)
	storage_open_btn.pressed.connect(_on_storage_open_pressed)
	game_open_btn.pressed.connect(_on_mods_open_pressed)
	#ue4ss_open_btn.pressed.connect(_on_ue4ss_open_pressed)
	#exe_open_btn.pressed.connect(_on_exe_open_pressed)

	# Build context menu
	mod_context_menu = PopupMenu.new()
	mod_context_menu.add_item("Open Config", 0)
	mod_context_menu.add_item("Open Folder", 1)
	mod_context_menu.id_pressed.connect(_on_mod_context_action)
	add_child(mod_context_menu)


func show_setup_guide():
	$Window.popup()

# -------------------------
# Settings load/save
# -------------------------

func get_config_path() -> String:
	var exe_dir: String = OS.get_executable_path().get_base_dir()
	return exe_dir.path_join(CONFIG_FILE)

func load_settings() -> void:
	var config_path = get_config_path()
	if FileAccess.file_exists(config_path):
		var f: FileAccess = FileAccess.open(config_path, FileAccess.READ)
		if f:
			var text: String = f.get_as_text()
			f.close()
			var parse_result: Variant = JSON.parse_string(text)
			if typeof(parse_result) == TYPE_DICTIONARY:
				var data: Dictionary = parse_result
				storage_path = str(data.get("storage_path", ""))
				game_mods_path = str(data.get("game_mods_path", ""))
				ue4ss_mods_path = str(data.get("ue4ss_mods_path", ""))
				game_exe = str(data.get("game_exe_path", ""))
	storage_path_edit.text = storage_path
	game_path_edit.text = game_mods_path
	ue4ss_path_edit.text = ue4ss_mods_path
	exe_path_edit.text = game_exe

func _on_save_settings() -> void:
	storage_path = storage_path_edit.text.strip_edges()
	game_mods_path = game_path_edit.text.strip_edges()
	ue4ss_mods_path = ue4ss_path_edit.text.strip_edges()
	game_exe = exe_path_edit.text.strip_edges()

	var config_path = get_config_path()
	var f: FileAccess = FileAccess.open(config_path, FileAccess.WRITE)
	if f:
		var out: Dictionary = {
			"storage_path": storage_path,
			"game_mods_path": game_mods_path,
			"ue4ss_mods_path": ue4ss_mods_path,
			"game_exe_path": game_exe
		}
		f.store_string(JSON.stringify(out))
		f.flush()
		f.close()
		print("Settings saved to ", config_path)

	# --- NEW: create steam_appid.txt next to exe ---
	if game_exe != "":
		var exe_dir := game_exe.get_base_dir()
		var appid_path := exe_dir.path_join("steam_appid.txt")
		if not FileAccess.file_exists(appid_path):
			var file := FileAccess.open(appid_path, FileAccess.WRITE)
			if file:
				file.store_string("480")
				file.close()
				print("steam_appid.txt created at: ", appid_path)
			else:
				printerr("Failed to create steam_appid.txt at: ", appid_path)

	refresh_mod_list()



# -------------------------
# Browse folders (FileDialog)
# -------------------------
func _on_browse_storage() -> void:
	var fd: FileDialog = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.use_native_dialog = true
	add_child(fd)
	fd.dir_selected.connect(func(path: String) -> void:
		storage_path_edit.text = path
		fd.queue_free()
	)
	fd.popup_centered()

func _on_browse_game() -> void:

	var fd: FileDialog = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.use_native_dialog = true
	add_child(fd)
	fd.dir_selected.connect(func(path: String) -> void:
		game_path_edit.text = path
		fd.queue_free()
	)
	fd.popup_centered()
 
func _on_browse_ue4ss() -> void:

	var fd: FileDialog = FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.use_native_dialog = true
	add_child(fd)
	fd.dir_selected.connect(func(path: String) -> void:
		ue4ss_path_edit.text = path
		fd.queue_free()
	)
	fd.popup_centered()

func _on_browse_exe() -> void:
	var fd := FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE # <-- allow selecting a single file
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.filters = ["*.exe ; Executable files"] # optional, restrict to .exe
	fd.use_native_dialog = true
	add_child(fd)
	
	# Connect the file_selected signal instead of dir_selected
	fd.file_selected.connect(func(path: String) -> void:
		exe_path_edit.text = path
		fd.queue_free()
	)
	
	fd.popup_centered()

# -------------------------
# Build & refresh mods list
# -------------------------
func refresh_mod_list() -> void:
	# clear existing children safely
	for child: Node in mods_list.get_children():
		child.queue_free()
	mod_checkboxes.clear()

	if storage_path == "" or not DirAccess.dir_exists_absolute(storage_path):
		return

	var dir: DirAccess = DirAccess.open(storage_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var mod_path = storage_path + "/" + file_name
			var meta = load_mod_metadata(mod_path)

			var row := HBoxContainer.new()

			var cb := CheckBox.new()
			cb.text = file_name

			# --- Only change: UE4SS-aware install check ---
			var use_ue4ss: bool = meta.get("ue4ss", false)
			var install_path: String = ""
			if use_ue4ss:
				if ue4ss_mods_path != "":
					install_path = ue4ss_mods_path + "/" + file_name
			else:
				if game_mods_path != "":
					install_path = game_mods_path + "/" + file_name

			if install_path != "" and DirAccess.dir_exists_absolute(install_path):
				cb.button_pressed = true
			# --- End change ---

			row.add_child(cb)

			var version_label := Label.new()
			version_label.text = meta["version"]
			version_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			version_label.add_theme_constant_override("margin_left", 20)
			row.add_child(version_label)

			var author_label := Label.new()
			author_label.text = meta["author"]
			author_label.add_theme_constant_override("margin_left", 20)
			row.add_child(author_label)

			var spacer := Control.new()
			row.add_child(spacer)
			mods_list.add_child(row)
			mod_checkboxes[file_name] = cb
		file_name = dir.get_next()
	dir.list_dir_end()



# GUI input handler for each row (bound with the mod_path)
func _on_row_gui_input(bound_mod_path: String, event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	if event.button_index != MOUSE_BUTTON_RIGHT or not event.pressed:
		return

	# store which mod we clicked
	context_mod_path = bound_mod_path

	# Compute coordinates in the PopupMenu parent's local space
	var parent_ctrl: Control = mod_context_menu.get_parent() as Control
	var mouse_pos: Vector2 = get_global_mouse_position()                    # global screen coords
	var local_pos: Vector2 = parent_ctrl.to_local(mouse_pos)               # local to menu parent

	# small offset so the menu doesn't overlap the cursor
	var offset: Vector2 = Vector2(12, 12)

	# Build the tiny rect for popup() — coordinates must be in parent's local space
	var popup_rect: Rect2 = Rect2(local_pos + offset, Vector2(1, 1))

	# Make sure size is calculated, then popup
	mod_context_menu.reset_size()
	mod_context_menu.popup(popup_rect)


func _on_mod_context_action(id: int) -> void:
	match id:
		0: # Open Config
			open_config_editor(context_mod_path)
		1: # Open Folder
			OS.shell_open(ProjectSettings.globalize_path(context_mod_path))


func open_config_editor(mod_path: String) -> void:
	var popup := Window.new()
	popup.title = "Create Config.ini"
	popup.size = Vector2(400, 250)
	popup.transparent_bg = true
	popup.exclusive = true

	# Background
	var bg := TextureRect.new()
	bg.texture = load("res://assets/specbg-pc.webp")
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	popup.add_child(bg)

	# Main layout overlay
	var main_vbox := VBoxContainer.new()
	main_vbox.anchor_right = 1.0
	main_vbox.anchor_bottom = 1.0
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 15)
	main_vbox.add_theme_constant_override("margin_left", 20)
	main_vbox.add_theme_constant_override("margin_right", 20)
	main_vbox.add_theme_constant_override("margin_top", 20)
	main_vbox.add_theme_constant_override("margin_bottom", 20)
	popup.add_child(main_vbox)

	# Title label
	var title_label := Label.new()
	title_label.text = "Config Editor"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 20)
	main_vbox.add_child(title_label)

	# Author input
	var author_line := LineEdit.new()
	author_line.placeholder_text = "Author"
	author_line.custom_minimum_size = Vector2(0, 30)
	main_vbox.add_child(author_line)

	# Version input
	var version_line := LineEdit.new()
	version_line.placeholder_text = "Version"
	version_line.custom_minimum_size = Vector2(0, 30)
	main_vbox.add_child(version_line)

	# Button row
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 15)
	main_vbox.add_child(btn_row)

	var save_btn := Button.new()
	save_btn.text = "Save"
	save_btn.custom_minimum_size = Vector2(100, 32)
	save_btn.pressed.connect(func():
		var config := ConfigFile.new()
		config.set_value("Mod", "Author", author_line.text)
		config.set_value("Mod", "Version", version_line.text)
		var ini_path = mod_path + "/config.ini"
		var err = config.save(ini_path)
		if err != OK:
			push_error("Failed to save config.ini at " + ini_path)
		else:
			print("Config.ini saved at: ", ini_path)
			refresh_mod_list()
		popup.queue_free()
	)
	btn_row.add_child(save_btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(100, 32)
	cancel_btn.pressed.connect(func():
		popup.queue_free()
	)
	btn_row.add_child(cancel_btn)

	get_tree().root.add_child(popup)
	popup.popup_centered()



func load_mod_metadata(mod_path: String) -> Dictionary:
	var config := ConfigFile.new()
	var ini_path = mod_path + "/config.ini"
	var result = config.load(ini_path)
	if result != OK:
		push_error("Failed to load ini at " + ini_path + " error code: " + str(result))
		return {"author": "Unknown", "version": "Unknown", "ue4ss": false}

	var author = config.get_value("Mod", "Author", "Unknown")
	var version = config.get_value("Mod", "Version", "Unknown")
	var ue4ss = config.get_value("Mod", "UE4SS", false)

	print("Loaded metadata for ", mod_path, ": Author=", author, " Version=", version, " UE4SS=", ue4ss)

	return {
		"author": str(author),
		"version": str(version),
		"ue4ss": bool(ue4ss)
	}




# -------------------------
# Install / Uninstall mods
# -------------------------
func _on_install_pressed() -> void:
	if storage_path == "" or (game_mods_path == "" and ue4ss_mods_path == ""):
		printerr("Paths not set — please set storage, game mods, and UE4SS paths.")
		return

	for mod_name: String in mod_checkboxes.keys():
		var cb: CheckBox = mod_checkboxes[mod_name]
		var source_path: String = storage_path + "/" + mod_name

		# Load metadata for UE4SS check
		var meta = load_mod_metadata(source_path)
		var use_ue4ss: bool = meta.get("ue4ss", false)

		# Pick target based on UE4SS flag
		var target_path: String
		if use_ue4ss:
			if ue4ss_mods_path == "":
				printerr("UE4SS path not set, but mod ", mod_name, " requires UE4SS.")
				continue
			target_path = ue4ss_mods_path + "/" + mod_name
		else:
			if game_mods_path == "":
				printerr("Game mods path not set, but mod ", mod_name, " requires it.")
				continue
			target_path = game_mods_path + "/" + mod_name

		# Install or uninstall
		if cb.button_pressed:
			copy_dir_recursive(source_path, target_path)
		else:
			if DirAccess.dir_exists_absolute(target_path):
				remove_dir_recursive(target_path)

	print("Mods installed/updated!")
	refresh_mod_list()


# -------------------------
func _on_launch_pressed() -> void:
	var exe_file := exe_path_edit.text.strip_edges()
	if exe_file == "":
		printerr("Game path not set. Please set it in Settings.")
		return

	# Ensure absolute path
	exe_file = ProjectSettings.globalize_path(exe_file)

	if not FileAccess.file_exists(exe_file):
		printerr("Invalid game exe path: ", exe_file)
		return

	# --- steam_appid.txt next to exe ---
	var exe_dir := exe_file.get_base_dir()
	var appid_path := exe_dir.path_join("steam_appid.txt")
	var file := FileAccess.open(appid_path, FileAccess.WRITE)
	if file:
		file.store_string("480")
		file.close()
		print("steam_appid.txt created at: ", appid_path)
	else:
		printerr("Failed to create steam_appid.txt at: ", appid_path)

	# Strip quotes if pasted
	if exe_file.begins_with("\"") and exe_file.ends_with("\""):
		exe_file = exe_file.substr(1, exe_file.length() - 2)

	# --- Launch with -union argument ---
	var args := ["-union"]
	var err = OS.create_process(exe_file, args, false) # false = no console
	if err != OK:
		printerr("Failed to launch game exe: ", exe_file, " (error code: ", err, ")")
	else:
		print("Launched game with -union: ", exe_file)

func _on_online_launch_pressed() -> void:
	var steam_url := "steam://launch/3601350"
	var err := OS.shell_open(steam_url)
	if err != OK:
		printerr("Failed to launch Steam game: ", steam_url)
	else:
		print("Launched Steam game: ", steam_url)

# -------------------------
# Helpers: copy & remove recursively
# -------------------------
func copy_dir_recursive(src: String, dst: String) -> void:
	# ensure dst dir exists
	if not DirAccess.dir_exists_absolute(dst):
		DirAccess.make_dir_recursive_absolute(dst)

	var dir: DirAccess = DirAccess.open(src)
	if dir == null:
		printerr("Source dir not found: ", src)
		return

	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue

		var src_path: String = src + "/" + name
		var dst_path: String = dst + "/" + name

		if dir.current_is_dir():
			copy_dir_recursive(src_path, dst_path)
		else:
			# copy file (binary-safe)
			var in_file: FileAccess = FileAccess.open(src_path, FileAccess.READ)
			if in_file == null:
				printerr("Failed to open source file: ", src_path)
			else:
				# make sure the dst dir exists (for safety)
				var parent_dir: String = dst.get_base_dir()
				if not DirAccess.dir_exists_absolute(parent_dir):
					DirAccess.make_dir_recursive_absolute(parent_dir)

				var out_file: FileAccess = FileAccess.open(dst_path, FileAccess.WRITE)
				if out_file == null:
					printerr("Failed to open destination file: ", dst_path)
				else:
					var buf: PackedByteArray = in_file.get_buffer(in_file.get_length())
					out_file.store_buffer(buf)
					out_file.flush()
					out_file.close()
				in_file.close()
		name = dir.get_next()
	dir.list_dir_end()

func remove_dir_recursive(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var child_path: String = path + "/" + name
		if dir.current_is_dir():
			remove_dir_recursive(child_path)
		else:
			# remove file
			DirAccess.remove_absolute(child_path)
		name = dir.get_next()
	dir.list_dir_end()
	# finally remove the (now-empty) directory
	DirAccess.remove_absolute(path)


func _on_window_close_requested() -> void:
	$Window.visible = false
	$Window/SetupGuide.queue_free()


func _on_storage_open_pressed() -> void:
	if storage_path != "" and DirAccess.dir_exists_absolute(storage_path):
		OS.shell_open(storage_path)
	else:
		push_error("Storage path is not set or invalid")


func _on_mods_open_pressed() -> void:
	if game_mods_path != "" and DirAccess.dir_exists_absolute(game_mods_path):
		OS.shell_open(game_mods_path)
	else:
		push_error("Mods path is not set or invalid")


func _on_ue4ss_open_pressed() -> void:
	if ue4ss_mods_path != "" and DirAccess.dir_exists_absolute(ue4ss_mods_path):
		OS.shell_open(ue4ss_mods_path)
	else:
		push_error("UE4SS path is not set or invalid")


func _on_exe_open_pressed() -> void:
	if game_exe != "" and FileAccess.file_exists(game_exe):
		# Open the folder containing the exe
		var exe_dir := game_exe.get_base_dir()
		OS.shell_open(exe_dir)
	else:
		push_error("Game exe path is not set or invalid")

func _on_kofi_pressed() -> void:
	print("Button pressed")
	OS.shell_open("https://ko-fi.com/itzcyn")
