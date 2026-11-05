extends SceneTree

func _init():
	DB.Init()
	print("HairstylesDB: ", DB.HairstylesDB.keys())
	print("Palettes HAIR: ", DB.PalettesDB[DB.Palette.HAIR].keys())
	print("RacesDB: ", DB.RacesDB.keys())
	var races = DB.RacesDB.keys()
	if races.size() > 0:
		var race = DB.GetRace(races[0])
		print("Race 0 skins: ", race.skins.keys())
		var traits = {
			"hairstyle": DB.HairstylesDB.keys()[0],
			"haircolor": DB.PalettesDB[DB.Palette.HAIR].keys()[0],
			"race": races[0],
			"skintone": race.skins.keys()[0],
			"gender": 0
		}
		print("CheckTraits test with skintone key: ", ActorCommons.CheckTraits(traits))
		traits["skintone"] = race.skins.keys()[0].hash()
		print("CheckTraits test with skintone hash: ", ActorCommons.CheckTraits(traits))
	quit(0)
