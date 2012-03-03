require 'active_support/core_ext/module/delegation'
require 'active_record/relation'

module Randumb
  
    #  https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/query_methods.rb
  module ActiveRecord
    
    module Relation
      
      def random(max_items = nil, random_method = :random_ids_via_partial_fisher_yates)
        # return only the first record if method was called without parameters
        return_first_record = max_items.nil?
        max_items ||= 1

        # take out limit from relation to use later
    
        relation = clone
      
        # store these for including at the end
        original_includes = relation.includes_values
        original_selects = relation.select_values
        
        # clear these for our id only query
        relation.select_values = []
        relation.includes_values = []
      
        # does their original query but only for id fields
        id_only_relation = relation.select("#{table_name}.id")
        id_results = connection.select_all(id_only_relation.to_sql)
      
        ids = self.send(random_method, id_results, max_items)

        the_scope = klass.includes(original_includes)
        # specifying empty selects caused bug in rails 3.0.0/3.0.1
        the_scope = the_scope.select(original_selects) unless original_selects.empty? 

        records = the_scope.find_all_by_id(ids)
                
        if return_first_record
          records.first
        else
          records
        end
      end

      

      def random_ids_via_shuffle(results, max_items)
        results.shuffle[0,max_items].collect { |h| h['id'] }
      end

      def random_ids_via_hash(results, max_items)
        ids = {}
        while ids.length < max_items && ids.length < results.length 
          rand_index = rand( results.length )
          ids[rand_index] = results[rand_index]["id"]
        end
        ids.values
      end

      def random_ids_via_set(results, max_items)
        ids = Set.new
        while ids.length < max_items && ids.length < results.length 
          ids << results[rand( results.length )]["id"]
        end
        ids.to_a
      end

      def ramdom_ids_via_delete_at(results, max_items)
        ids = []
        results_start_length = results.length
        while ids.length < max_items && ids.length < results_start_length
          ids << ( results.delete_at(rand( results.length ))["id"] )
        end
        ids
      end

      def random_ids_via_partial_fisher_yates(results, max_items)
        i = 0
        # perform swaps only as far as we need
        while i < max_items && i < results.length
          # select only from portion of set past current element
          rand_i = i + rand( results.length - i ) 
          # swap current element, and picked element
          results[i], results[rand_i] = results[rand_i], results[i]
          i += 1
        end
        results[0, max_items].collect { |h| h['id'] }
      end

    end # Relation
    
    module Base
      
      # Class method
      def random(max_items = nil, random_method = nil)
        if random_method
          relation.random(max_items, random_method)
        else
          relation.random(max_items)
        end
      end
      
    end # Base
    
    
  end # ActiveRecord
  
end # Randumb


# Mix it in
class ActiveRecord::Relation
  include Randumb::ActiveRecord::Relation
end

class ActiveRecord::Base
  extend Randumb::ActiveRecord::Base
end
