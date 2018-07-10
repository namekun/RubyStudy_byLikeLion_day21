# config/initializers/pusher.rb
require 'pusher'

Pusher.app_id = ENV["Pusher_app_id"]
Pusher.key = ENV["Pusher_key"]
Pusher.secret = ENV["Pusher_secret"]
Pusher.cluster = ENV["Pusher_cluster"]
Pusher.logger = Rails.logger
Pusher.encrypted = true
