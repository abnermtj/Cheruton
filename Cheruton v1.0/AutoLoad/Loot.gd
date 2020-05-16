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
	for i in range(1, loot_count + 1):
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

		if(loot_dict[index][0] == "Weapons"):
			print("Appending to Weapons")
			for i in range(1, DataResource.dict_inventory.Weapons.size() + 1):
				if(DataResource.dict_inventory.Weapons["Item" + str(i)].item_name == loot_dict[index][1]):
					print("Item Present")
					DataResource.dict_inventory.Weapons["Item" + str(i)].item_qty += loot_dict[index][2]
					break
				elif(i == DataResource.dict_inventory.Weapons.size()):
					print("Item Not Present. Inserting...")
					var curr_size = DataResource.dict_inventory.Weapons.size() + 1
					insert_data(index, curr_size)

		elif(loot_dict[index][0] == "Apparel"):
			print("Appending to Apparel")
			for i in range(1, DataResource.dict_inventory.Apparel.size() + 1):
				if(DataResource.dict_inventory.Apparel["Item" + str(i)].item_name == loot_dict[index][1]):
					print("Item Present")
					DataResource.dict_inventory.Apparel["Item" + str(i)].item_qty += loot_dict[index][2]
					break
				elif(i == DataResource.dict_inventory.Apparel.size()):
					print("Item Not Present. Inserting...")
					var curr_size = DataResource.dict_inventory.Apparel.size() + 1
					insert_data(index, curr_size)

		elif(loot_dict[index][0] == "Consum"):
			print("Appending to Consum")
			for i in range(1, DataResource.dict_inventory.Consum.size() + 1):
				if(DataResource.dict_inventory.Consum["Item" + str(i)].item_name == loot_dict[index][1]):
					print("Item Present")
					DataResource.dict_inventory.Consum["Item" + str(i)].item_qty += loot_dict[index][2]
					break
				elif(i == DataResource.dict_inventory.Consum.size()):
					print("Item Not Present. Inserting...")
					var curr_size = DataResource.dict_inventory.Consum.size() + 1
					insert_data(index, curr_size)

		elif(loot_dict[index][0] == "Misc"):
			print("Appending to Misc")
			for i in range(1, DataResource.dict_inventory.Misc.size() + 1):
				if(DataResource.dict_inventory.Misc["Item" + str(i)].item_name == loot_dict[index][1]):
					print("Item Present")
					DataResource.dict_inventory.Misc["Item" + str(i)].item_qty += loot_dict[index][2]
					break
				elif(i == DataResource.dict_inventory.Misc.size()):
					print("Item Not Present. Inserting...")
					var curr_size = DataResource.dict_inventory.Misc.size() + 1
					insert_data(index, curr_size)

		elif(loot_dict[index][0] == "Key Items"):
			print("Appending to Key Items")
			for i in range(1, DataResource.dict_inventory["Key Items"].size() + 1):
				if(DataResource.dict_inventory["Key Items"]["Item" + str(i)].item_name == loot_dict[index][1]):
					print("Item Present")
					DataResource.dict_inventory["Key Items"]["Item" + str(i)].item_qty += loot_dict[index][2]
					break
				elif(i == DataResource.dict_inventory["Key Items"].size()):
					print("Item Not Present. Inserting...")
					var curr_size = DataResource.dict_inventory["Key Items"].size() + 1
					insert_data(index, curr_size)
		elif(loot_dict[index][0] == "Money"):
			print("Increasing Coins")
			DataFunctions.change_coins(int(loot_dict[index][2]))
		index += 1
		loot_count -= 1
	DataResource.save_rest()
	print(DataResource.dict_inventory)

func insert_data(index, curr_size):
	var name = loot_dict[index][1]
	var style =  {
				"item_name": name,
				"item_attack": DataResource.dict_item_masterlist.name.ItemAtk,
				"item_defense": DataResource.dict_item_masterlist.name.ItemDef,# stub - to update
				"item_statheal": DataResource.dict_item_masterlist.name.StatHeal,
				"item_healval": DataResource.dict_item_masterlist.name.HealVal,
				"item_value": DataResource.dict_item_masterlist.name.ItemValue,
				"item_qty": loot_dict[index][2],
		}
	DataResource.dict_inventory[name]["Item" + str(curr_size)] = style

