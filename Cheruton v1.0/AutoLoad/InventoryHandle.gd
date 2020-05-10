extends Node

var inventory_data
const INVENTORY = "res://SaveData/inventory-data.json"

func load_inventory_data():
	load_dict(INVENTORY)


func load_dict(FilePath):
	var DataFile = File.new()
	DataFile.open(FilePath, File.READ)
	inventory_data = JSON.parse(DataFile.get_as_text())
	DataFile.close()
