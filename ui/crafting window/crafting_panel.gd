extends Control

@export var recipe_button_prefab : PackedScene
@export var recipe_button_parent : Control

@export var selected_recipe_texture : TextureRect
@export var selected_recipe_label : Label
@export var selected_recipe_reagents : Array[TextureRect]

var selected_recipe : Recipe

var recipe_buttons : Dictionary

func _ready():
	for recipe in RecipeHandler.recipes:
		create_recipe_button(recipe)

func open():
	var inventory = InventoryInterface.player_inventory
	for recipe in recipe_buttons.keys():
		recipe_buttons[recipe].visible = true
		for reagent in recipe.reagents:
			if !inventory.has_stack(reagent):
				recipe_buttons[recipe].visible = false
				continue

func create_recipe_button(recipe : Recipe):
	var btn = recipe_button_prefab.instantiate()
	recipe_button_parent.add_child(btn)
	recipe_buttons[recipe] = btn
	
	btn.get_child(0).get_child(0).texture = recipe.result.item.texture
	
	var lambda = func():
		select_recipe(recipe)
	btn.pressed.connect(lambda)

func select_recipe(recipe : Recipe):
	selected_recipe = recipe
	selected_recipe_texture.texture = recipe.result.item.texture
	selected_recipe_label.text = recipe.result.item.name
	for i in selected_recipe_reagents.size():
		if i < recipe.reagents.size():
			selected_recipe_reagents[i].visible = true
			selected_recipe_reagents[i].texture = recipe.reagents[i].item.texture
			selected_recipe_reagents[i].get_child(0).text = str(recipe.reagents[i].count)
		else:
			selected_recipe_reagents[i].visible = false

func craft():
	if selected_recipe == null:
		return
	var inventory = InventoryInterface.player_inventory
	for reagent in selected_recipe.reagents:
		if !inventory.has_stack(reagent):
			return
	
	for reagent in selected_recipe.reagents:
		inventory.remove_stack(reagent.duplicate())
	
	inventory.add_stack(selected_recipe.result.duplicate())
	open()
