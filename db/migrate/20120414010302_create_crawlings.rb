class CreateCrawlings < ActiveRecord::Migration
  def change
    create_table :crawlings do |t|
      t.text :url
      t.string :key_word
      t.text :result

      t.timestamps
    end
  end
end
