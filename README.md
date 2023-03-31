
How yo use Sidekiq Cron and Web in Plain Ruby?
==============================================

[Sidekiq](https://github.com/sidekiq/sidekiq) is a simple, efficient background processing for Ruby. It is completely integrated with Rails and is super easy to use. Have you ever tried to run it with plain ruby? In this article, I will run Sidekiq using its cron jobs and the monitoring panel in plain Ruby.

Sidekiq Web Panel

Intro
=====

For this article, you need to have ruby installed. I’m using ruby:3.1.3 and also dockerized everything at the end to make it easier.

Check out my other article about [Tips On Using Docker](https://medium.com/tips-on-using-docker-5c19c8ad17a2) since I use most of them here as well.

So what is Sidekiq? Why do we need it? Why do we need to run it in plain ruby?

Sidekiq
-------

Sidekiq is a simple, efficient background processing for Ruby.

> Sidekiq uses threads to handle many jobs at the same time in the same process. It does not require Rails but will integrate tightly with Rails to make background processing dead simple.

Sidekiq Cron
------------

> Sidekiq-Cron runs a thread alongside Sidekiq workers to schedule jobs at specified times (using cron notation `* * * * *` parsed by [Fugit](https://github.com/floraison/fugit)).
> 
> Checks for new jobs to schedule every 30 seconds and doesn’t schedule the same job multiple times when more than one Sidekiq worker is running.
> 
> Scheduling jobs are added only when at least one Sidekiq process is running, but it is safe to use Sidekiq-Cron in environments where multiple Sidekiq processes or nodes are running.

Sidekiq Web
-----------

It’s a built-in panel to monitor the Sidekiq jobs and cron.

You could always use the system cron jobs and also use shell scripts to do the scheduled stuff for you, however, sometimes using Ruby is easier and handier.

Setup
=====

First of all, you need to run the `bundle init` to create a Gemfile.

After running the command you could see a file called Gemfile like this

```
\# frozen\_string\_literal: true  
  
source "https://rubygems.org"  
  
\# gem "rails"
```

Now edit this file and add these gems to it.

```
\# Gemfile  
  
\# frozen\_string\_literal: true  
  
source "https://rubygems.org"  
  
gem 'sidekiq'  
gem 'sidekiq-cron'
```

Then run `$ bundle install` to install the gems.

How to run Sidekiq?
===================

For running Sidekiq you need to have Redis first. I assume you have installed Redis or running a container with docker. Also, you need to create a config file for Sidekiq. I added a file like this at `config/sidekiq_config.yml`

```
\# config/sidekiq\_config.yml  
  
\---  
:verbose: true  
:concurrency: 10  
:timeout: 300  
  
:queues:  
  - default
```

Moreover, we need to define a job for Sidekiq. Let’s add the `lib/jobs/sample.rb` file like below.

```
\# lib/jobs/sample.rb  
require 'sidekiq'  
  
class Sample  
  include Sidekiq::Job  
  def perform  
    file\_name = "./logs/logs.log"  
    File.write(file\_name, "Hello #{Time.now}\\n", mode: 'a')  
  end  
end
```

Sidekiq uses 2 environment variables to get the Redis URL. `REDIS_PROVIDER` is like a pointer to the name of the environment variable containing the address. I’m using these environment variables.

```
REDIS\_PROVIDER=REDIS\_URL  
REDIS\_URL=redis://127.0.0.1:6379/1
```

Now let’s run Sidekiq with the command below.

```
  
REDIS\_PROVIDER=REDIS\_URL REDIS\_URL=redis://127.0.0.1:6379/1 bundle exec sidekiq -C config/sidekiq\_config.yml -r $PWD/lib/jobs/sample.rb
```

If everything works fine you should see something like this in the console which means Sidekiq has run successfully.

```
 m,  
               \`$b  
          .ss,  $$:         .,d$  
          \`$$P,d$P'    .,md$P"'  
           ,$$$$$b/md$$$P^'                                                                                           \[0/356\]  
         .d$$$$$$/$$$P'  
         $$^' \`"/$$$'       \_\_\_\_  \_     \_      \_    \_  
         $:    ',$$:       / \_\_\_|(\_) \_\_| | \_\_\_| | \_(\_) \_\_ \_  
         \`b     :$$        \\\_\_\_ \\| |/ \_\` |/ \_ \\ |/ / |/ \_\` |  
                $$:         \_\_\_) | | (\_| |  \_\_/   <| | (\_| |  
                $$         |\_\_\_\_/|\_|\\\_\_,\_|\\\_\_\_|\_|\\\_\\\_|\\\_\_, |  
              .d$$                                       |\_|  
  
  
2023-03-30T21:21:35.714Z pid=2526 tid=e6 INFO: Running in ruby 3.1.3p185 (2022-11-24 revision 1a6b16756e) \[arm64-darwin22\]  
2023-03-30T21:21:35.714Z pid=2526 tid=e6 INFO: See LICENSE and the LGPL-3.0 for licensing details.  
2023-03-30T21:21:35.714Z pid=2526 tid=e6 INFO: Upgrade to Sidekiq Pro for more features and support: https://sidekiq.org  
2023-03-30T21:21:35.715Z pid=2526 tid=e6 INFO: Sidekiq 7.0.7 connecting to Redis with options {:size=>5, :pool\_name=>"internal", :url=>"redis://127.0.0.1:6379/1"}  
2023-03-30T21:21:35.722Z pid=2526 tid=e6 INFO: Sidekiq 7.0.7 connecting to Redis with options {:size=>10, :pool\_name=>"default", :url=>"redis://127.0.0.1:6379/1"}  
2023-03-30T21:21:35.722Z pid=2526 tid=e6 DEBUG: Firing startup event  
2023-03-30T21:21:35.722Z pid=2526 tid=e6 DEBUG: Client Middleware:  
2023-03-30T21:21:35.722Z pid=2526 tid=e6 DEBUG: Server Middleware: Sidekiq::Metrics::Middleware  
2023-03-30T21:21:35.722Z pid=2526 tid=e6 INFO: Starting processing, hit Ctrl-C to stop  
2023-03-30T21:21:35.722Z pid=2526 tid=e6 DEBUG: {:labels=>#<Set: {}>, :require=>"/Users/zlf/projects/sidekiq-in-plain-ruby/lib/jobs/sample.rb", :environment=>nil, :concurrency=>10, :timeout=>300, :poll\_interval\_average=>nil, :average\_scheduled\_poll\_interval=>5, :on\_complex\_arguments=>:raise, :error\_handlers=>\[#<Proc:0x0000000106a2fc90 /Users/zlf/.rbenv/versions/3.1.3/lib/ruby/gems/3.1.0/gems/sidekiq-7.0.7/lib/sidekiq/config.rb:36 (lambda)>\], :death\_handlers=>\[\], :lifecycle\_events=>{:startup=>\[\], :quiet=>\[\], :shutdown=>\[\], :heartbeat=>\[\], :beat=>\[#<Proc:0x0000000106bfbee8 /Users/zlf/.rbenv/versions/3.1.3/lib/ruby/gems/3.1.0/gems/sidekiq-7.0.7/lib/sidekiq/metrics/tracking.rb:133>\]}, :dead\_max\_jobs=>10000, :dead\_timeout\_in\_seconds=>15552000, :reloader=>#<Proc:0x0000000106a2fd58 /Users/zlf/.rbenv/versions/3.1.3/lib/ruby/gems/3.1.0/gems/sidekiq-7.0.7/lib/sidekiq/config.rb:33>, :verbose=>true, :queues=>\["default"\], :config\_file=>"config/sidekiq\_config.yml", :identity=>"Zlfs-MacBook-Pro.local:2526:9e99d1b47c47"}  
2023-03-30T21:21:35.736Z pid=2526 tid=42 DEBUG: Firing heartbeat event
```

This means Sidekiq knows how to handle the Sample job now and if we push a job like this it will be processed. In a couple of next steps, we are going to move things a little and add `sidekiq-cron` so the Sample job be processed in the background with the given schedule.

How to Add Cron Jobs?
=====================

We already installed `sidekiq-cron` gem. Now we are going to add the schedule file and tell Sidekiq about it.

Firstly, we are going to add `config/schedule.yml` to define how often which job should be processed.

```
\# config/schedule.yml  
  
sample:  
  cron: "\* \* \* \* \*"  
  class: "Sample"  
  queue: default
```

Next, we need to add a Ruby script to tell Sidekiq about these schedules. Now let’s create `crons.rb` file with the content below.

```
 1 require 'yaml'  
  2 require 'sidekiq'  
  3 require 'sidekiq-cron'  
  
  4 Dir\['lib/\*\*/\*.rb'\].each { |f| require\_relative f }  
  5  
  6 schedule\_file = "./config/schedule.yml"  
  7 Sidekiq::Cron::Job.load\_from\_hash YAML.load\_file(schedule\_file)
```

In the first 3 lines, we have added the required packages.

In line 4 we added all the ruby files in `lib` the directory.

In the last 2 lines, we have loaded the `config/schedule.yml` file and tell Sidekiq about it.

Now we are going to run Sidekiq again with a little change, this time we will only require `crons.rb` file for Sidekiq and it will take care of the rest.

```
  
REDIS\_PROVIDER=REDIS\_URL REDIS\_URL=redis://127.0.0.1:6379/1 bundle exec sidekiq -C config/sidekiq\_config.yml -r $PWD/crons.rb
```

Now if everything went well, after 1 minute you could see something like this in your console.

```
  
2023-03-30T21:43:18.269Z pid=5366 tid=5tu class=Sample jid=068e61eeb4cc5e58f818385f INFO: start  
2023-03-30T21:43:18.271Z pid=5366 tid=5tu class=Sample jid=068e61eeb4cc5e58f818385f elapsed=0.002 INFO: done
```

Also if you check the `logs/logs.log` file, there should be a line added like this

```
  
Hello 2023-03-31 01:13:18 +0330
```

Now you can add as many as custom jobs you want in `lib/jobs/` the directory. Just remember that each of them should have a unique class name, have `include Sidekiq::Job` at the beginning, and a `perform` method that Sidekiq understands to run.

How to Add Web Monitoring?
==========================

Sidekiq comes with a built-in web monitoring panel which you could easily run and monitor the jobs and cron jobs. For running the `sidekiq/web` panel we need to add these lines to `Gemfile` and run `bundle install` .

```
\# Gemfile  
  
...  
gem 'rackup'  
gem 'rack-session'  
...  

```

Now we need a `rackup` file to run `Sidekiq::Web` panel. Let’s add `lib/web/panel.ru` file with the content below.

```
 1 require 'sidekiq/web'  
  2 require 'sidekiq/cron/web'  
  3 require 'rack/session'  
  4 require 'securerandom'  
  5  
  6 File.open(".session.key", "w") {|f| f.write(SecureRandom.hex(32)) } unless File.exists?(".session.key")  
  7  
  8 use Rack::Session::Cookie, secret: File.read(".session.key"), same\_site: true, max\_age: 86400  
  9  
 10 run Sidekiq::Web
```

We have added the required packages from lines 1 to 4. In line 6 we have added a secure random string as a valid rack session otherwise we would have seen an error like below.

Now let’s run the web panel in a separate terminal with the command below

```
  
REDIS\_PROVIDER=REDIS\_URL REDIS\_URL=redis://127.0.0.1:6379/1 bundle exec rackup lib/web/panel.ru -o 0.0.0.0 -p 9292
```

Open `127.0.0.1:9292` in your browser and you should see the panel below.

I have pushed all the related codes in a github project called [azolf/sidekiq-in-plain-ruby](https://github.com/azolf/sidekiq-in-plain-ruby).

Also, I have dockerized everything and you could run the sample with just

`docker-compose up -d` .
