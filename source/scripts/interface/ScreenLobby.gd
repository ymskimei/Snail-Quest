extends Control

export var server: PackedScene

onready var username_edit: LineEdit = $VBoxContainer/GridContainer/LineEdit
onready var ip_edit: LineEdit = $VBoxContainer/GridContainer/LineEdit2

onready var waiting: Popup = $Waiting
onready var clients_list: ItemList = $Waiting/VBoxContainer/ItemList

onready var ready: Button = $Waiting/VBoxContainer/Button
onready var create_server: Button = $VBoxContainer/Button2

var ready_clients: int = 0
var can_start: bool = false

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	
	username_edit.set_text(Network.username)
	ip_edit.set_text(Network.ip)

	$VBoxContainer/Button.grab_focus()

func _on_network_peer_connected(client_id) -> void:
	print("Client " + str(client_id) + " has connected")
	if ready_clients <= 0:
		ready_clients = 2
	else:
		ready_clients += 1
	if ready_clients >= 2:
		get_parent().change_screen(SnailQuest.multi_world)
	_create_controlled_instance(client_id)

func _on_network_peer_disconnected(client_id) -> void:
	print("Client " + str(client_id) + " has disconnected")

func _on_connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	_create_controlled_instance(Network.client_local_id)

func _on_create_Button_pressed() -> void:
	update_server_data()
	Network.create_server()
	ready_clients += 1
	waiting.popup_centered()
	_create_controlled_instance(Network.client_local_id)
	
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
	ready.grab_focus()

func _on_ready_Button_pressed():
	ready.set_disabled(true)

func _create_controlled_instance(client_id) -> void:
	var controlled_instance = load("res://source/scenes/entity/snail.tscn").instance()
	controlled_instance.set_network_master(client_id)
	controlled_instance.set_name("Snail" + str(client_id))
	controlled_instance.get_entity_identity().set_entity_name(str(client_id))
	Network.controlled_instances.append(controlled_instance)
	print(Network.controlled_instances)
