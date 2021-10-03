extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var did = false
var Story = load("res://addons/inkgd/runtime/story.gd")
var story # The specific story instance.

onready var story_label = get_node("CanvasLayer/CenterContainer/MarginContainer/VBoxContainer/MainStoryLabel")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _load_story(ink_story_path):
	var ink_story = File.new()
	ink_story.open(ink_story_path, File.READ)
	var content = ink_story.get_as_text()
	ink_story.close()

	self.story = Story.new(content)

func start_story():
	InkRuntime.init(get_tree().root)
	_load_story("res://ink/main.json")
	story_label.text = ""
	continue_story()

func continue_story():
	while story.can_continue:
		story_label.text += "\n" + story.continue()
	
	if story.current_choices.size() > 0:
		print(story.current_choices)

func _process(_delta):
	if not did:
		did = true
		start_story()
