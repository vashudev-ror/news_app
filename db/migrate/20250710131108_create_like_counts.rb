class CreateLikeCounts < ActiveRecord::Migration[7.1]
  def change
    create_table :like_counts do |t|
      t.references :article, null: false, foreign_key: true
      t.date :date
      t.integer :count

      t.timestamps
    end
  end
end
