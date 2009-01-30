=begin
  This file contains generic tasks for Tosca
=end

namespace :tosca do

  desc "Generate a default Database with default values."
  task :generate => [ 'db:create', 'db:migrate', 'db:fixtures:load']

  desc "Configure a new Tosca instance"
  task :install do
  end

desc "Configure a new Tosca instance"
  # TODO : split this file in more methods
  task :install do
    require 'fileutils'
    root = RAILS_ROOT
    FileUtils.mkdir_p "#{root}/log"

    # dependencies
    puts "You need to install those dependencies : "
    puts "sudo apt-get install ruby1.8 ri ri1.8 rdoc rake irb rubygems mongrel"
    puts "Is those dependencies here ? [Y/n]"
    exit 0 if STDIN.gets.chomp! == 'n'

    # Database #
    puts "Use default access to mysql [Y/n] ?"
    if STDIN.gets.chomp! != 'n'
      FileUtils.cp "#{root}/config/database.yml.sample",
                   "#{root}/config/database.yml"
    end
    FileUtils.cp "#{root}/config/config.rb.sample", "#{root}/config/config.rb"
    # needed for dev mode, when stylesheets are not cached in single file.
    FileUtils.ln_s '../../public/images/', 'public/stylesheets/images', :force => true

    Rake::Task['l10n:mo'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end


  namespace :dist do
    desc "Generate small tarball for public distribution"
  	task :minimal do
      sh "git archive --format=tar --prefix=tosca/ HEAD > tosca.tar"
      sh "bzip2 -f tosca.tar"
    end
    desc "Generate small tarball for public distribution"
  	task :all do
      sh "git archive --format=tar --prefix=tosca/ HEAD > tosca-full.tar"
	  sh "cd vendor/extensions; git archive --format=tar --prefix=tosca/vendor/extensions/ 721d3ed0cdf1a0c5fdae03c63fdbe06b1199f858 > ../../extensions.tar; cd -"
	  sh "tar -A extensions.tar -f tosca-full.tar; rm -f extensions.tar"
      sh "bzip2 -f tosca-full.tar"
    end
  end

end
