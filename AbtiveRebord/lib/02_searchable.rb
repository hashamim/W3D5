require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    str = params.keys.map{|param|" #{param} = :#{param}"}
    str = str.join(" AND ")
    debugger 
    arr = DBConnection.execute(<<-SQL,params)
    SELECT *
    FROM #{self.table_name}
    WHERE
    #{str}
    SQL
    
    arr.map{|attributes| self.new(attributes)}
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
