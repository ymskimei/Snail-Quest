extends Node

var network = NetworkedMultiplayerENet.new()
var port = 3234
var max_clients = 4

var clients = {}

func _ready() -> void:
	network.create_server(port, max_clients)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_client_connected")
	network.connect("peer_disconnected", self, "_client_disconnected")
	print("Server started")
	
func _client_connected(client_id) -> void:
	print("Client " + str(client_id) + " connected")
	
func _client_disconnected(client_id) -> void:
	print("Client " + str(client_id) + " disconnected")
	
remote func send_client_data(client_id, client_data) -> void:
	clients[client_id] = client_data
	rset("clients", clients)
	rpc("update_clients_list")
