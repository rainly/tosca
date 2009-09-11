desc "Create mo-files for L10n"
task :makemo do
  require 'gettext_rails/tools'
  GetText.create_mofiles
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext_rails/tools'
  require 'tosca'
  files = Dir.glob("{app,lib,config}/**/*.{rb,erb}").concat(Dir.glob("vendor/extensions/**/*.{rb,erb}"))
  GetText::ActiveRecordParser.init(:use_classname => false, :db_mode => "development")  # default db_mode is development.
  GetText.update_pofiles("tosca", files, "tosca #{Tosca::App::Version}")
end
