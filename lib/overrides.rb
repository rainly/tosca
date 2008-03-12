#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################


class Array
   #   [ 4, 5 ].sum
   #      9
   def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
   end
end

class String
  # this convenience method search an url in a string and add the "http://" needed
  # RFC sur les URLS : link:"http://rfc.net/rfc1738.html"
  # Made from this regexp : link:"http://www.editeurjavascript.com/scripts/scripts_formulaires_3_250.php"
  #
  # It works with :
  #  "www.google.com"
  #  "http://www.google.com"
  #  "toto tutu djdjdjd google.com" >
  #  "toto tutu djdjdjd http://truc.machin.com/touo/sdqsd?tutu=1&machin google.com/toto/ddk?tr=1&machin"
  #TODO: A améliorer
  def urlize
    (self.gsub(/(\s+|^)[a-zA-Z]([\w-]{0,61}\w)?\.[a-zA-Z]([\w-]{0,61}\w)?(\.[a-zA-Z]([\w-]{0,61}\w)?)?/) { |s| " http://" + s.strip }).strip
  end

  # Small convenience method which replace each space by its unbreakable html
  # equivalent.
  #
  # Call it like this :
  #   "this is a test".unbreak
  #     this&nbsp;is&nbsp;a&nbsp;test"
  def unbreak
    self.gsub(' ', '&nbsp;')
  end

end

# View Optimization : no '\n'
ActionView::Base.erb_trim_mode = '>'

# TODO : find a lib or a way to compute holidays
# of other countries. It's only France, for now.
# You can override Fixed & Variable Holidays in lib/config.rb
class Date
  # There's no year since comparison on FixedHolidays can be done
  # only with day and month.
  # They are stored in a hash in order to have a faster "include?"
  FixedHolidays = {
    Date.new(0, 1, 1) => true, # 1st january
    Date.new(0, 5, 1) => true, # 1st may
    Date.new(0, 5, 8) => true, # 8th may
    Date.new(0, 7, 17) => true, #14th july
    Date.new(0, 8, 15) => true, #15th august
    Date.new(0, 11, 1) => true, # 1st november
    Date.new(0, 11, 11) => true, #11th november
    Date.new(0, 12, 25) => true #25th december
  }

  # Dynamic cache for variable holidays, for performance reason
  @@variable_holidays = Hash.new
  def self.VariableHolidays(year)
    cache = @@variable_holidays[year]
    return cache unless cache.nil?

    # Easter computing is from
    # http://fr.wikipedia.org/wiki/Calcul_de_la_date_de_P%C3%A2ques#Algorithme_de_Thomas_O.E2.80.99Beirne
    # It's valid only between 1900 and 2099.
    # There is no need to name correctly those vars, since
    # this algorithm is clearly not human readable.
    n = year - 1900
    a = n % 19
    b = (a * 7 +1) / 19
    c = ((11 * a) - b + 4) % 29
    d = n / 4
    e = (n - c + d + 31) % 7
    p = 25 - c - e
    easter_day = Date.new(year, 3, 31) + p
    easter_monday = easter_day + 1
    ascension_day = easter_day + 40
    # 2 variable holidays in france
    @@variable_holidays[year] = {easter_monday => true, ascension_day => true}
  end

  # Tell if the current date is worked or not.
  # It's based on FixedHolidays & VariableHolidays(year) mechanism
  # See lib/overrides.rb for more info on how to hook'em.
  def working?
    return false if self.cwday > 5 # 6,7 => Week End
    return false if FixedHolidays.include? Date.new(0, self.month, self.day)
    return false if Date.VariableHolidays(self.year).include? self
    true
  end

end


