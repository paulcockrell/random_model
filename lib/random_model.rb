require 'active_support/core_ext/module/delegation'
require 'active_record/relation'

module Randumb
  # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/query_methods.rb
  module ActiveRecord
    module Relation

      def random
        relation = clone

        if connection.adapter_name =~ /sqlite/i || connection.adapter_name =~ /postgres/i
          rand_syntax = "(select floor(RANDOM() * (select max(id) from #{relation.table_name})))"
        elsif connection.adapter_name =~ /mysql/i
          rand_syntax = "(select floor(RAND() * (select max(id) from #{relation.table_name})))"
        else
          raise Exception, "ActiveRecord adapter: '#{connection.adapter_name}' not supported by randumb.  Send a pull request or open a ticket: https://github.com/spilliton/randumb"
        end

        the_scope = relation.where("id = "+rand_syntax)
      end

    end # Relation

    module Base
      # Class method
      def random
        relation.random
      end
    end

  end # ActiveRecord
end # Randumb

# Mix it in
class ActiveRecord::Relation
  include Randumb::ActiveRecord::Relation
end

class ActiveRecord::Base
  extend Randumb::ActiveRecord::Base
end
