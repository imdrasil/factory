require "sam"
require "./config"
require "./models.cr"
require "./migrations/*"

load_dependencies "jennifer"

Sam.help
