require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'rack/session'
require 'securerandom'

File.open(".session.key", "w") {|f| f.write(SecureRandom.hex(32)) } unless File.exists?(".session.key")

use Rack::Session::Cookie, secret: File.read(".session.key"), same_site: true, max_age: 86400

run Sidekiq::Web
