require_relative 'db_connection'
require 'active_support/inflector'
require "byebug"
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    @columns ||= DBConnection.execute2(<<-SQL)
    SELECT *
    FROM #{table_name}
    SQL
    .first
    .map(&:to_sym)
  end

  def self.finalize!
    cols = columns
    cols.each do |column|
      define_method(column) do 
        attributes[column]
      end
      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    name = self.inspect
    
    @table_name ||= name.downcase + "s"
  end

  def self.all
    # ...
    arr = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    parse_all(arr)
  end

  def self.parse_all(results)
    # ...
    results.map{|hash| self.new(hash)}
  end

  def self.find(id)
    # ...
    hash = DBConnection.execute(<<-SQL,id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL
    .first
    return nil if hash.nil?
    self.new(hash)
  end

  def initialize(params = {})
    # ...
    columns = self.class.columns
    params.each do |k,v|
      raise "unknown attribute '#{k}'" unless columns.include?(k.to_sym)
      self.send("#{k}=".to_sym,v)
    end
  end

  def attributes
    # ...
    @attributes ||= {}

  end

  def attribute_values
    # ...
    arr = []
    attributes.each do |k,v|
      arr << v
    end
    arr

  end
  def attributes_array
    # ...
    arr = []
    attributes.each do |k,v|
      arr << [k,v]
    end
    arr
  end

  def insert
    # ...
    col_syms = self.class.columns[1..-1]
    col_names = col_syms.map(&:to_s).join(", ")
    col_names = "(" + col_names + ")"
    question_marks = (["?"] * (attributes.count)).join(", ")
    question_marks = "(" + question_marks + ")"
    cols = col_syms.map{|col| self.send(col)}
    # debugger
    DBConnection.execute(<<-SQL,cols)
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks}
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    vals = attribute_values
    vals.shift
    setstring = attributes_array.map{|pair| " #{pair[0]} = ?"}
    setstring = setstring.join(",")
    DBConnection.execute(<<-SQL,attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{setstring}
      WHERE
        id = #{self.id}

    SQL
  end

  def save
    # ...
    if id.nil?
      self.insert
    else
      self.update
    end
  end
end
