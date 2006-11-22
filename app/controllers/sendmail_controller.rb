#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class SendmailController < ApplicationController

# ce controller est "inutile"
# il permet juste de tester l'envoi de mail depuis sendmail/index
# ou l'on peut choisir un destinataire.
# la page sendmail/test recupere des parametre pour finalement
# appeler le model "notifier" (lui, est utile ;)

# il suffit d'inclure les lignes dans un controller pour l'envoyer :
#   @dest = ...
#   mail = Notifier::create_mailto(@dest)
#   Notifier::deliver(mail)
# on cr�era id�alement une fonction "mail" appel�e � l'occasion

 def index
  @identifiants = Identifiant.find_all
 end

 def test
  if ( @params['dest_id'] != nil )

    if ( Identifiant.find(@params['dest_id'])[0] != nil )
      # cas ou recu depuis form sendmail/index
      @dest = Identifiant.find(@params['dest_id'])[0]
    else
      # cas ou 
      @dest = Identifiant.find(@params['dest_id'])
    end
 
    # mail simple :
      #Notifier::deliver_mailto #(identifiant)

    # ou avec piece jointe :
      mail = Notifier::create_mailto(@dest)
      Notifier::deliver(mail)

    flash[:notice]  = "Message envoy� � " + @dest.login
  else
    flash[:notice]  = "Pas de destinataire s�lectionn�"
  end
 end #test

end
