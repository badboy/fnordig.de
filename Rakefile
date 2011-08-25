#!/usr/bin/env ruby
# encoding: utf-8

PRODUCTION = {
  :url    => "http://fnordig.de",
  :dest   => "/var/www/sites/fnordig.de.test",
  :source => "/home/badboy/git/fnordig.de/_site"
}

desc 'Generate page using jekyll'
task :generate do
  sh "jekyll"
end

desc 'Serve the page on http://localhost:4000'
task :serve do
  sh "jekyll --serve --auto"
end

namespace :deploy do
  desc 'Deploy the page on the production machine (executed on production)'
  task :production do
    verbose(true) {
      sh <<-EOF
        git reset --hard HEAD &&
        git pull origin master &&
        rake generate
        cp -ar #{PRODUCTION[:source]}/* #{PRODUCTION[:dest]}
      EOF
    }
  end
end
