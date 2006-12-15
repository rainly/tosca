#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
Date::MONTHS = { 'Janvier' => 1, 'F�vrier' => 2, 'Mars' => 3, 'Avril' => 4, 'Mai' => 5, 'Juin' => 6, 'Juillet' => 7, 'Ao�t' => 8, 'Septembre'=> 9, 'Octobre' =>10, 'Novembre' =>11, 'D�cembre' =>12 }
Date::DAYS = { 'Lundi' => 0, 'Mardi' => 1, 'Mercredi' => 2, 'Jeudi'=> 3, 'Vendredi' => 4, 'Samedi' => 5, 'Dimanche' => 6 }
Date::ABBR_MONTHS = { 'jan' => 1, 'f�v' => 2, 'mar' => 3, 'avr' => 4, 'mai' => 5, 'juin' => 6, 'juil' => 7, 'ao�' => 8, 'sep' => 9, 'oct' =>10, 'nov' =>11, 'd�c' =>12 }
Date::ABBR_DAYS = { 'lun' => 0, 'mar' => 1, 'mer' => 2, 'jeu' => 3, 'ven' => 4, 'sam' => 5, 'dim' => 6 }
Date::MONTHNAMES = [nil] + %w(Janvier F�vrier Mars Avril Mai Juin Juillet Ao�t Septembre Octobre Novembre D�cembre )
Date::DAYNAMES = %w(Lundi Mardi Mercredi Jeudi Vendredi Samedi Dimanche )
Date::ABBR_MONTHNAMES = [nil] + %w(jan f�v mar avr mai juin juil ao� sep oct nov d�c)
Date::ABBR_DAYNAMES = %w(lun mar mer jeu ven sam dim)


Date::ABBR_MONTHS_LSTM = { 0 => 'jan', 1 => 'f�v', 2 => 'mar', 3 => 'avr', 4 => 'mai', 5 => 'juin', 6 => 'juil', 7 => 'ao�', 8 => 'sep', 9 => 'oct', 10 => 'nov', 11 => 'd�c' }

class Time
  alias :strftime_nolocale :strftime
  
  def strftime(format)
    format = format.dup
    format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
    format.gsub!(/%A/, Date::DAYNAMES[self.wday])
    format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
    format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
    self.strftime_nolocale(format)
  end
end



module ActiveRecord
  class Base

    def updated_on_formatted
      d = @attributes['updated_on']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} � #{d[11,2]}h#{d[14,2]}"
    end

    def created_on_formatted
      d = @attributes['created_on']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} � #{d[11,2]}h#{d[14,2]}"
    end
  end
end

module ActionController
 def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
   if html_options
     html_options = html_options.stringify_keys
     convert_options_to_javascript!(html_options)
     tag_options = tag_options(html_options)
   else
     tag_options = nil
   end
   url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
   "<a href=\"#{url}\"#{tag_options}>Yeah ! #{name || url}</a>"
 end

end
