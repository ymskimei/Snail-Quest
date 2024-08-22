class_name RegistryColor
extends Node

const white: String = "FFFFFF"
const light_gray: String = "E5E0E0"
const gray: String = "C1B8C0"
const dark_gray: String = "818491"
const black: String = "000000"

const light_red: String = "FFB2B7"
const light_orange: String = "FFC69B"
const light_yellow: String = "F7F2CA"
const light_lime: String = "D1EAAF"
const light_green: String = "9AEAC2"
const light_cyan: String = "C9FFFC"
const light_blue: String = "89C8FF"
const light_purple: String = "DBACFE"
const light_magenta: String = "F8C7FE"
const light_pink: String = "FFCCEB"

const red: String = "FF565F"
const orange: String = "FFAA5B"
const yellow: String = "F9EB7A"
const lime: String = "ACE06D"
const green: String = "5DDD9F"
const cyan: String = "8FEAE6"
const blue: String = "4286F4"
const purple: String = "A860F1"
const magenta: String = "F48EFD"
const pink: String = "FF8BCD"

const dark_red: String = "C12C4A"
const dark_orange: String = "CC7451"
const dark_yellow: String = "D3A23F"
const dark_lime: String = "7BB548"
const dark_green: String = "37B274"
const dark_cyan: String = "41C5D3"
const dark_blue: String = "2560BF"
const dark_purple: String = "9842D4"
const dark_magenta: String = "DE58E8"
const dark_pink: String = "EA62AF"

static func get_bbcode(color: String) -> String:
	return "[color=#" + color + "]"
