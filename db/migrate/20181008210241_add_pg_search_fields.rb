# frozen_string_literal: true

class AddPgSearchFields < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE EXTENSION unaccent'
    execute 'CREATE EXTENSION pg_trgm'
    execute 'CREATE EXTENSION fuzzystrmatch'
  end

  def down
    execute 'drop extension unaccent'
    execute 'drop extension pg_trgm'
    execute 'drop extension fuzzystrmatch'
  end
end
