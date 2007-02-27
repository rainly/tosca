#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# UPLOAD > file_column.rb:l.596
#  :root_path => File.join(RAILS_ROOT, "files"),

# ROUTES > routes.rb
#  routing files to prevent download from public access

# MOVE FILES TO PROTECT > script shell
#  mv public/folders_to_protect files/

# DOCUMENTATION
#  http://wiki.rubyonrails.com/rails/pages/HowtoSendFiles
#  http://robertrevans.com/article/files-outside-public-directory
#  http://svn.techno-weenie.net/projects/plugins/acts_as_attachment/

class FilesController < ApplicationController

  def download
    file_type = params[:file_type]
    map = {:piecejointe => 'file', 
           :contribution => 'patch',
           :document => 'fichier',
           :binaire => 'archive', 
           :photo => 'image'
    }
    # TODO : recuperer le model sans hash
    model = { :piecejointe => Piecejointe, 
              :contribution => Contribution,
              :document => Document,
              :binaire => Binaire, 
              :photo => nil
    }
    root_path = "#{RAILS_ROOT}/files"
    root = [ root_path, file_type, map[file_type.intern] ] * '/'
    fullpath = [ root, params[:id], params[:filename] ] * '/'
    # rescue unless item not found
    send_file fullpath if model[file_type.intern].find(params[:id])

  rescue 
    flash[:warn] = 'Ce fichier n\'existe pas.'
    redirect_to_home 
  end

end
