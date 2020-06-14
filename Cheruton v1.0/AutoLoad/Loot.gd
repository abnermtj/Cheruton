extends Node

var loot_dict = {} # Items pending transfer to inventory
enum item{TYPE = 0, NAME = 1, AMOUNT = 2}

func determine_loot(map):
	var loot_count = determine_loot_count(map)
	loot_selector(map, loot_count)
	append_loot(loot_count)

# Determines the qty of tiems to be released
func determine_loot_count(map_name):
	var ItemMinCount = DataResource.dict_item_spawn[map_name].ItemMinCount
	var ItemMaxCount = DataResource.dict_item_spawn[map_name].ItemMaxCount

	randomize()
	var loot_count = randi()%((int(ItemMaxCount) - int(ItemMinCount))+ 1) + int(ItemMinCount)
	return loot_count

# Determines what items and their respective qty to be released
# Needs rework. Currently, the next loot item can only be obtained after the previous one is
func loot_selector(map_name, loot_count):
	for _i in range(loot_count):
		randomize()
		var index = 1
		var loot_chance = randi() % 100 + 1
		while(loot_chance > -1):
			# Item has been found - take note of its critical elements
			if(loot_chance <= DataResource.dict_item_spawn[map_name]["ItemChance"+ str(index)]):
				var loot = []
				loot.append(DataResource.dict_item_spawn[map_name]["ItemType"+ str(index)])
				loot.append(DataResource.dict_item_spawn[map_name]["ItemName"+ str(index)])
				randomize()
				#Randomize the qty of the item to be found
				loot.append(int(rand_range(float(DataResource.dict_item_spawn[map_name]["ItemMinQ" + str(index)]), float(DataResource.dict_item_spawn[map_name]["ItemMaxQ"+ str(index)]))))
				loot_dict[loot_dict.size() + 1] = loot
				break
			#Item not found, manipulate loot_chance val and compare against next index
			else:
				loot_chance -= DataResource.dict_item_spawn[map_name]["ItemChance" + str(index)]
				index += 1

# Transfers all loot present in loot_dict to dict_inventory
func append_loot(loot_count):
	var index = 1
	while loot_count:
		var item_type = loot_dict[index][item.TYPE]

		# Money
		if(loot_dict[index][0] == "Money"):
			DataFunctions.change_coins(int(loot_dict[index][item.AMOUNT]))

		# Non Money
		else:
			# Empty Tab
			if(DataResource.dict_inventory[item_type].size() == 0):
				var curr_size = DataResource.dict_inventory[item_type].size() + 1
				insert_data(index, curr_size)

			# Non-Empty Tab
			else:
				for i in range(1, DataResource.dict_inventory[item_type].size() + 1):
					# Item exists in inventory
					if(DataResource.dict_inventory[item_type]["Item" + str(i)].item_name == loot_dict[index][item.NAME]):
						DataResource.dict_inventory[item_type]["Item" + str(i)].item_qty += loot_dict[index][item.AMOUNT]
						break
					# Item not present
					var curr_size = DataResource.dict_inventory[item_type].size() + 1
					insert_data(index, curr_size)
		index += 1
		loot_count -= 1
	DataResource.save_rest()

# inserts item to inventory at insert_index
func insert_data(item_id, insert_index):
	var item_name = loot_dict[item_id][item.NAME]
	var stats =  {
				"item_name": loot_dict[item_id][1],
				"item_attack": DataResource.dict_item_masterlist[item_name].ItemAtk,
				"item_defense": DataResource.dict_item_masterlist[item_name].ItemDef,# stub - to update
				"item_statheal": DataResource.dict_item_masterlist[item_name].StatHeal,
				"item_healval": DataResource.dict_item_masterlist[item_name].HealVal,
				"item_value": DataResource.dict_item_masterlist[item_name].ItemValue,
				"item_details": DataResource.dict_item_masterlist[item_name].ItemDetails,
				"item_png": DataResource.dict_item_masterlist[item_name].ItemPNG,
				"item_qty": loot_dict[item_id][2],
		}
	DataResource.dict_inventory[loot_dict[item_id][item.TYPE]]["Item" + str(insert_index)] = stats
