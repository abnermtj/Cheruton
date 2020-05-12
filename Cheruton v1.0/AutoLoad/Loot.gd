extends Node

var loot_dict = {}


# Determines the qty of tiems to be released
func determine_loot_count(map_name):
	var ItemMinCount = DataResource.dict_loot[map_name].ItemMinCount
	var ItemMaxCount = DataResource.dict_loot[map_name].ItemMaxCount
	#gives the random seed
	randomize()
	#randi() expects array, so factor + 1
	var loot_count = randi()%((int(ItemMaxCount) - int(ItemMinCount))+ 1) + int(ItemMinCount)
	return loot_count
	print(loot_count) #debug


func loot_selector(map_name, loot_count):
	for i in range(1, loot_count + 1):
		randomize()
		var index = 1
		var chosen_loot = randi() % 100 + 1
		while(chosen_loot > -1):
			# Item has been found - take note of its critical elements
			if(chosen_loot <= DataResource.dict_loot[map_name]["ItemChance"+ str(index)]):
				var loot = []
				loot.append(DataResource.dict_loot[map_name]["ItemType"+ str(index)])
				loot.append(DataResource.dict_loot[map_name]["ItemName"+ str(index)])
				randomize()
				#Randomize the qty of the item to be found
				loot.append(int(rand_range(float(DataResource.dict_loot[map_name]["ItemMinQ" + str(index)]), float(DataResource.dict_loot[map_name]["ItemMaxQ"+ str(index)]))))
				loot_dict[loot_dict.size() + 1] = loot
				break
			#Item not found, manipulate chosen_loot val and compare against next index
			else:
				chosen_loot -= DataResource.dict_loot[map_name]["ItemChance" + str(index)]
				index += 1
	print(loot_dict)#-debug
#

func append_loot(map_name, loot_count):
	var index = 1
	while(loot_count != 0):
		#Append current_index of loot dict to the temp ivnentory dict
		if(loot_dict[index][0] == "Weapons"):
			print("Appending to Weapons")
			if(DataResource.temp_dict_inventory.Weapons.has(loot_dict[index][1])):
				#DataResource.temp_dict_inventory.Weapons..item_qty += loot_dict[index][2]

		elif(loot_dict[index][0] == "Apparel"):
			print("Appending to Apparel")
			if(DataResource.temp_dict_inventory.Apparel.has(loot_dict[index][1])):
				var item = loot_dict[index][1]
				#DataResource.temp_dict_inventory.Apparel.item.item_qty += loot_dict[index][2]
			
		elif(loot_dict[index][0] == "Aid"):
			print("Appending to Aid")
			if(DataResource.temp_dict_inventory.Aid.has(loot_dict[index][1])):
				var item = loot_dict[index][1]
				#DataResource.temp_dict_inventory.Aid.item.item_qty += loot_dict[index][2]
			
		elif(loot_dict[index][0] == "Misc"):
			print("Appending to Misc")
			if(DataResource.temp_dict_inventory.Misc.has(loot_dict[index][1])):
				var item = loot_dict[index][1]
				#DataResource.temp_dict_inventory.Misc.item.item_qty += loot_dict[index][2]
			
		elif(loot_dict[index][0] == "Key Items"):
			print("Appending to Key Items")
			if(DataResource.temp_dict_inventory["Key Items"].has(loot_dict[index][1])):
				var item = loot_dict[index][1]
				#DataResource.temp_dict_inventory["Key Items"].item.item_qty += loot_dict[index][2]
			
		elif(loot_dict[index][0] == "Money"):
			print("Increasing Coins")
			#DataFunctions.change_coins(int(loot_dict[index][2]))
		index += 1
		loot_count -= 1
	print(DataResource.temp_dict_inventory)
