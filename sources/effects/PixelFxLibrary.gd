extends RefCounted
class_name PixelFxLibrary

## TDNM — BUILD 12: PixelFX sprite-sheet catalog + SpriteFrames cache
## Sheets live under res://assets/vfx/pixelfx/<category>/<id>/
## Each effect folder contains: <id>.png + <id>.json (Aseprite-style from PixelFX).

const ROOT := "res://assets/vfx/pixelfx"

## Logical effect keys used by gameplay → relative folder under ROOT
const CATALOG : Dictionary = {
	# arcane
	"arcane_beam": "arcane/arcane-beam",
	"arcane_missiles": "arcane/arcane-missiles",
	"arcane_orb": "arcane/arcane-orb",
	"blink_in": "arcane/blink-in",
	"blink_out": "arcane/blink-out",
	"magic_circle_cast": "arcane/magic-circle-cast",
	"mana_burst": "arcane/mana-burst",
	"portal": "arcane/portal",
	"rune_circle": "arcane/rune-circle",
	"spell_charge": "arcane/spell-charge",
	"star_fall": "arcane/star-fall",
	"time_stop": "arcane/time-stop",
	# critters
	"bat": "critters/bat",
	"bird": "critters/bird",
	"butterfly": "critters/butterfly",
	"eyeball": "critters/eyeball",
	"fish_school": "critters/fish-school",
	"flying_skull": "critters/flying-skull",
	"frog": "critters/frog",
	"ghost": "critters/ghost",
	"jellyfish": "critters/jellyfish",
	"slime": "critters/slime",
	"snake": "critters/snake",
	"wisp": "critters/wisp",
	# cultivation
	"dragon_golden_spiral": "cultivation/dragon-golden-spiral",
	# explosions
	"barrel_explosion": "explosions/barrel-explosion",
	"big_explosion": "explosions/big-explosion",
	"cartoon_pow": "explosions/cartoon-pow",
	"dirt_explosion": "explosions/dirt-explosion",
	"firework_burst": "explosions/firework-burst",
	"firework_rocket": "explosions/firework-rocket",
	"grenade": "explosions/grenade",
	"implosion": "explosions/implosion",
	"nuke": "explosions/nuke",
	"plasma_explosion": "explosions/plasma-explosion",
	"small_explosion": "explosions/small-explosion",
	"smoke_bomb": "explosions/smoke-bomb",
	# fire
	"brazier": "fire/brazier",
	"campfire": "fire/campfire",
	"candle": "fire/candle",
	"fire_breath": "fire/fire-breath",
	"fire_ring": "fire/fire-ring",
	"fire_tornado": "fire/fire-tornado",
	"fireball": "fire/fireball",
	"flame_pillar": "fire/flame-pillar",
	"flamethrower": "fire/flamethrower",
	"meteor": "fire/meteor",
	"spirit_flame": "fire/spirit-flame",
	"torch": "fire/torch",
	# holy
	"blessing": "holy/blessing",
	"divine_shield": "holy/divine-shield",
	"feather_burst": "holy/feather-burst",
	"halo": "holy/halo",
	"heal": "holy/heal",
	"heal_aoe": "holy/heal-aoe",
	"holy_pillar": "holy/holy-pillar",
	"resurrection": "holy/resurrection",
	"smite": "holy/smite",
	"sunburst": "holy/sunburst",
	# ice
	"blizzard_vortex": "ice/blizzard-vortex",
	"freeze": "ice/freeze",
	"frost_breath": "ice/frost-breath",
	"frost_nova": "ice/frost-nova",
	"ice_crystal": "ice/ice-crystal",
	"ice_lance": "ice/ice-lance",
	"ice_shatter": "ice/ice-shatter",
	"ice_spikes": "ice/ice-spikes",
	"icicle_fall": "ice/icicle-fall",
	"snowflake_burst": "ice/snowflake-burst",
	# impacts
	"blunt_hit": "impacts/blunt-hit",
	"bullet_impact": "impacts/bullet-impact",
	"crit_hit": "impacts/crit-hit",
	"ground_slam": "impacts/ground-slam",
	"heavy_landing": "impacts/heavy-landing",
	"hit_flash": "impacts/hit-flash",
	"hit_spark": "impacts/hit-spark",
	"impact_frame": "impacts/impact-frame",
	"parry": "impacts/parry",
	"ricochet": "impacts/ricochet",
	"shield_block": "impacts/shield-block",
	# lightning
	"ball_lightning": "lightning/ball-lightning",
	"chain_lightning": "lightning/chain-lightning",
	"charge_up": "lightning/charge-up",
	"electrified": "lightning/electrified",
	"lightning_strike": "lightning/lightning-strike",
	"plasma_ball": "lightning/plasma-ball",
	"spark_arc": "lightning/spark-arc",
	"storm_cloud": "lightning/storm-cloud",
	"tesla_coil": "lightning/tesla-coil",
	"thunderclap": "lightning/thunderclap",
	"zap_hit": "lightning/zap-hit",
	# melee
	"claw_swipe": "melee/claw-swipe",
	"dagger_flurry": "melee/dagger-flurry",
	"double_slash": "melee/double-slash",
	"hammer_smash": "melee/hammer-smash",
	"heavy_cleave": "melee/heavy-cleave",
	"scythe_reap": "melee/scythe-reap",
	"spear_sweep": "melee/spear-sweep",
	"spin_slash": "melee/spin-slash",
	"sword_slash": "melee/sword-slash",
	"thrust": "melee/thrust",
	"uppercut": "melee/uppercut",
	"whip_crack": "melee/whip-crack",
	# moves
	"arrow_shot": "moves/arrow-shot",
	"dash_strike": "moves/dash-strike",
	"earth_stomp": "moves/earth-stomp",
	"fireball_throw": "moves/fireball-throw",
	"ground_pound": "moves/ground-pound",
	"holy_smite": "moves/holy-smite",
	"ice_lance_throw": "moves/ice-lance-throw",
	"lightning_call": "moves/lightning-call",
	"meteor_call": "moves/meteor-call",
	"pistol_shots": "moves/pistol-shots",
	"rocket_launcher": "moves/rocket-launcher",
	"sword_combo": "moves/sword-combo",
	# nature
	"acid_splash": "nature/acid-splash",
	"boulder": "nature/boulder",
	"earth_spike": "nature/earth-spike",
	"healing_bloom": "nature/healing-bloom",
	"leaf_storm": "nature/leaf-storm",
	"poison_cloud": "nature/poison-cloud",
	"quake": "nature/quake",
	"root_snare": "nature/root-snare",
	"spore_burst": "nature/spore-burst",
	"thorns": "nature/thorns",
	"tornado": "nature/tornado",
	"toxic_puddle": "nature/toxic-puddle",
	"vine_whip": "nature/vine-whip",
	# pickups
	"chest_open": "pickups/chest-open",
	"coin_spin": "pickups/coin-spin",
	"collect_burst": "pickups/collect-burst",
	"crystal_shard": "pickups/crystal-shard",
	"gem_spin": "pickups/gem-spin",
	"heart_pickup": "pickups/heart-pickup",
	"key_glint": "pickups/key-glint",
	"loot_beam": "pickups/loot-beam",
	"potion": "pickups/potion",
	"power_star": "pickups/power-star",
	"xp_orb": "pickups/xp-orb",
	# projectiles
	"arrow": "projectiles/arrow",
	"bullet_tracer": "projectiles/bullet-tracer",
	"cannonball": "projectiles/cannonball",
	"energy_disc": "projectiles/energy-disc",
	"flare": "projectiles/flare",
	"homing_missile": "projectiles/homing-missile",
	"laser_bolt": "projectiles/laser-bolt",
	"magic_missile": "projectiles/magic-missile",
	"muzzle_pistol": "projectiles/muzzle-pistol",
	"muzzle_shotgun": "projectiles/muzzle-shotgun",
	"muzzle_smg": "projectiles/muzzle-smg",
	"plasma_shot": "projectiles/plasma-shot",
	"rocket": "projectiles/rocket",
	# scifi
	"emp_blast": "scifi/emp-blast",
	"energy_core": "scifi/energy-core",
	"force_field": "scifi/force-field",
	"glitch": "scifi/glitch",
	"hologram": "scifi/hologram",
	"jetpack": "scifi/jetpack",
	"laser_grid": "scifi/laser-grid",
	"scanner": "scifi/scanner",
	"teleporter_pad": "scifi/teleporter-pad",
	"tractor_beam": "scifi/tractor-beam",
	"warp_in": "scifi/warp-in",
	"warp_out": "scifi/warp-out",
	# shadow
	"black_hole": "shadow/black-hole",
	"curse": "shadow/curse",
	"dark_explosion": "shadow/dark-explosion",
	"eclipse": "shadow/eclipse",
	"grasping_hands": "shadow/grasping-hands",
	"hex_sigil": "shadow/hex-sigil",
	"life_steal": "shadow/life-steal",
	"necro_skulls": "shadow/necro-skulls",
	"shadow_flames": "shadow/shadow-flames",
	"shadow_tendrils": "shadow/shadow-tendrils",
	"soul_drain": "shadow/soul-drain",
	"void_orb": "shadow/void-orb",
	# spawn
	"coin_drop": "spawn/coin-drop",
	"disintegrate": "spawn/disintegrate",
	"dissolve_burn": "spawn/dissolve-burn",
	"egg_hatch": "spawn/egg-hatch",
	"poof": "spawn/poof",
	"respawn_beam": "spawn/respawn-beam",
	"shatter_death": "spawn/shatter-death",
	"soul_rise": "spawn/soul-rise",
	"spawn_portal": "spawn/spawn-portal",
	"summon_rise": "spawn/summon-rise",
	# status
	"bleeding": "status/bleeding",
	"burning": "status/burning",
	"charmed": "status/charmed",
	"confused": "status/confused",
	"cursed": "status/cursed",
	"frozen": "status/frozen",
	"haste": "status/haste",
	"petrified": "status/petrified",
	"poisoned": "status/poisoned",
	"rage": "status/rage",
	"sleep": "status/sleep",
	"slowed": "status/slowed",
	"stunned": "status/stunned",
	# sword
	"nhat_kiem_tram_thien_mon": "sword/nhat-kiem-tram-thien-mon",
	"van_kiem_quy_tong": "sword/van-kiem-quy-tong",
	# transitions
	"blinds": "transitions/blinds",
	"burn_away": "transitions/burn-away",
	"crt_off": "transitions/crt-off",
	"diamond_wipe": "transitions/diamond-wipe",
	"glitch_wipe": "transitions/glitch-wipe",
	"iris": "transitions/iris",
	"pixel_dissolve": "transitions/pixel-dissolve",
	"shatter_wipe": "transitions/shatter-wipe",
	"slash_wipe": "transitions/slash-wipe",
	"star_iris": "transitions/star-iris",
	# ui
	"achievement": "ui/achievement",
	"coin_collect": "ui/coin-collect",
	"combo_counter": "ui/combo-counter",
	"confetti": "ui/confetti",
	"countdown": "ui/countdown",
	"crit_number": "ui/crit-number",
	"damage_number": "ui/damage-number",
	"exclamation": "ui/exclamation",
	"health_bar_hit": "ui/health-bar-hit",
	"heart_lost": "ui/heart-lost",
	"level_up": "ui/level-up",
	"quest_complete": "ui/quest-complete",
	# water
	"bubbles": "water/bubbles",
	"drip": "water/drip",
	"fountain": "water/fountain",
	"geyser": "water/geyser",
	"rain_splash": "water/rain-splash",
	"ripples": "water/ripples",
	"splash": "water/splash",
	"water_jet": "water/water-jet",
	"water_orb": "water/water-orb",
	"waterfall": "water/waterfall",
	"wave_crash": "water/wave-crash",
	"whirlpool": "water/whirlpool",
	# weather
	"aurora": "weather/aurora",
	"blizzard": "weather/blizzard",
	"cherry_blossoms": "weather/cherry-blossoms",
	"clouds": "weather/clouds",
	"falling_leaves": "weather/falling-leaves",
	"fireflies": "weather/fireflies",
	"fog": "weather/fog",
	"god_rays": "weather/god-rays",
	"rain": "weather/rain",
	"shooting_stars": "weather/shooting-stars",
	"snow": "weather/snow",
	"storm": "weather/storm",
}

