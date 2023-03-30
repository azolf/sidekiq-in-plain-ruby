require 'yaml'
require 'sidekiq'
require 'sidekiq-cron'
Dir['lib/**/*.rb'].each { |f| require_relative f }

schedule_file = "./config/schedule.yml"
Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)

