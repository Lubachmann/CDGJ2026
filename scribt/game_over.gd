extends Control

#var dummyData = {"name": "smo", "score": 1000}

var BaseHbox
var ScoreBoardRoot
var ScoreInputRoot

var ScoreInputName
var ScoreInputScore

func ReadScoreFromFile() -> Array:
	if !FileAccess.file_exists("user://highscores.json"):
		return []

	var file = FileAccess.open("user://highscores.json", FileAccess.READ)
	if file == null:
		return []

	var text = file.get_as_text()
	file.close()

	if text.strip_edges() == "":
		return []

	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		push_error("JSON parse error")
		return []

	if typeof(json.data) != TYPE_ARRAY:
		push_error("JSON is not an array!")
		return []

	return json.data
	
func SaveScoreToFile(new_scores: Dictionary):
	var existingData = ReadScoreFromFile()
	
	if typeof(new_scores) == TYPE_DICTIONARY:
		existingData.append(new_scores)

	var file = FileAccess.open("user://highscores.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(existingData, "\t"))
	file.close()

func _on_visibility_changed() -> void:
	ScoreInputName = $VBoxContainer2/LineEdit
	ScoreInputScore = $VBoxContainer2/HBoxContainer/Label2
	
	ScoreInputScore.text = GetScore()
	
	BaseHbox = preload("res://scene/HighscoreEntrie.tscn")
	ScoreBoardRoot = $VBoxContainer
	#SaveScoreToFile(dummyData)
	var sortedScore = ReadScoreFromFile()
	sortedScore.sort_custom(func(a, b):
		return a["score"] > b["score"]
	)

	for i in range(sortedScore.size()):
		var tempBox = BaseHbox.instantiate()
		ScoreBoardRoot.add_child(tempBox)
		ScoreBoardRoot.get_child(i).get_child(0).text = str(i + 1)+"."
		ScoreBoardRoot.get_child(i).get_child(2).text = sortedScore[i]["name"]
		ScoreBoardRoot.get_child(i).get_child(4).text = str(int(sortedScore[i]["score"]))

func GetScore() -> int:
	return 0

func _on_button_pressed() -> void:
	var newScore = {
		"name": ScoreInputName.text,
		"score": int(ScoreInputScore.text)
	}
	SaveScoreToFile(newScore)
	
	get_tree().change_scene_to_file("res://scene/main.tscn")
	pass # Replace with function body.
