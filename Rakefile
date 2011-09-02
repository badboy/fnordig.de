#!/usr/bin/env ruby
# encoding: utf-8

PRODUCTION = {
  :url    => "http://fnordig.de",
  :log    => "/home/badboy/git/fnordig.de/deploy.log",
  :dest   => "/var/www/sites/fnordig.de",
  :source => "/home/badboy/git/fnordig.de/_site",
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
        (
          echo -n "Production deployment: "; date;
          echo "Resetting git & fetching from origin..."
          git reset --hard HEAD &&
          git pull origin master &&
          echo "generating page..."
          rake generate &&
          echo "copy to webserver directory..."
          cp -ar #{PRODUCTION[:source]}/* #{PRODUCTION[:dest]}
          echo "deployment done"
        ) | tee #{PRODUCTION[:log]}
      EOF
    }
  end
end