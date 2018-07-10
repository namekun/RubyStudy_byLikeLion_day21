class CreateChatRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_rooms do |t|
      
      t.string      :title
      t.string      :master_id
      
      
      t.integer     :max_count
      t.integer     :admissions_count, default: 0 # join 테이블에서 몇개가 만들어져있는지 넣어줄것(현재 카운트)
      
      
      
      t.timestamps
    end
  end
end
