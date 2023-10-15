extends QodotEntity

#Path Corner
var path_name:String = ""
var path_index:int 
var speed:int 
var delay:float 

enum {CONSTANT,LERP}
var path_speed_type:int = CONSTANT

func update_properties():
	if (!Engine.is_editor_hint()):
		return;
	#set_rotation_degrees(GameManager::demangler(properties));
	rotation_degrees =(demangler(properties))
	if (properties.has("path_index")):
		path_index = properties["path_index"]
	## Speed of 0 maintains current velocity; make sure to set the first path node's speed!
	if (properties.has("speed")):
		speed = properties["speed"]
	## Time in seconds to wait before moving onto the next node
	if (properties.has("delay")):
		delay = properties["delay"]
	if (properties.has("path_speed_type")):
		path_speed_type = properties.path_speed_type


func _ready():
	if (!Engine.is_editor_hint() && properties.has("path_name")):
		path_name = properties["path_name"];
		add_to_group("path_" + path_name);
	if (properties.has("path_index")):
		path_index = properties["path_index"]
	if (properties.has("delay")):
		delay = properties["delay"]

#static Vector3 demangler(Dictionary properties, int mangle_type = 0)
func demangler(properties:Dictionary,mangle_type:int = 0) -> Vector3:
	if (properties.has("mangle")):
		var mangle:Vector3 = Vector3.ZERO
		if typeof(properties["mangle"]) == TYPE_VECTOR3:
			mangle = properties["mangle"]
		elif typeof(properties["mangle"]) == TYPE_STRING:
			var v:String = properties["mangle"];
			var arr:Array = v.split(" ");
			v = arr[0];
			mangle.x = v.to_float();
			v = arr[1];
			mangle.y = v.to_float();
			v = arr[2];
			mangle.z = v.to_float();
		if (mangle_type == 0): # actors, items, etc...
			mangle = Vector3(mangle.x, mangle.y + 180.0, -mangle.z);
		elif (mangle_type == 1): # lights
			mangle = Vector3(mangle.y, mangle.x + 180.0, -mangle.z);
		elif (mangle_type == 2): # info_intermission
			mangle = Vector3(-mangle.x, mangle.y + 180.0, -mangle.z);
		return mangle;
	return Vector3(0.0, 180.0, 0.0);