## Ngũ Hành → preferred sheet key (may include looping sheets — cast/ambient only)
const ELEMENT_FX : Dictionary = {
	0: "hit_spark",
	1: "slash",
	2: "leaf_storm",
	3: "frost_nova",
	4: "fire_spirit",
	5: "earth_spike",
}

## Hit impacts must be short one-shots (no looping weather/element sheets)
const IMPACT_FX : Dictionary = {
	0: "hit_spark",
	1: "slash",
	2: "hit_spark",
	3: "ice_spikes",
	4: "crit_hit",
	5: "ground_slam",
}

## Legacy short keys used by combat/UI → catalog stem keys after full-import
const KEY_ALIASES : Dictionary = {
	"slash": "sword_slash",
	"fire_spirit": "spirit_flame",
	"lightning_charge": "charge_up",
	"magic_circle": "magic_circle_cast",
	"heal_ring": "heal_aoe",
}

static func NormalizeKey(key : String) -> String:
	return String(KEY_ALIASES.get(key, key))

## PixelFX gallery placement — where / how to spawn (not every FX is a body-attached move)
## body_act: moves — attach to caster + act windup/hit
## body: status/buffs — attach, follow character
## body_dir: melee/breath/beam — attach + face with caster
## floor: AoE / ground slam rings — world at feet (fringe)
## target: impacts — world on hit entity
## world: weather / ambient / transitions
## ui: HUD toasts / numbers
const PLACE_BODY_ACT := "body_act"
const PLACE_BODY := "body"
const PLACE_BODY_DIR := "body_dir"
const PLACE_FLOOR := "floor"
const PLACE_TARGET := "target"
const PLACE_WORLD := "world"
const PLACE_UI := "ui"

