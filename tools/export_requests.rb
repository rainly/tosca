#!/usr/bin/env script/runner

require 'fastercsv'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'find'
require 'fileutils'


if ARGV[0]
  client_id = ARGV[0]
  client_name = Client.find(client_id).name_clean
  puts "Would you like export informations for this client : #{client_name}? (y/ n)"
  reponse = $stdin.gets
  if reponse[0] == ?n
    puts "Cancel"
    exit
  end
else
  puts "Call it like this : "
  puts "$ #{$0} client_id"
  exit
end
puts "Export running..."

destdir = client_name

FileUtils.remove_dir("#{destdir}") if FileTest.exist?("#{destdir}")

Dir.mkdir("./#{destdir}")

requests = Client.find(client_id).demandes

requests_csv = []
comments_csv = []
attachments_csv = []

requests_csv << ["id", "beneficiaire", "resume", "severite", "logiciel", "created_on", "typedemande", "statut de sortie"]
comments_csv << ["id", "demande_id", "attachment_id", "corps", "created_on", "déposeur"]
attachments_csv << ["id", "name"]

requests.each do |d|
  name_logiciel = d.logiciel ? d.logiciel.name : ""
  requests_csv << [d.id, d.beneficiaire.user.name_clean, d.resume, d.severite.name, name_logiciel, d.created_on, d.typedemande.name, d.statut.name]

  d.commentaires.find(:all, :conditions => { :prive => false }).each do |c|
    name_user = c.user.client? ? c.user.name : "Linagora"
    comments_csv << [c.id, c.demande_id, c.attachment_id, c.corps, c.created_on, name_user]
  end

  d.attachments.each do |p|
    attachments_csv << [p.id, p.file_relative_path]
    Dir.mkdir("./#{destdir}/#{p.file_relative_path.split('/')[0]}")
    File.copy("files/attachment/file/#{p.file_relative_path}","#{destdir}/#{p.file_relative_path.split('/')[0]}")
  end
end


requests_csv_string = FasterCSV.generate do |csv|
  requests_csv.each do |d|
    csv << d
  end
end

comments_csv_string = FasterCSV.generate do |csv|
  comments_csv.each do |c|
    csv << c
  end
end

attachments_csv_string = FasterCSV.generate do |csv|
  attachments_csv.each do |p|
    csv << p
  end
end

File.open("#{destdir}/requests.csv","w") { |f|
  f.write(requests_csv_string)
}

File.open("#{destdir}/comments.csv","w") { |f|
  f.write(comments_csv_string)
}

File.open("#{destdir}/attachments.csv","w") { |f|
  f.write(attachments_csv_string)
}

result = "#{destdir}.zip"

FileUtils.remove_dir(result) if FileTest.exist?(result)

Zip::ZipFile.open( result, Zip::ZipFile::CREATE ){ |zipfile|
  Find.find( destdir ){ |find|
    # get relative path for the zip
    base_path = find[ destdir.length, find.length ]
    if base_path != ""
      if FileTest.directory?( find )
        zipfile.dir.mkdir( base_path )
      else
        zipfile.file.open( base_path, 'w' ){ |f|
          f.write( File.open(find, 'rb').read )
        }
      end
    end
  }
  zipfile.close
}

FileUtils.remove_dir("#{destdir}") if FileTest.exist?("#{destdir}")

puts "#{result} written"
