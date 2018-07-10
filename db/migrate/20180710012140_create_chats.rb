class CreateChats < ActiveRecord::Migration[5.0]
  def change
    create_table :chats do |t|
      
      t.references      :user # 누가 여기서 채팅했지?
      t.references      :chat_room # 어느방에서 채팅했지?
      
      t.timestamps
    end
  end
end
