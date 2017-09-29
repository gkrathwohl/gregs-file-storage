class Upload < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, 
                  :against => [:name, :description, :full_text],
                  :using => {
                    :tsearch => {:prefix => true}
                  }
end
