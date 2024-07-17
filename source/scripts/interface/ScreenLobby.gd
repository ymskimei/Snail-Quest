extends Control

export var server: PackedScene

onready var username_edit: LineEdit = $VBoxContainer/GridContainer/LineEdit
onready var ip_edit: LineEdit = $VBoxContainer/GridContainer/LineEdit2

onready var waiting: Popup = $Waiting
onready var clients_list: ItemList = $Waiting/VBoxContainer/ItemList

onready var ready: Button = $Waiting/VBoxContainer/Button
onready var create_server: Button = $VBoxContainer/Button2

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_network_on_peer_disconnected")

	username_edit.set_text(Network.username)
	ip_edit.set_text(Network.ip)

	$VBoxContainer/Button.grab_focus()

func _on_network_peer_connected(client_id) -> void:
	print("Client " + str(client_id) + " has connected")

func _on_network_peer_disconnected(client_id) -> void:
	print("Client " + str(client_id) + " has disconnected")

func _on_create_Button_pressed() -> void:
	update_server_data()
	Network.create_server()
	waiting.popup_centered()

func _on_connection_Button_pressed() -> void:
	update_server_data()
	Network.join_server()
	waiting.popup_centered()

func update_server_data() -> void:
	Network.set_username(username_edit.get_text())
	Network.set_ip(ip_edit.get_text())

func update_clients_list(clients) -> void:
	clients_list.clear()
	for client_id in clients:
		var client = clients[client_id]["username"]
		print(client)
		clients_list.add_item(client, null, false)

func _on_ready_Button_pressed():
	ready.set_disabled(true)
