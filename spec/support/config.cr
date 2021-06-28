require "jennifer"
require "jennifer/adapter/postgres"

::Jennifer::Config.configure do |conf|
  conf.logger.level = :error
  conf.adapter = "postgres"
  conf.migration_files_path = "./spec/support/migrations"
  conf.db = "factory_test"

  conf.user = ENV["DB_USER"]? || "developer"
  conf.password = ENV["DB_PASSWORD"]? || "1qazxsw2"
end
