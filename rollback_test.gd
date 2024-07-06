extends Node3D

const DummyNetworkAdaptor = preload ("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

const LOG_FILE_DIRECTORY = 'user://detailed_logs'

var logging_enabled := true

@export var IS_SERVER := true
@export var IP_ADDRESS := '127.0.0.1'
@export var PORT := 9999

func _ready() -> void:
  multiplayer.connect("peer_connected", _on_network_peer_connected)
  multiplayer.connect("peer_disconnected", _on_network_peer_disconnected)
  multiplayer.connect("server_disconnected", _on_server_disconnected)
  SyncManager.connect("sync_started", _on_SyncManager_sync_started)
  SyncManager.connect("sync_stopped", _on_SyncManager_sync_stopped)
  SyncManager.connect("sync_lost", _on_SyncManager_sync_lost)
  SyncManager.connect("sync_regained", _on_SyncManager_sync_regained)
  SyncManager.connect("sync_error", _on_SyncManager_sync_error)

  if OS.get_cmdline_args().has("server"):
    IS_SERVER = true
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(PORT)
    multiplayer.multiplayer_peer = peer
    print("Server Listening at: ", IP_ADDRESS, ":", PORT)
  else:
    IS_SERVER = false
    await get_tree().create_timer(1.0).timeout
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(IP_ADDRESS, PORT)
    multiplayer.multiplayer_peer = peer
    print("Client connecting to server at: ", IP_ADDRESS, ":", PORT)

func _on_network_peer_connected(peer_id: int):
  print(peer_id, " connected!")
  SyncManager.add_peer(peer_id)
  
  #$ServerPlayer.set_network_master(1)
  #if get_tree().is_network_server():
  #$ClientPlayer.set_network_master(peer_id)
  #else:
  #$ClientPlayer.set_network_master(get_tree().get_network_unique_id())
  
  if multiplayer.is_server():
    print("Starting match...")
    rpc ("setup_match", {})
  
    # Give a little time to get ping data.
    await get_tree().create_timer(2.0).timeout
    SyncManager.start()

@rpc("any_peer", "call_local") func setup_match(info: Dictionary) -> void:
  #johnny.set_seed(info['mother_seed'])
  #$ClientPlayer.rng.set_seed(johnny.randi())
  #$ServerPlayer.rng.set_seed(johnny.randi())
  pass

func _on_network_peer_disconnected(peer_id: int):
  print(peer_id, " disconnected")
  SyncManager.remove_peer(peer_id)

func _on_server_disconnected() -> void:
  _on_network_peer_disconnected(1)

func _on_SyncManager_sync_started() -> void:
  print("Sync started!")
  
  if logging_enabled and not SyncReplay.active:
    var dir = DirAccess.open("user://")
    if not dir.dir_exists(LOG_FILE_DIRECTORY):
      dir.make_dir(LOG_FILE_DIRECTORY)
  
    var datetime = Time.get_datetime_dict_from_system()
    var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
    datetime['year'],
    datetime['month'],
    datetime['day'],
    datetime['hour'],
    datetime['minute'],
    datetime['second'],
    SyncManager.network_adaptor.get_unique_id(),
    ]
  
    SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)

func _on_SyncManager_sync_stopped() -> void:
  if logging_enabled:
    SyncManager.stop_logging()

func _on_SyncManager_sync_lost() -> void:
  #sync_lost_label.visible = true
  print("Sync lost!")

func _on_SyncManager_sync_regained() -> void:
  #sync_lost_label.visible = false
  print("Sync regained!")

func _on_SyncManager_sync_error(msg: String) -> void:
  #message_label.text = "Fatal sync error: " + msg
  #sync_lost_label.visible = false
  print("Fatal sync error! ", msg)
  
  var peer = multiplayer.network_peer
  if peer:
    peer.close_connection()
    SyncManager.clear_peers()

func setup_match_for_replay(my_peer_id: int, peer_ids: Array, match_info: Dictionary) -> void:
  #main_menu.visible = false
  #connection_panel.visible = false
  #reset_button.visible = false
  pass

func _on_OnlineButton_pressed() -> void:
  #connection_panel.popup_centered()
  SyncManager.reset_network_adaptor()

func _on_LocalButton_pressed() -> void:
  #$ClientPlayer.input_prefix = "player2_"
  #main_menu.visible = false
  #SyncManager.network_adaptor = DummyNetworkAdaptor.new()
  #SyncManager.start()
  pass
