module Iphoto
  class Keyword < ActiveRecord::Base
    set_table_name "iphoto_keywords"
    
    belongs_to :library
  end
end
