#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################

# Meta data ici :
# ajouter par Lstm
module Metadata

  # application
  NOM_COURT_APPLICATION = "LSTM"
  NOM_LONG_APPLICATION = "Linagora Software Tracker Manager"
  COPYRIGHT_APPLICATION = "Copyright Linagora SA 2006 - Tous droits r�serv�s."

  # service
  NOM_COURT_SERVICE = "OSSA"
  NOM_LONG_SERVICE = "Open Source Software Assurance"
  NOM_ENTREPRISE = "Linagora"

  # contacts
  PREFIXE_TELEPHONE = "08000"
  CODE_TELEPHONE = "54689"
  TEXTE_TELEPHONE = "LINUX"
  SITE_INTERNET = "08000LINUX.com"

  # logo
  LOGO_08000LINUX = '<img alt="08000 LINUX" src="/images/logo_08000.gif">'

  # message d'erreur
  DEMANDE_NOSTATUS = 'Cette demande n\'a pas de statut, veuillez contacter la cellule'
end



def rmtree(directory)
  Dir.foreach(directory) do |entry|
    next if entry =~ /^\.\.?$/     # Ignore . and .. as usual
    path = directory + "/" + entry
    if FileTest.directory?(path)
      rmtree(path)
    else
      File.delete(path)
    end
  end

  Dir.delete(directory)
end


def avg(data)
  return 0 unless data.is_a? Array
  data.inject(0){|n, value| n + value} / data.size.to_f
end
