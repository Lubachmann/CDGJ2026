extends Control

var dummyData = [
	{"name": "smo", "score": 1000},
	{"name": "thi", "score": 2000},
	{"name": "guy", "score": 99999},
	{"name": "ano", "score": 9000}
]

var BaseHbox
var ScoreBoardRoot

func ReadScoreFromFile():
	var file = FileAccess.open("user://highscores.json", FileAccess.READ)
	if file == null:
		push_error("Failed to open file")
		return []

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var result = json.parse(json_string)

	if result != OK:
		push_error("JSON parse error")
		return []

	return json.data
	
func SaveScoreToFile(data: Array[Dictionary]):
	var existingData: Array[Dictionary] = ReadScoreFromFile()
	existingData.append_array(data)
	
	var file = FileAccess.open("user://highscores.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(existingData, "\t"))
	file.close()

func _on_visibility_changed() -> void:
	BaseHbox = preload("res://scene/HighscoreEntrie.tscn")
	ScoreBoardRoot = $VBoxContainer
	SaveScoreToFile(dummyData)
	var sortedScore = QuickSortScoreList(ReadScoreFromFile())

	for i in range(sortedScore.size()):
		var tempBox = BaseHbox.instantiate()
		ScoreBoardRoot.add_child(tempBox)
		ScoreBoardRoot.get_child(i).get_child(0).text = str(i + 1)+"."
		ScoreBoardRoot.get_child(i).get_child(2).text = sortedScore[i]["name"]
		ScoreBoardRoot.get_child(i).get_child(4).text = str(int(sortedScore[i]["score"]))

func QuickSortScoreList(list: Array) -> Array:
	if list.size() <= 1:
		return list

	var pivot = list[0]
	var smaller: Array = []
	var bigger: Array = []

	for i in range(1, list.size()):
		if list[i]["score"] > pivot["score"]:
			bigger.append(list[i])
		else:
			smaller.append(list[i])

	return QuickSortScoreList(bigger) + [pivot] + QuickSortScoreList(smaller)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")
	pass # Replace with function body.
