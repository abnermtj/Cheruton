extends Node

var inventory_data
#var loot_data
#var loot_count
#var loot_dict = {}

const INVENTORY = "res://SaveData/inventory_data.json"
#const LOOT = "res://SaveData/loot_data.json"

func load_inventory_data():
	load_dict(INVENTORY)

#func load_loot_data():
#	load_dict(LOOT)

func load_dict(FilePath):
	var DataFile = File.new()
	DataFile.open(FilePath, File.READ)
	inventory_data = JSON.parse(DataFile.get_as_text())
	DataFile.close()
	print("Data Loaded!")


## To transfer the following functions to data to inventory once loot is setup
# Determines the qty of tiems to be released
#func determine_loot_count():
#	var ItemMinCount = loot_data.ItemMinCount
#	var ItemMaxCount = loot_data.ItemMaxCount
#	#gives the random seed
#	randomize()
#	#randi() expects array, so factor + 1
#	loot_count = randi()%((int(ItemMaxCount) - int(ItemMinCount))+ 1) + int(ItemMinCount)
#	print(loot_count) #debug


#
func loot_selector():
	for i in range(1, loot_count + 1):
		randomize()
		var chosen_loot = randi() % 100 + 1
		var index = 1
		while(chosen_loot > -1):
			# Item has been found, add it to loot dict
			if(chosen_loot <= filerename.loot_data[map_name]["Item" + str(index) + "Chance"]):
				var loot = []
				loot.append(filerename.loot_data[map_name]["Item" + str(index) + "Chance"])
				randomize()
				#Randomize the qty of the item to be found
				loot.append(int(rand_range(float(filename.loot_data[map_name]["Item" + str(index) + "MinQ"]), float(filename.loot_data[map_name]["Item" + str(index) + "MaxQ"]))))
				loot_dic[loot_dic.size() + 1] = loot
				break
			#Item not found, manipulate chosen_loot val and compare against next index
			else:
				chosen_loot -= filename.loot_data[map_name]["Item" + str(index) + "Chance"]
				index += 1
	print(loot_dic)#-debug

func populate_panel():
	var count = loot_dic.size()
	print(count)#-debug
	#check vid to expand
