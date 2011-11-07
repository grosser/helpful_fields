task :spec do
  sh "rspec spec"
end

task :default do
  sh "RAILS=2.3.12 && (bundle || bundle install) && bundle exec rake spec"
  sh "RAILS=3.0.9 && (bundle || bundle install) && exec rake spec"
  sh "RAILS=3.1.0.rc4 && (bundle || bundle install) && exec rake spec"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'helpful_fields'
    gem.summary = "Many helpful field helpers e.g. check_box_with_label"
    gem.email = "michael@grosser.it"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
    gem.license = 'MIT'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
