#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Palavr

  module Database

    LoadedDefintions = []

    module Table
      def self.jobmodule?
        true
        #instance_variable_get("@simple_table")[1..-2]
      end
    end

    module Tables

      def self.Table(*a)
        ret = ::Sequel::Model(a.first)
        ret.extend(Palavr::Database::Table)
        #ret.extend(TableName)
        #ret.name = a.first
        ret
      end

      def self.tables
        self.constants.map{|c| self.const_get(c)}
      end

      def self.job_modules(name = nil)
        ret = tables.select{|t|
          t.table_name.to_s[0..3] == "jmod"
        }
        if name
          name = name.to_s
          ret.reject!{|t| name != t.table_name.to_s[5..-1] }
          return ret.first
        end
        ret
      end

    end

    def self.tables
      Tables.tables
    end
    
    def self.migrate(w = :up, defs = nil)
      (defs || definitions).each do |defi|
        name = defi.instance_variable_get("@simple_table")[1..-2]
        log "migrating: #{w}  %s" % name
        begin
          if w == :down
            DB.drop_table name
          elsif w == :up
            defi::Shema.call
          else
          end
        rescue
          p $!
        end
      end
    end

    def self.database(db = :sequel)
      self.class.const_get(db.to_s.downcase.capitalize)
    end

    def self.definitions
      load_definitions
      consts = Database::Tables.constants.map{ |const|
        const = Database::Tables.const_get(const)
      }
      # consts.map do |constcls|
      #   constcls.class_eval {
      #     include DBHelper.select_for(constcls)
      #   }
      # end
    end

    # TODO: Migration
    def self.load_definitions(force = false, dir = "")
      dira = "#{Palavr::Source.to_s}/app/model/#{dir}"
      LoadedDefintions.clear if force
      #return nil unless LoadedDefintions.empty?
      Dir["#{dira}*.rb"].sort.each do |l|
        log "model load: #{File.basename(l)}"
        LoadedDefintions << l
        require l
      end
    end

    def self.model(db = :sequel)
      self.database.model
    end

    class Adapter
      def model
        @model ||= :sequel
      end
    end

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
