extends Node

var network: NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()

const DEFAULT_IP: String = "127.0.0.1"
const DEFAULT_PORT: int = 3234

var username: String
var selected_ip: String
var selected_port: int

var ip: String
var local_client_id: int = 0

var max_clients: int = 4

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

	get_tree().connect("network_peer_connected", self, "_on_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_client_disconnect")

	get_tree().connect("connection_failed", self, "_on_client_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_server_disconnect")

func connect_to_server() -> void:
	get_tree().connect("connected_to_server", self, "_on_client_connection_success")
	network.create_client(selected_ip, selected_port)
	get_tree().set_network_peer(network)

func _on_client_connected(client_id) -> void:
	print("Client " + str(client_id) + " has connected")

func _on_client_disconnect(client_id) -> void:
	print("Client " + str(client_id) + " has disconnected")

func _on_client_connection_success() -> void:
	print("Connection successful")
	register_client_data()
	rpc_id(1, "send_client_data", local_client_id, client_data)

func _on_client_connection_failed() -> void:
	print("Connection failed")

func _on_server_disconnect() -> void:
	print("Server disconnected")

func register_client_data() -> void:
	local_client_id = get_tree().get_network_unique_id()
	client_data = {
		"username": username
	}
	clients[local_client_id] = client_data

sync func update_clients_list() -> void:
	get_tree().call_group("Lobby", "update_clients_list", clients)