const CATEGORY_PLACEMENT : Dictionary = {
	"moves": PLACE_BODY_ACT,
	"melee": PLACE_BODY_DIR,
	"impacts": PLACE_TARGET,
	"projectiles": PLACE_BODY_DIR,
	"status": PLACE_BODY,
	"holy": PLACE_BODY,
	"weather": PLACE_WORLD,
	"ui": PLACE_UI,
	"transitions": PLACE_WORLD,
	"critters": PLACE_WORLD,
	"pickups": PLACE_FLOOR,
	"spawn": PLACE_BODY,
	"explosions": PLACE_FLOOR,
	"nature": PLACE_FLOOR,
	"water": PLACE_FLOOR,
	"scifi": PLACE_BODY,
	"shadow": PLACE_FLOOR,
	"arcane": PLACE_BODY_DIR,
	"fire": PLACE_BODY_DIR,
	"ice": PLACE_BODY_DIR,
	"lightning": PLACE_BODY_DIR,
	"cultivation": PLACE_BODY_ACT,
	"sword": PLACE_BODY_DIR,
}

## Per-key overrides when category default is wrong
const KEY_PLACEMENT : Dictionary = {
	# fire — floor AoE / props
	"fire_ring": PLACE_FLOOR,
	"flame_pillar": PLACE_FLOOR,
	"fire_tornado": PLACE_FLOOR,
	"meteor": PLACE_FLOOR,
	"brazier": PLACE_FLOOR,
	"campfire": PLACE_FLOOR,
	"candle": PLACE_FLOOR,
	"torch": PLACE_FLOOR,
	"spirit_flame": PLACE_BODY,
	# ice
	"frost_nova": PLACE_FLOOR,
	"ice_spikes": PLACE_FLOOR,
	"blizzard_vortex": PLACE_FLOOR,
	"freeze": PLACE_BODY,
	"ice_crystal": PLACE_BODY,
	# lightning
	"lightning_strike": PLACE_TARGET, # call-down on aimed NPC
	"thunderclap": PLACE_FLOOR,
	"storm_cloud": PLACE_WORLD,
	"electrified": PLACE_BODY,
	"tesla_coil": PLACE_FLOOR,
	# arcane
	"magic_circle_cast": PLACE_FLOOR,
	"rune_circle": PLACE_FLOOR,
	"star_fall": PLACE_FLOOR,
	"portal": PLACE_FLOOR,
	"mana_burst": PLACE_BODY,
	"blink_in": PLACE_BODY,
	"blink_out": PLACE_BODY,
	"time_stop": PLACE_FLOOR,
	# holy
	"heal_aoe": PLACE_FLOOR,
	"holy_pillar": PLACE_TARGET,
	"smite": PLACE_TARGET,
	"sunburst": PLACE_FLOOR,
	"feather_burst": PLACE_BODY,
	"resurrection": PLACE_BODY,
	# shadow
	"curse": PLACE_BODY,
	"life_steal": PLACE_BODY_DIR,
	"hex_sigil": PLACE_BODY,
	"necro_skulls": PLACE_BODY,
	"eclipse": PLACE_WORLD,
	# nature exceptions (directional)
	"vine_whip": PLACE_BODY_DIR,
	"leaf_storm": PLACE_BODY,
	"healing_bloom": PLACE_BODY,
	"root_snare": PLACE_BODY,
	# scifi
	"force_field": PLACE_BODY,
	"glitch": PLACE_BODY,
	"scanner": PLACE_BODY,
	"jetpack": PLACE_BODY,
	"emp_blast": PLACE_FLOOR,
	"teleporter_pad": PLACE_FLOOR,
	"laser_grid": PLACE_FLOOR,
	"warp_in": PLACE_BODY,
	"warp_out": PLACE_BODY,
	# water directional
	"water_jet": PLACE_BODY_DIR,
	"geyser": PLACE_FLOOR,
	"whirlpool": PLACE_FLOOR,
	# impacts already target; ground ones stay floor-ish at hit pos
	"ground_slam": PLACE_TARGET,
	"heavy_landing": PLACE_TARGET,
}

