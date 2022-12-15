class EnableMultiSearchable < ActiveRecord::Migration[6.1]
  def up
    Contact.rebuild_pg_search_documents
    PgSearch::Multisearch.rebuild(Conversation)
    PgSearch::Multisearch.rebuild(Message)
    execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'
  end

  def down
    PgSearch::Document.delete_all
  end
end
