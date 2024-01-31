class_name ResourceIdentitySnail
extends ResourceIdentity

@export var mesh_shell: Mesh
@export var mesh_body: Mesh
@export var mesh_eye_left: Mesh
@export var mesh_eye_right: Mesh

@export var pattern_shell: Texture2D
@export var pattern_body: Texture2D
@export var pattern_eyes: Texture2D
@export var pattern_eyelids: Texture2D

@export var color_shell_base: Color = Color("FFFFFF")
@export var color_shell_base_shade: Color = Color("FFFFFF")
@export var color_shell_accent: Color = Color("FFFFFF")

@export var color_body_specular: Color = Color("FFFFFF")
@export var color_body: Color = Color("FFFFFF")
@export var color_body_shade: Color = Color("FFFFFF")
@export var color_body_accent: Color = Color("FFFFFF")

@export var color_eye_left: Color = Color("FFFFFF")
@export var color_eye_right: Color = Color("FFFFFF")