static func GetCategory(key : String) -> String:
	var k := NormalizeKey(key)
	if not CATALOG.has(k):
		return ""
	var path : String = String(CATALOG[k])
	var slash := path.find("/")
	if slash <= 0:
		return path
	return path.substr(0, slash)

## Returns PLACE_* — martial may override via fxPlace
static func GetPlacement(key : String) -> String:
	var k := NormalizeKey(key)
	if KEY_PLACEMENT.has(k):
		return String(KEY_PLACEMENT[k])
	var cat := GetCategory(k)
	return String(CATEGORY_PLACEMENT.get(cat, PLACE_BODY_DIR))

static func IsMoveAct(key : String) -> bool:
	return GetPlacement(key) == PLACE_BODY_ACT

## Default world scale so PixelFX sheets fit TDNM isometric character size
const DEFAULT_SCALE : Dictionary = {
	"achievement": 0.50,
	"acid_splash": 0.50,
	"arcane_beam": 0.50,
	"arcane_missiles": 0.50,
	"arcane_orb": 0.55,
	"arrow": 0.50,
	"arrow_shot": 0.50,
	"aurora": 0.40,
	"ball_lightning": 0.50,
	"barrel_explosion": 0.50,
	"bat": 0.50,
	"big_explosion": 0.35,
	"bird": 0.50,
	"black_hole": 0.50,
	"bleeding": 0.60,
	"blessing": 0.50,
	"blinds": 0.50,
	"blink_in": 0.55,
	"blink_out": 0.55,
	"blizzard": 0.50,
	"blizzard_vortex": 0.40,
	"blunt_hit": 0.55,
	"boulder": 0.50,
	"brazier": 0.50,
	"bubbles": 0.50,
	"bullet_impact": 0.50,
	"bullet_tracer": 0.50,
	"burn_away": 0.50,
	"burning": 0.60,
	"butterfly": 0.50,
	"campfire": 0.50,
	"candle": 0.50,
	"cannonball": 0.50,
	"cartoon_pow": 0.50,
	"chain_lightning": 0.45,
	"charge_up": 0.50,
	"charmed": 0.50,
	"cherry_blossoms": 0.45,
	"chest_open": 0.50,
	"claw_swipe": 0.55,
	"clouds": 0.50,
	"coin_collect": 0.70,
	"coin_drop": 0.50,
	"coin_spin": 0.50,
	"collect_burst": 0.65,
	"combo_counter": 0.50,
	"confetti": 0.45,
	"confused": 0.50,
	"countdown": 0.50,
	"crit_hit": 0.55,
	"crit_number": 0.55,
	"crt_off": 0.50,
	"crystal_shard": 0.50,
	"curse": 0.50,
	"cursed": 0.50,
	"dagger_flurry": 0.50,
	"damage_number": 0.55,
	"dark_explosion": 0.50,
	"dash_strike": 0.50,
	"diamond_wipe": 0.50,
	"dirt_explosion": 0.50,
	"disintegrate": 0.50,
	"dissolve_burn": 0.50,
	"divine_shield": 0.75,
	"double_slash": 0.55,
	"dragon_golden_spiral": 0.50,
	"drip": 0.50,
	"earth_spike": 0.40,
	"earth_stomp": 0.50,
	"eclipse": 0.50,
	"egg_hatch": 0.50,
	"electrified": 0.50,
	"emp_blast": 0.50,
	"energy_core": 0.50,
	"energy_disc": 0.50,
	"exclamation": 0.55,
	"eyeball": 0.50,
	"falling_leaves": 0.45,
	"feather_burst": 0.50,
	"fire_breath": 0.50,
	"fire_ring": 0.45,
	"fire_tornado": 0.40,
	"fireball": 0.55,
	"fireball_throw": 0.50,
	"fireflies": 0.50,
	"firework_burst": 0.50,
	"firework_rocket": 0.50,
	"fish_school": 0.50,
	"flame_pillar": 0.45,
	"flamethrower": 0.50,
	"flare": 0.50,
	"flying_skull": 0.50,
	"fog": 0.50,
	"force_field": 0.50,
	"fountain": 0.50,
	"freeze": 0.55,
	"frog": 0.50,
	"frost_breath": 0.50,
	"frost_nova": 0.35,
	"frozen": 0.60,
	"gem_spin": 0.50,
	"geyser": 0.50,
	"ghost": 0.50,
	"glitch": 0.50,
	"glitch_wipe": 0.50,
	"god_rays": 0.50,
	"grasping_hands": 0.50,
	"grenade": 0.50,
	"ground_pound": 0.50,
	"ground_slam": 0.40,
	"halo": 0.60,
	"hammer_smash": 0.50,
	"haste": 0.50,
	"heal": 0.70,
	"heal_aoe": 0.50,
	"healing_bloom": 0.50,
	"health_bar_hit": 0.50,
	"heart_lost": 0.50,
	"heart_pickup": 0.65,
	"heavy_cleave": 0.50,
	"heavy_landing": 0.45,
	"hex_sigil": 0.45,
	"hit_flash": 0.60,
	"hit_spark": 0.65,
	"hologram": 0.50,
	"holy_pillar": 0.40,
	"holy_smite": 0.50,
	"homing_missile": 0.50,
	"ice_crystal": 0.50,
	"ice_lance": 0.50,
	"ice_lance_throw": 0.50,
	"ice_shatter": 0.50,
	"ice_spikes": 0.40,
	"icicle_fall": 0.50,
	"impact_frame": 0.50,
	"implosion": 0.50,
	"iris": 0.50,
	"jellyfish": 0.50,
	"jetpack": 0.50,
	"key_glint": 0.50,
	"laser_bolt": 0.50,
	"laser_grid": 0.50,
	"leaf_storm": 0.40,
	"level_up": 0.55,
	"life_steal": 0.50,
	"lightning_call": 0.50,
	"lightning_strike": 0.35,
	"loot_beam": 0.50,
	"magic_circle_cast": 0.50,
	"magic_missile": 0.50,
	"mana_burst": 0.45,
	"meteor": 0.40,
	"meteor_call": 0.50,
	"muzzle_pistol": 0.50,
	"muzzle_shotgun": 0.50,
	"muzzle_smg": 0.50,
	"necro_skulls": 0.50,
	"nhat_kiem_tram_thien_mon": 0.50,
	"nuke": 0.50,
	"parry": 0.55,
	"petrified": 0.50,
	"pistol_shots": 0.50,
	"pixel_dissolve": 0.50,
	"plasma_ball": 0.50,
	"plasma_explosion": 0.50,
	"plasma_shot": 0.50,
	"poison_cloud": 0.40,
	"poisoned": 0.60,
	"poof": 0.55,
	"portal": 0.45,
	"potion": 0.50,
	"power_star": 0.50,
	"quake": 0.40,
	"quest_complete": 0.50,
	"rage": 0.60,
	"rain": 0.45,
	"rain_splash": 0.50,
	"respawn_beam": 0.50,
	"resurrection": 0.50,
	"ricochet": 0.50,
	"ripples": 0.55,
	"rocket": 0.50,
	"rocket_launcher": 0.50,
	"root_snare": 0.45,
	"rune_circle": 0.40,
	"scanner": 0.50,
	"scythe_reap": 0.50,
	"shadow_flames": 0.50,
	"shadow_tendrils": 0.50,
	"shatter_death": 0.50,
	"shatter_wipe": 0.50,
	"shield_block": 0.60,
	"shooting_stars": 0.45,
	"slash_wipe": 0.50,
	"sleep": 0.50,
	"slime": 0.50,
	"slowed": 0.50,
	"small_explosion": 0.40,
	"smite": 0.45,
	"smoke_bomb": 0.45,
	"snake": 0.50,
	"snow": 0.45,
	"snowflake_burst": 0.50,
	"soul_drain": 0.50,
	"soul_rise": 0.50,
	"spark_arc": 0.55,
	"spawn_portal": 0.50,
	"spear_sweep": 0.50,
	"spell_charge": 0.55,
	"spin_slash": 0.55,
	"spirit_flame": 0.50,
	"splash": 0.50,
	"spore_burst": 0.50,
	"star_fall": 0.45,
	"star_iris": 0.50,
	"storm": 0.50,
	"storm_cloud": 0.50,
	"stunned": 0.60,
	"summon_rise": 0.45,
	"sunburst": 0.40,
	"sword_combo": 0.50,
	"sword_slash": 0.50,
	"teleporter_pad": 0.50,
	"tesla_coil": 0.50,
	"thorns": 0.50,
	"thrust": 0.55,
	"thunderclap": 0.45,
	"time_stop": 0.50,
	"torch": 0.50,
	"tornado": 0.40,
	"toxic_puddle": 0.50,
	"tractor_beam": 0.50,
	"uppercut": 0.55,
	"van_kiem_quy_tong": 0.48,
	"vine_whip": 0.50,
	"void_orb": 0.50,
	"warp_in": 0.50,
	"warp_out": 0.50,
	"water_jet": 0.50,
	"water_orb": 0.50,
	"waterfall": 0.50,
	"wave_crash": 0.50,
	"whip_crack": 0.50,
	"whirlpool": 0.40,
	"wisp": 0.50,
	"xp_orb": 0.70,
	"zap_hit": 0.55,
}

