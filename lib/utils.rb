#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#For html2text
require 'cgi'

#Found here
#http://blog.yanime.org/articles/2005/10/10/html2text-function-in-ruby
#TODO : Make ordered list
def html2text(html)
  text = html.
    gsub(/(&nbsp;)+/im, ' ').squeeze(' ').strip.gsub("\n",'').gsub(/(&lsquo;)+/, "'").
    gsub(/<([^\s]+)[^>]*(src|href)=\s*(.?)([^>\s]*)\3[^>]*>\4<\/\1>/i, '\4')

  links = []
  linkregex = /<[^>]*(src|href)=\s*(.?)([^>\s]*)\2[^>]*>([^>]*)<[^>]*>/i
  while linkregex.match(text)
    links << $~[3]
    text.sub!(linkregex, "#{$~[4]}[#{links.size}]")
  end

  text = CGI.unescapeHTML(
    text.
      gsub(/<(script|style)[^>]*>.*<\/\1>/im, '').
      gsub(/<!--.*-->/m, '').
      gsub(/<hr(| *[^>]*)>/i, "----------------------------\n").
      gsub(/<li(| [^>]*)>/i, "\n * ").
      gsub(/<blockquote(| [^>]*)>/i, '> ').
      gsub(/<br(| *[^>]*)>/i, "\n").
      gsub(/<\/(h[\d]+|p)(| [^>]*)>/i, "\n\n").
      gsub(/<\/address(| [^>]*)>/i, "\n").
      gsub(/<\/pre(| [^>]*)>/i, "\n").
      gsub(/<\/?(b|strong)[^>]*>/i, "*").
      gsub(/<\/?(i|em)[^>]*>/i, "/").
      gsub(/<\/?u[^>]*>/i, "").
      gsub(/<[^>]*>/, '')
  )
  # OOo does not know the Unbreakable UTF-8 char, as of OOo 2.4.1, Hardy.
  text.gsub!(/\240/, ' ')

  for i in (0...links.size).to_a
    text = text + "\n  [#{i+1}] <#{CGI.unescapeHTML(links[i])}>" unless links[i].nil?
  end

  text
end

#Is this method useful ?
#rails I18n should do this
def _ordinalize(number)
  if Locale.get.language =~ /fr/
    case number
    when 1; "#{number}er"
    when 2; "#{number}nd"
    else    "#{number}eme"
    end
  else
    if (11..13).include?(number.to_i % 100)
      "#{number}th"
    else
      case number.to_i % 10
      when 1; "#{number}st"
      when 2; "#{number}nd"
      when 3; "#{number}rd"
      else    "#{number}th"
      end
    end
  end
end

module Utils
  # Used to help a newcomer
  def self.check_files(path, error_msg)
    if !File.exists? path
      $stderr.puts error_msg
      $stderr.puts "You have to specify one, you'll find an example in #{path}.sample."
      $stderr.puts "You have to copy it to #{path} and adapt it to your configuration."
      $stderr.puts "cp #{path}.sample #{path}"
      exit(-1)
    end
  end

end
