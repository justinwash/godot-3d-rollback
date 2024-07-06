extends Node3D

var t = 0

@onready var block1 = $Block1
@onready var block2 = $Block2
@onready var ball = $Ball

var run = 0

var init_transform = {}

var end_transform = {}

func _ready():
  init_transform.block1 = block1.global_transform
  init_transform.block2 = block2.global_transform
  init_transform.ball = ball.global_transform

func _physics_process(delta):
  if t == 0:
    block1.linear_velocity = Vector3.ZERO
    block1.angular_velocity = Vector3.ZERO
    block2.linear_velocity = Vector3.ZERO
    block2.angular_velocity = Vector3.ZERO
    ball.linear_velocity = Vector3.ZERO
    ball.angular_velocity = Vector3.ZERO
      
    block1.global_transform = init_transform.block1
    block2.global_transform = init_transform.block2
    ball.global_transform = init_transform.ball
    
  if t == 300:
    if run < 1:
      end_transform.block1 = block1.global_transform
      end_transform.block2 = block2.global_transform
      end_transform.ball = ball.global_transform
      
      t = 0
      run += 1
      return
      
    else:
      print("Block1 Transform equality: ", block1.global_transform == end_transform.block1)
      print("Block2 Transform equality: ", block2.global_transform == end_transform.block2)
      print("Ball Transform equality: ", ball.global_transform == end_transform.ball)
      
      if block1.global_transform != end_transform.block1 || block2.global_transform != end_transform.block2 || ball.global_transform != end_transform.ball:
        get_tree().quit()
      t = 0
      run += 1
      return
  
  t += 1
