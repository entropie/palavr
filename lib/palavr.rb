#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


def log(str)
  puts "> %s" % str
end


moduleb Palavr

  Source = File.dirname(File.dirname(File.expand_path(__FILE__)))

  $: << File.join(Source, "lib/palavr")

  Version = {
    :major => 0,
    :minor => 3,
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
                      :password => "/home/entropy/mysql.pw".join.strip,
                      :logger => Logger.new( STDOUT ),
                      :host => "localhost")
  else
    
    
    DB = Sequel.mysql('palavr_devel',
                      :user => 'root',
                      :password => '',
                      :logger => Logger.new( STDOUT ),
                      :host => "localhost",
                      :socket => "/tmp/mysql.sock")
  end
  def self.version
    str = "Palavr-%i.%i" % [Version[:major], Version[:minor]]
    str << "-#{Version[:suffix]}" if Version[:suffix]
  end
  
end


Palavr::Database.load_definitions




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
