#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


def log(str)
  puts "> %s" % str
end


module Palavr

  Source = File.dirname(File.dirname(File.expand_path(__FILE__)))

  $: << File.join(Source, "lib/palavr")
  $: << File.join(Source, "../innate/lib/")

  Version = {
    :major => 0,
    :minor => 7,
    :suffix => "alpha"
  }
  
  # load stdlib exts
  Dir["#{Source}/lib/ruby/*.rb"].each {|file| log "loading ruby base class-extension: #{file}"; require file  }

  require "rubygems"
  require "sequel"

  gem 'haml'

  require 'sass'  
  
  #require "contrib"
  require "database"
  require "logger"
  require "pp"

  Opts = {}
  Opts[:public_dir] = pd="public"
  Opts[:data_dir]   = "#{pd}/data"
  Opts[:www_data_dir]   = "/data"
  
  if `hostname`.strip == "t2062.greatnet.de"
    DB = Sequel.mysql('palavr_devel',
                      :user => 'palavr',
                      :password => 'palavr',
                      :logger => Logger.new( STDOUT ),
                      :host => "localhost")

  elsif `hostname`.strip == "io"
    DB = Sequel.mysql('palavr_devel',
                      :user => 'palavr',
                      :password => File.readlines("/home/entropy/mysql.pw").join.strip,
                      :logger => Logger.new( STDOUT ),
                      :host => "localhost")
  else
    
    
    DB = Sequel.mysql('palavr_devel',
                      :user => 'root',
                      :password => '',
                      :logger => Logger.new( STDOUT ),
                      :host => "localhost",
                      :socket => "/var/run/mysqld/mysqld.sock")
  end
  def self.version
    str = "Palavr-%i.%i" % [Version[:major], Version[:minor]]
    str << "-#{Version[:suffix]}" if Version[:suffix]
  end

  
  module E

    def url
      Database::Tables::Phread[self[:id]].url
    end

    def title
      Database::Tables::Phread[self[:id]].title      
    end
    
    def liker
      Database::Tables::Phread[self[:id]].liker      
    end

    def html_body
      Database::Tables::Phread[self[:id]].html_body
    end
    def tags
      Database::Tables::Phread[self[:id]].tags
    end
    def phreads
      Database::Tables::Phread[self[:id]].phreads
    end
    
    def backlink
      ''
    end

    def category
      Database::Tables::Category[self[:category_id]] or parent.category
    end

    def parent_id
      3
    end
    
    def from
      Database::Tables::User[self[:op_id]]
    end
    
    def readonly?
      self["readonly?".to_sym]
    end
    
    def count
      self[:count]
    end
    
    def parent
      @parent = Database::Tables::Phread[Database::Tables::PhreadsPhreads.
                                         find(:phread_id => self[:id]).parent_id]
      @parent
    end

    def method_missing(m, *a, &b)
      if self.include?(m.to_sym)
        self[m.to_sym]
      else
        super
      end
    end
  end
  

end


Sequel.extension :pagination 

Palavr::Database.load_definitions




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
