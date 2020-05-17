extends Node

var loot_dict = {} # Items pending transfer to inventory


# Determines the qty of tiems to be released
func determine_loot_count(map_name):
	var ItemMinCount = DataResource.dict_item_spawn[map_name].ItemMinCount
	var ItemMaxCount = DataResource.dict_item_spawn[map_name].ItemMaxCount
	#gives the random seed
	randomize()
	#randi() expects array, so factor + 1
	var loot_count = randi()%((int(ItemMaxCount) - int(ItemMinCount))+ 1) + int(ItemMinCount)
	return loot_count

# Determines what items and their respective qty to be released
func loot_selector(map_name, loot_count):
	for _i in range(1, loot_count + 1):
		randomize()
		var index = 1
		var chosen_loot = randi() % 100 + 1
		while(chosen_loot > -1):
			# Item has been found - take note of its critical elements
			if(chosen_loot <= DataResource.dict_item_spawn[map_name]["ItemChance"+ str(index)]):
				var loot = []
				loot.append(DataResource.dict_item_spawn[map_name]["ItemType"+ str(index)])
				loot.append(DataResource.dict_item_spawn[map_name]["ItemName"+ str(index)])
				randomize()
				#Randomize the qty of the item to be found
				loot.append(int(rand_range(float(DataResource.dict_item_spawn[map_name]["ItemMinQ" + str(index)]), float(DataResource.dict_item_spawn[map_name]["ItemMaxQ"+ str(index)]))))
				loot_dict[loot_dict.size() + 1] = loot
				break
			#Item not found, manipulate chosen_loot val and compare against next index
			else:
				chosen_loot -= DataResource.dict_item_spawn[map_name]["ItemChance" + str(index)]
				index += 1
	print(loot_dict)#-debug

# Transfers all loot present in loot_dict to dict_inventory
func append_loot(loot_count):
	var index = 1
	while(loot_count != 0):
		# Append current_index of loot dict to the temp ivnentory dict
		# If inventory has the item, increase its item quantity
		# else, create new data of its stats in dict_inventory
		var name = loot_dict[index][0]
		print("Appending to " + name)

		# Increase Coins
		if(loot_dict[index][0] == "Money"):
			DataFunctions.change_coins(int(loot_dict[index][2]))

		# Insert item in inventory
		else:
			# Empty Tab
			if(DataResource.dict_inventory[name].size() == 0):
				print("Item Not Present. Inserting...")
				var curr_size = DataResource.dict_inventory[name].size() + 1
				insert_data(index, curr_size)

			# Non-Empty Tab
			else:
				for i in range(1, DataResource.dict_inventory[name].size() + 1):
					# Item exists in inventory
					if(DataResource.dict_inventory[name]["Item" + str(i)].item_name == loot_dict[index][1]):
						print("Item Present")
						DataResource.dict_inventory[name]["Item" + str(i)].item_qty += loot_dict[index][2]
						break
					# Item not present
					elif(i == DataResource.dict_inventory[name].size()):
						print("Item Not Present. Inserting...")
						var curr_size = DataResource.dict_inventory[name].size() + 1
						insert_data(index, curr_size)
		index += 1
		loot_count -= 1
	DataResource.save_rest()
	print(DataResource.dict_inventory)

func insert_data(index, curr_size):
	var name = loot_dict[index][1]
	var style =  {
				"item_name": loot_dict[index][1],
				"item_attack": DataResource.dict_item_masterlist[name].ItemAtk,
				"item_defense": DataResource.dict_item_masterlist[name].ItemDef,# stub - to update
				"item_statheal": DataResource.dict_item_masterlist[name].StatHeal,
				"item_healval": DataResource.dict_item_masterlist[name].HealVal,
				"item_value": DataResource.dict_item_masterlist[name].ItemValue,
				"item_details": DataResource.dict_item_masterlist[name].ItemDetails,
				"item_qty": loot_dict[index][2],
		}
	DataResource.dict_inventory[loot_dict[index][0]]["Item" + str(curr_size)] = style

