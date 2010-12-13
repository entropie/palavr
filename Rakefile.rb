#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'rubygems'
require '../ramaze/lib/ramaze'
require "lib/palavr"

include Palavr::Database::Tables

task :start do
  sh "cd app && ruby start.rb"
end


# by manveru
task :todo do
  files = Hash.new{|h,k| h[k] = []}
  Dir.glob('{lib,app}/**/*.rb') do |file|
    lastline = todo = comment = long_comment = false
    
    File.readlines(file).each_with_index do |line, lineno|
      lineno += 1
      comment = line =~ /^\s*?#.*?$/
      long_comment = line =~ /^=begin/
      long_comment = line =~ /^=end/
      todo = true if line =~ /TODO|FIXME|THINK/ and (long_comment or comment)
      todo = false if line.gsub('#', '').strip.empty?
      todo = false unless comment or long_comment
      if todo
        l = line.strip.gsub(/^#\s*/, '')
        str = ''
        str << l
        lastline = lineno
        files[file] << ("#{lineno}\t" << str)
      end
    end
  end
  File.open('FIXMES', 'w+'){|f|
    files.each_pair{|fk, fv|
      f.puts(fk)
      fv.each do |fline|
        f.puts "  #{fline}"
      end
      f.puts
    }
  }
end

task :todofile => [:todo] do
  # todos = User.first.todo.select{|t| t.category == "DEVEL"}
  str = "# File is Autogenerated at #{Time.now.to_s(false)}\n\n"
  # todos.each do |t|
  #   mark = t.done == 1 ? "-" : '*'
  #   str << "#{mark} [#{t.created_at.to_s(false)}]\n  #{t.body}\n"
  # end
  File.open("TODO", File::WRONLY|File::TRUNC|File::CREAT){|f| f.write(str)}
end


task :deploy => [:umigrate, :migrate, :todo, :development, :todofile] do
end

task :live => [:umigrate, :migrate, :todo, :production, :mk_live, :import] do
end

task :development do
  ruby "script/db_migration_devel.rb"
end

task :production do
  ruby "script/db_production.rb"
end

task :migrate do
  Palavr::Database.migrate
end

task :umigrate do
  Palavr::Database.migrate(:down)
end


module E
  def method_missing(m, *a, &b)
    if self[m.to_sym]
      self[m.to_sym]
    else
      super
    end
  end
end

task :bu do
  pp Phread[65].get_ordered.to_a
  puts
  pp Phread[65].phreads
end

task :ba do
  p User[2].authorized?
end


def mk_phread_to_yaml(phread, title = nil, last = nil)
  yamlp = phread.values.merge(:pid => last.id).to_yaml
  title ||= phread.title.to_a.select{|c| c =~ /[a-zA-Z]/}.join.downcase

  data_path = "livedata/phreads/#{title}"
  FileUtils.mkdir_p(data_path)

  file = File.join(data_path, "phread_%s_%i.yaml" % [title, phread.id])
  File.open(file, "w+") do |fp|
    fp.write(yamlp)
  end
  File.open( File.join(data_path, "user.yaml"), 'w+' ) do |fp|
    fp.write(phread.op.to_yaml)
  end
  phread.phreads.each do |pr|
    mk_phread_to_yaml(pr, title, phread)
  end
end


def mk_from_yaml(yphread, user, last = nil)
    nh = {
      :title => yphread[:title],
      :body  => yphread[:body]
    }

  phr = Phread.create(nh)
  phr.op = user
  Category[yphread[:category_id]].add_phread(phr) unless last
  last.add_phread(phr) if last
  phr.save
end

def mk_yaml_to_phread(files, last = nil, user = nil)
  ufile = files.select{|f| f =~ /user/}.shift
  user = YAML::load(File.readlines(ufile).join)
  nuser = User.find_or_create(:email => user.email, :nick => user.nick, :passwd => user.passwd)

  last = nil
  
  files.each do |file|
    next if file =~ /user/
    yphread = YAML::load(File.readlines(file).join)
    last = mk_from_yaml(yphread, nuser, last)
  end

end

def phread_yaml_import
  data_path = "livedata/phreads"
  Dir.chdir(data_path) do
    contents = Dir.glob('**/*.yaml').to_a.sort
    last = nil
    mk_yaml_to_phread(contents)
  end
end


require "yaml"

task :import do
  phread_yaml_import
end

task :export do
  ids = [68]
  ids.each do |id|
    pr = Phread[id]
    mk_phread_to_yaml(pr)
  end
end


task :foo do

  phread_ids = Category.join(:phread, :category_id => :id).
    filter(:category_id => 2).select(:phread__id)


  
  # a = Phread.filter(:phread_id => phread_ids).
  #   join(:phreads_users, :phreads_users__phread_id => :id).
  #   group(:phreads_users__phread_id).reverse.
  #   join(:user, :phread__op_id => :user__id).
  #   select(:email, :readonly, :body, :category_id, :mod_user_id, :user_id,
  #          :created_at, :title, :phread__id).
  #   order(:phreads_users__phread_id, :phread__id).reverse

  a="SELECT "+
    "phread.*, user.id as uid, user.email as email, "+
    "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
    "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+    
    "FROM phread "+
    "LEFT JOIN cat ON phread.category_id = cat.id "+
    "LEFT JOIN user ON phread.op_id = user.id "+
    "WHERE cat.id = 1 "+
    "ORDER BY count DESC "
  
  
  

  
  Palavr::DB[a].paginate(1,1).map{|r| r.extend(E)}.each do |i|
    p i
    p i[:count]
    puts
    puts
  end

  exit
  #  pp a.to_a

  pp a.paginate(1, 5).to_a
  pp a.paginate(2, 5).to_a

end


task :pptables do
  Palavr::Database.definitions.each do |tbl|
    puts
    puts tbl.name
    puts
    tbl.print
  end
end

task :mk_live do
  ruby "script/mk_livedata.rb"
end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
