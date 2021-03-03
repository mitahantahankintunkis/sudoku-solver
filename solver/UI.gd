extends Control

var palette = {
	"normal": Color("000000"),
	"hover": Color("888888"),
	"generated": Color("#118ab2"),
}

onready var grid_buttons = $VBoxContainer/CenterContainer/GridContainer.get_children()
var selected_number = 1
var hover_i = 0
var previous_text = {}


func _ready():
	var template = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 3, 0, 8, 0, 0, 0, 0, 2, 5, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 5, 0, 0, 7, 0, 0, 0, 0, 0, 0, 3, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 7, 0, 0, 0, 0, 9, 0, 0, 6, 0, 2, 0]
	for i in template.size():
		var t = template[i]
		grid_buttons[i].text = str(t) if t else ""

	# Initializes button colors
	for i in grid_buttons.size():
		grid_buttons[i].set("custom_colors/font_color", palette["normal"])

	# Connects grid buttons
	for i in grid_buttons.size():
		grid_buttons[i].connect("button_down", self, "_on_grid_button_pressed", [i])
		grid_buttons[i].connect("mouse_entered", self, "_on_grid_button_mouse_enter", [i])
		grid_buttons[i].connect("mouse_exited", self, "_on_grid_button_mouse_exit", [i])


func _process(_delta):
	for key in range(1, 10):
		if Input.is_action_pressed(str(key)):
			selected_number = key

			if hover_i != -1:
				grid_buttons[hover_i].text = str(selected_number)

			break


func _on_grid_button_pressed(i):
	grid_buttons[i].set("custom_colors/font_color", palette["normal"])

	if Input.is_mouse_button_pressed(2):
		grid_buttons[i].text = ""
		previous_text[i] = ""
	else:
		grid_buttons[i].text = str(selected_number)
		previous_text[i] = grid_buttons[i].text


func _on_grid_button_mouse_enter(i):
	hover_i = i
	previous_text[i] = grid_buttons[i].text
	grid_buttons[i].text = str(selected_number)


func _on_grid_button_mouse_exit(i):
	hover_i = -1
	grid_buttons[i].text = previous_text.get(i, "")


func _on_Clear_pressed():
	for child in grid_buttons:
		child.text = ""


func _on_Solve_pressed():
	for i in grid_buttons.size():
		if grid_buttons[i].get("custom_colors/font_color") != palette["normal"]:
			grid_buttons[i].text = ""
	
		if grid_buttons[i].text:
			grid_buttons[i].set("custom_colors/font_color", palette["normal"])
		else:
			grid_buttons[i].set("custom_colors/font_color", palette["generated"])

	var solver = $Solvers/Naive
	
	if not solver.solve():
		print("Could not solve")
	else:
		for i in grid_buttons.size():
			var v = solver.grid[i]
			grid_buttons[i].text = str(v) if v != 0 else ""
	print(solver.grid)
