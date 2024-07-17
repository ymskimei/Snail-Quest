extends Node

const DEFAULT_PORT: int = 20167
const MAX_CLIENTS: int = 4

var server
var client

var ip: String
var username: String

var local_client_id: int = 0

sync var clients: Dictionary = {}
sync var client_data: Dictionary = {}

func _ready() -> void:
	match OS.get_name():
		"Windows":
			ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), 1)
			username = OS.get_environment("USERNAME")
		"OSX":
			ip = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), 1)
			username = OS.get_environment("USER")
		"X11":
			ip = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), 1)
			username = OS.get_environment("USER")

	for i in IP.get_local_addresses():
		if i.begins_with("192.168."):
			ip = i

	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	print("Server started")

func _on_connected_to_server() -> void:
	print("Connection successful")
	register_client_data()
	rpc_id(1, "send_client_data", local_client_id, client_data)

func _on_server_disconnected() -> void:
	print("Connection ended")

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func register_client_data() -> void:
	local_client_id = get_tree().get_network_unique_id()
	client_data = {
		"username": username
	}
	clients[local_client_id] = client_data

sync func update_clients_list() -> void:
	get_tree().call_group("Lobby", "update_clients_list", clients)

remote func send_client_data(client_id, client_data) -> void:
	clients[client_id] = client_data
	rset("clients", clients)
	rpc("update_clients_list")

func set_username(new_name: String) -> void:
	username = new_name

func get_username() -> String:
	return username

func set_ip(new_ip: String) -> void:
	ip = new_ip

func get_ip() -> String:
	return ip