class Time
  ##
  # Compute the difference between <tt>start_date</tt> and
  # <tt>end_date</tt> during Working Days, as define in Date::working?
  # <tt>opens_at</tt> and <tt>closes_at</tt> are the hours when the service
  # is open.
  # The result is expressed in this unit. So if you call :
  # <pre>
  #   Time.working_diff(2.days.ago, 1.day.ago, 10, 18)
  # </pre>
  # It will return 8.hours, and not 24.hours
  # It will return 0 if start_date > end_date or closes_at > opens_at
  def self.working_diff(start_date, end_date, opens_at, closes_at)
    ### check ###
    return 0 if opens_at > closes_at || start_date > end_date
    return 0 if opens_at < 0 || opens_at > 24
    return 0 if closes_at < 0 || closes_at > 24

    ### init ###
    one_working_day = (closes_at - opens_at) * 1.hour
    start_day = Date.new(start_date.year, start_date.month, start_date.day)
    end_day = Date.new(end_date.year, end_date.month, end_date.day)
    period = end_day - start_day - 1

    # It will return 0 if end_time is before start_time.
    @@diff_day ||= Proc.new do |start_time, end_time|
      result = end_time - start_time
      (result >= 0 ? result : 0)
    end

    ### compute ###
    result = 0
    # 1st day : end_date can be on the same day
    start_close_time = (closes_at == 24 ? start_date.end_of_day : start_date.change(:hour => closes_at))
    start_end_date = [ start_close_time, end_date ].min
    if start_day.working?
      result += @@diff_day.call(start_date, start_end_date)
    end
    # Period
    current_day = start_day
    period.round.times do
      result += one_working_day if current_day.working?
      current_day = current_day.next
    end
    # Last day
    if start_day != end_day && end_day.working?
      result += @@diff_day.call(end_date.change(:hour => opens_at), end_date)
    end
    result
  end

  # FONCTION vers lib/lstm.rb:time_in_french_words
  def distance_of_time_in_french_words(distance_in_seconds, contrat)
    dayly_time = contrat.heure_fermeture - contrat.heure_ouverture # in hours
    Time.in_words(distance_in_seconds, dayly_time)
  end

  # Calcule en JO (jours ouvrés) le temps écoulé
  def distance_of_time_in_working_days(distance_in_seconds, period_in_hour)
    distance_in_minutes = ((distance_in_seconds.abs)/60.0)
    jo = period_in_hour * 60.0
    distance_in_minutes.to_f / jo.to_f
  end


  # Integers are interpreted as seconds. So,
  # <tt>Time.in_words(50)</tt> returns "less than a minute".
  #
  # Set <tt>include_seconds</tt> to true if you want more detailed approximations if distance < 1 minute
  # Le deuxième paramètre peut être un nombre ou un booléen.
  #   Si c'est un nombre, ca indique le nombre d'heures dans une journée ouvrée
  #   Si c'est un booleén à true, ça indique que les journées font 24 heures et sont ouvrées
  #   Si il n'y a rien, les journées font 24 heures et ne sont pas ouvrées
  #
  # TODO : There is no test for this important component
  # Call it like this :
  # Time.in_words(15.hours, 5)
  # Time.in_words(13.hours, 5)
  # Time.in_words(10.hours, 5)
  # Time.in_words(2.days + 10.hours)
  # Time.in_words(0.5.days, true)
  def self.in_words(distance_in_seconds, dayly_time = 24)
    return '-' unless distance_in_seconds.is_a? Numeric and distance_in_seconds > 0
    return '-' unless dayly_time == true or (dayly_time > 0 and dayly_time < 25)
    opened = (dayly_time != 24 ? true : false)
    dayly_time, opened = 24, true if (dayly_time == true)

    distance = ((distance_in_seconds.abs)/60).round # in minutes
    day = dayly_time * 60 # one day, in minutes
    mo = 30 * day # one month, in minutes
    half_day_inf = (day/2) - 60
    half_day_sup = (day/2) + 60

    case distance # in minutes
    when 0..1
      _('less than a minute')
    when 1..45
      _('%d minutes') % distance
    when 45..half_day_inf, half_day_sup..day-60
      value = (distance.to_f / 60.0).round
      n_('%d hour', '%d hours', value) % value
    when half_day_inf..half_day_sup
      (opened ? _('1 half a working day') : _('1 half day'))
    when (day-60)..(day+60), (day*2-60)..(day*2+60),
         (day*3-60)..(day*3), (3*day)..mo
      val = (distance / day).round
      (opened ? n_('%d working day', '%d working days', val) :
                n_('%d day', '%d days', val)) % val
    when day..(3*day)
      days = (distance / day).floor
      hours = ((distance % 1.day)/60).round
      out = ((opened ? n_('%d working day', '%d working days', days) :
                       n_('%d day', '%d days', days)) % days)
      out << ' and ' << n_('%d hour', '%d hours', hours) % hours
      out
    else
      val = (distance / mo).round
      (opened ? n_('%d working month', '%d working months', val) :
                n_('%d month', '%d months', val)) % val
    end
  end

end

