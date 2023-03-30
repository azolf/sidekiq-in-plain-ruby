class Sample
  include Sidekiq::Job
  def perform
    file_name = "./logs/logs.log"
    File.write(file_name, "Hello #{Time.now}\n", mode: 'a')
  end
end
