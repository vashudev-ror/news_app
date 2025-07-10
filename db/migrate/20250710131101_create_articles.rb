class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.date :publication_date
      t.string :category
      t.string :author
      t.text :body

      t.timestamps
    end
  end
end