#############################################
# Needed coz of f***ing Debian              #
# We had to override this in order to fix   #
# an issue when gettext_localize call this  #
# interface                                 #
#############################################
class CGI
  module QueryExtension
    # Get the value for the parameter with a given key.
    #
    # If the parameter has multiple values, only the first will be
    # retrieved; use #params() to get the array of values.
    def [](key)
      params = @params[key]
      return '' unless params
      value = params[0]
      if @multipart
        if value
          return value
        elsif defined? StringIO
          StringIO.new("")
        else
          Tempfile.new("CGI")
        end
      else
        str = if value then value.dup else "" end
        str.extend(Value)
        str.set_params(params)
        str
      end
    end
  end
end


# This module is overloaded in order to display link_to lazily
# and efficiently. It display links <b>only</b> if the user
# has the right access to the ressource.
module ActionView::Helpers::UrlHelper
  # this link_to is a specialised one which only returns a link
  # if the user is connected and has the right access to the ressource
  # requested. See public_link_to for everyone links.
  def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    action = nil
    return nil unless options
    if html_options
      case html_options[:method]
        when :delete
        action = 'destroy'
        when :put
        action = 'update'
      end
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    # With the hack on the named route, we have a nil url if authenticated user
    # does not have access to the page. See the hack to define_url_helper
    # for more information

    user = session[:user]
    unless url.blank? or user.nil?
      if options.is_a?(Hash) and options.has_key? :action
        required_perm = '%s/%s' % [ options[:controller] || controller.controller_name,
                                    options[:action] ]
        return nil unless user.authorized?(required_perm)
      end
      if action and options.is_a? String
        # No '/' here, since we have it with the grepped part of the url.
        # [/[^\/]*\/\d+$/] => a string without a '/', a '/' and an id
        required_perm = '%s/%s' % [ url.scan(/([^\/]*)\/\d+/).first.first, action ]
        return nil unless user.authorized?(required_perm)
      end
      "<a href=\"#{url}\"#{tag_options}>#{name || url}</a>"
    else
      nil
    end
  end

  # this link_to display a link whatever happens, to all the internet world
  def public_link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    "<a href=\"#{url}\"#{tag_options}>#{name || url}</a>"
  end

  def authorize_url?(options)
    perm = "#{options[:controller]}/#{options[:action]}"

    result = LoginSystem::public_user.authorized?(perm)

    unless result
      if session.data.has_key? :user and session[:user].authorized?(perm)
        return true
      end
    end
    result
  end
end



# This module is overloaded, mainly for performance
# and the scope stuff.
module ActiveRecord
  class Base
    # This <b>must</b> be called after each call of set_scope,
    # specified in each concerned model. See ApplicationController
    # and its around_filter for more information
    def self.remove_scope
      self.scoped_methods.pop
    end


    # By convention, all tosca records have or implements a 'name' method,
    # used mainly for displaying and selecting them. It's also their default
    # to_s implementation, even if it's free to specialize it when needed.
    def to_s
      name
    end

    # It's the more common select applied, mainly for select box.
    # By default, it returns an array of [ name, id ].
    # If 'collect' is false, it will return an array of ActiveRecord
    # Call it like this :
    #  User.find_select(:include => [:role]) =>
    #  Recipient.find_select(:include => [:client], false)
    # /!\ Beware of applying the collect!{|c| [ c.name, c.id ] } before
    #     displaying it /!\
    def self.find_select(options = {}, collect = true)
      options[:select] = 'id, name'
      options[:order] ||= "#{self.table_name}.name ASC"
      res = self.find(:all, options)
      res.collect!{ |o| [o.name, o.id]} if collect
      res
    end

    # Same as #find_select, but returns only active objects
    def self.find_active4select(options = {})
      options[:select] = 'id, name'
      table_name = self.table_name
      if options.has_key? :conditions
        options[:conditions] += " AND #{table_name}.inactive = 0"
      else
        options[:conditions] = "#{table_name}.inactive = 0"
      end
      options[:order] ||= "#{table_name}.name ASC"
      self.find(:all, options).collect{ |o| [o.name, o.id]}
    end


    # this special method allows to gain a lot of performance
    # since it doesn't require to load Time or strftime in order
    # to display the date
    def updated_on_formatted
      d = @attributes['updated_on']
      (d ? "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}" : '-')
    end

    # this special method allows to gain a lot of performance
    # since it doesn't require to load Time or strftime in order
    # to display the date
    def created_on_formatted
      d = @attributes['created_on']
      (d ? "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} à #{d[11,2]}h#{d[14,2]}" : '-')
    end
  end
end


#To have homemade message-id in mails
module TMail
  class Mail
    def ready_to_send
      delete_no_send_fields
      #The only thing to comment.
      #add_message_id
      add_date
    end
  end
end
