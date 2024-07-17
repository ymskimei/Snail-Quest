extends Control

export var server: PackedScene

onready var username_edit: LineEdit = $VBoxContainer/GridContainer/LineEdit
onready var ip_edit: LineEdit = $VBoxContainer/GridContainer/LineEdit2
onready var port_edit: LineEdit = $VBoxContainer/GridContainer/LineEdit3

onready var waiting: Popup = $Waiting
onready var clients_list: ItemList = $Waiting/VBoxContainer/ItemList
onready var ready: Button = $Waiting/VBoxContainer/Button
onready var create_server: Button = $VBoxContainer/Button2

func _ready() -> void:
	username_edit.set_text(Server.username)
	ip_edit.set_text(Server.DEFAULT_IP)
	port_edit.set_text(str(Server.DEFAULT_PORT))
	$VBoxContainer/Button.grab_focus()

func update_clients_list(clients) -> void:
	clients_list.clear()
	for client_id in clients:
		var client = clients[client_id]["username"]
		print(client)
		clients_list.add_item(client, null, false)

func _on_create_Button_pressed() -> void:
	SnailQuest.add_child(load("res://source/scripts/network/Server.tscn").instance())
	create_server.set_disabled(true)

func _on_connection_Button_pressed() -> void:
	Server.username = username_edit.get_text()
	Server.selected_ip = ip_edit.get_text()
	Server.selected_port = int(port_edit.get_text())
	Server.connect_to_server()
	waiting.popup_centered()

func _on_ready_Button_pressed():
	ready.set_disabled(true)