static var _framesCache : Dictionary = {}
static var _metaCache : Dictionary = {}

static func Has(key : String) -> bool:
	return CATALOG.has(NormalizeKey(key))

static func ResolvePath(key : String) -> String:
	var k := NormalizeKey(key)
	if not CATALOG.has(k):
		return ""
	return "%s/%s" % [ROOT, CATALOG[k]]

static func GetScale(key : String) -> float:
	var k := NormalizeKey(key)
	return float(DEFAULT_SCALE.get(k, DEFAULT_SCALE.get(key, 0.5)))

static func GetMeta(key : String) -> Dictionary:
	var k := NormalizeKey(key)
	_EnsureLoaded(k)
	return _metaCache.get(k, {})

## PixelFX #moves act timeline from sheet JSON meta.pixelfx.act
## Returns { hasAct, windup, onBody, hits:[{t,freeze,shake,amp,push,...}] }
static func GetAct(key : String) -> Dictionary:
	var meta : Dictionary = GetMeta(key)
	var act = meta.get("act", {})
	if typeof(act) != TYPE_DICTIONARY or act.is_empty():
		return {"hasAct": false, "windup": 0.0, "onBody": false, "hits": []}
	var hitsRaw = act.get("hits", [])
	var hits : Array = []
	if typeof(hitsRaw) == TYPE_ARRAY:
		for h in hitsRaw:
			if typeof(h) == TYPE_DICTIONARY:
				hits.append(h)
	return {
		"hasAct": true,
		"windup": float(act.get("windup", 0.0)),
		"onBody": bool(act.get("onBody", false)),
		"hits": hits,
	}

