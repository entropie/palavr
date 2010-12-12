#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class SearchController < PalavrController
  map "/search"
  set_layout_except("layout" => [:_all])
  
  # helper :auth
  # before(:me){
  #   login_required
  # }

  def get_ordered
  end

  
  
  def self.search_phreads(squery)
    like = proc{|title| "(#{title} LIKE BINARY '%#{squery}%')"}
    query="SELECT "+
      "phread.*, user.id as uid, user.email as email, "+
      "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
      "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+
      "FROM phread "+
      "LEFT JOIN cat ON phread.category_id = cat.id "+
      "LEFT JOIN user ON phread.op_id = user.id "+
      "WHERE " + like.call("phread.title") + " OR " + like.call("phread.body") +  " "+
      "ORDER BY count DESC  LIMIT 10 "
    ret = Palavr::DB[query].to_a.map{|a| a.extend(Palavr::E)}
  end

  def self.search_user(squery)
    like = proc{|title| "(#{title} LIKE BINARY '%#{squery}%')"}
    query = "SELECT "+
      "user.id as uid, user.email as email "+
      "FROM user "+
      "WHERE " + like.call("user.name") + " OR " + like.call("user.nick") +  " "+
      "ORDER BY user.id"
    ret = Palavr::DB[query].to_a.map{|a| a.extend(Palavr::E)}
    ret
  end
  
  def self.search_from_user(squery)
    like = proc{|title| "(#{title} LIKE BINARY '%#{squery}%')"}
    query = "SELECT "+
      "phread.*, user.id as uid, user.email as email, "+
      "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
      "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
      "FROM phread "+
      "LEFT JOIN user ON phread.op_id = user.id "+          
      "INNER JOIN phreads_users "+
      "ON phreads_users.phread_id = phread.id "+
      "WHERE " + like.call("user.name") + " OR " + like.call("user.nick") +  " "+
      "GROUP by phread.id " +
      "ORDER BY count DESC  LIMIT 10"
    ret = Palavr::DB[query].to_a.map{|a| a.extend(Palavr::E)}
    ret
  end

  def self.search_tags(squery)
    like = proc{|title| "(#{title} LIKE BINARY '%#{squery}%')"}
    query = "SELECT "+
      "phread.*, user.id as uid, user.email as email, tag.tag as tag, "+
      "(SELECT COUNT(*) FROM phreads_users WHERE phread.id = phreads_users.phread_id) as count, "+
      "(SELECT COUNT(*) FROM phreads_phreads WHERE phread.id = phreads_phreads.parent_id) as countchilds "+              
      "FROM phread "+
      "LEFT JOIN user ON phread.op_id = user.id "+
      "LEFT JOIN phreads_tags ON phreads_tags.phread_id = phread.id "+
      "LEFT JOIN tag ON phreads_tags.tag_id = tag.id "+       
      "INNER JOIN phreads_users "+
      "ON phreads_users.phread_id = phread.id "+
      "WHERE " + like.call("tag") + " " +
      "GROUP by count, phread.id " +
      "ORDER BY count DESC  LIMIT 10"
    ret = Palavr::DB[query].to_a.map{|a| a.extend(Palavr::E)}
    ret
  end
  
  def self.search(params)
    result = {}
    query = params["s"].to_s.strip
    result[:phreads]  = self.search_phreads(query)
    result[:user]     = self.search_user(query)
    result[:fromuser] = self.search_from_user(query)
    result[:fromtags] = self.search_tags(query)
    result
  end
  
  def index
  end

  def _all
    @query = request.params["s"].to_s.strip
    @result = SearchController.search(request.params)
  end

end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
