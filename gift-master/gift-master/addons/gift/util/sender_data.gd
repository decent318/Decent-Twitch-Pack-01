class_name SenderData
extends RefCounted

var user : String
var channel : String
var tags : Dictionary


func _init(usr : String, ch : String, tag_dict : Dictionary):
	user = usr
	channel = ch
	tags = tag_dict