## Sum of frame durations for lifetime caps (moves sheets can be 2–6s+)
static func GetSheetDuration(key : String) -> float:
	var frames : SpriteFrames = GetSpriteFrames(key)
	var animName := StringName("default")
	if frames == null or not frames.has_animation(animName):
		return 1.0
	var total : float = 0.0
	var n : int = frames.get_frame_count(animName)
	for i in n:
		total += frames.get_frame_duration(animName, i)
	return maxf(total, 0.2)

static func GetSpriteFrames(key : String) -> SpriteFrames:
	var k := NormalizeKey(key)
	_EnsureLoaded(k)
	return _framesCache.get(k, null)

static func ElementKey(element : int, isCrit : bool = false) -> String:
	if isCrit:
		return "crit_hit"
	return ELEMENT_FX.get(element, "hit_spark")

static func ImpactKey(element : int, isCrit : bool = false) -> String:
	if isCrit:
		return "crit_hit"
	return IMPACT_FX.get(element, "hit_spark")

static func _EnsureLoaded(key : String) -> void:
	key = NormalizeKey(key)
	if _framesCache.has(key):
		return
	if not CATALOG.has(key):
		return
	var folder : String = ResolvePath(key)
	var idName : String = String(CATALOG[key]).get_file()
	var pngPath : String = "%s/%s.png" % [folder, idName]
	var jsonPath : String = "%s/%s.json" % [folder, idName]
	if not ResourceLoader.exists(pngPath) and not FileAccess.file_exists(pngPath):
		Util.PrintInfo("PixelFx", "Missing PNG for '%s' (%s)" % [key, pngPath])
		return
	if not FileAccess.file_exists(jsonPath):
		Util.PrintInfo("PixelFx", "Missing JSON for '%s' (%s)" % [key, jsonPath])
		return

	var tex : Texture2D = null
	if ResourceLoader.exists(pngPath):
		tex = load(pngPath) as Texture2D
	# Headless / fresh checkout: PNG may exist on disk without .import yet
	if tex == null and FileAccess.file_exists(pngPath):
		var img := Image.new()
		if img.load(pngPath) == OK:
			tex = ImageTexture.create_from_image(img)
	if tex == null:
		return

	var raw : String = FileAccess.get_file_as_string(jsonPath)
	var data = JSON.parse_string(raw)
	if typeof(data) != TYPE_DICTIONARY:
		return

	var meta : Dictionary = data.get("meta", {})
	var px : Dictionary = meta.get("pixelfx", {})
	var fps : float = float(px.get("fps", 12))
	var loop : bool = bool(px.get("loop", false))
	var pivot = px.get("pivot", [0, 0])
	var frameSize = px.get("frameSize", [0, 0])
	var frameW : int = 0
	var frameH : int = 0
	if typeof(frameSize) == TYPE_ARRAY and frameSize.size() >= 2:
		frameW = int(frameSize[0])
		frameH = int(frameSize[1])
	var pivotVec := Vector2.ZERO
	if typeof(pivot) == TYPE_ARRAY and pivot.size() >= 2:
		pivotVec = Vector2(float(pivot[0]), float(pivot[1]))
	# PixelFX gallery #moves — windup / hit freeze+shake baked into sheet meta
	var actData = px.get("act", {})
	var actDict : Dictionary = {}
	if typeof(actData) == TYPE_DICTIONARY:
		actDict = actData

	var framesRaw = data.get("frames", [])
	var frameList : Array = []
	if typeof(framesRaw) == TYPE_ARRAY:
		frameList = framesRaw
	elif typeof(framesRaw) == TYPE_DICTIONARY:
		var keys : Array = framesRaw.keys()
		keys.sort_custom(func(a, b): return str(a) < str(b))
		for fk in keys:
			frameList.append(framesRaw[fk])

	var sf := SpriteFrames.new()
	var animName := StringName("default")
	# SpriteFrames ships with a built-in "default" animation — reuse it
	if not sf.has_animation(animName):
		sf.add_animation(animName)
	sf.set_animation_loop(animName, loop)
	sf.set_animation_speed(animName, 1.0) # durations are absolute seconds via add_frame duration
	sf.clear(animName)

	for fr in frameList:
		if typeof(fr) != TYPE_DICTIONARY:
			continue
		var rectData = fr.get("frame", {})
		var x : int = int(rectData.get("x", 0))
		var y : int = int(rectData.get("y", 0))
		var w : int = int(rectData.get("w", frameW))
		var h : int = int(rectData.get("h", frameH))
		if w <= 0 or h <= 0:
			continue
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(x, y, w, h)
		var durMs : float = float(fr.get("duration", 1000.0 / maxf(fps, 1.0)))
		var frameDur : float = maxf(durMs / 1000.0, 0.01)
		sf.add_frame(animName, atlas, frameDur)
		if frameW <= 0:
			frameW = w
		if frameH <= 0:
			frameH = h

	_framesCache[key] = sf
	_metaCache[key] = {
		"fps": fps,
		"loop": loop,
		"pivot": pivotVec,
		"frame_w": frameW,
		"frame_h": frameH,
		"path": folder,
		"act": actDict,
		"blend_add": String(px.get("blend", "")) == "add",
	}
	Util.PrintLog("PixelFx", "Loaded '%s' (%d frames @ %.0ffps, loop=%s)" % [key, sf.get_frame_count(animName), fps, str(loop)])
