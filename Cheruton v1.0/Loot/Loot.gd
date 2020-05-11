extends Control

var map_name
var loot_count
var loot_dict = {}

func _ready():
	map_name = "debug" # find something to link to this
	determine_loot_count()
	loot_selector()

# Determines the qty of tiems to be released
func determine_loot_count():
	var ItemMinCount = DataResource.dict_loot[map_name].ItemMinCount
	var ItemMaxCount = DataResource.dict_loot[map_name].ItemMaxCount
	#gives the random seed
	randomize()
	#randi() expects array, so factor + 1
	loot_count = randi()%((int(ItemMaxCount) - int(ItemMinCount))+ 1) + int(ItemMinCount)
	print(loot_count) #debug


func loot_selector():
	for i in range(1, loot_count + 1):
		randomize()
		var index = 1
		var chosen_loot = randi() % 100 + 1
		while(chosen_loot > -1):
			# Item has been found, add it to loot dict
			if(chosen_loot <= DataResource.dict_loot[map_name]["Item" + str(index) + "Chance"]):
				var loot = []
				loot.append(DataResource.dict_loot[map_name]["Item" + str(index) + "Chance"])
				randomize()
				#Randomize the qty of the item to be found
				loot.append(int(rand_range(float(DataResource.dict_loot[map_name]["Item" + str(index) + "MinQ"]), float(DataResource.dict_loot[map_name]["Item" + str(index) + "MaxQ"]))))
				loot_dict[loot_dict.size() + 1] = loot
				break
			#Item not found, manipulate chosen_loot val and compare against next index
			else:
				chosen_loot -= DataResource.dict_loot[map_name]["Item" + str(index) + "Chance"]
				index += 1
	print(loot_dict)#-debug
#
#func populate_panel():
#	var count = loot_dic.size()
#	print(count)#-debug
#	#check vid to expand
