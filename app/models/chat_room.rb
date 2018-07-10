class ChatRoom < ApplicationRecord
    has_many :admissions
    has_many :users, through: :admissions
    has_many :chats
    
    #after_commit :method_name, on: :create 
    #after_commit :master_admit_room, on: :create
    after_commit :create_chat_room_notification, on: :create

    def create_chat_room_notification
        Pusher.trigger('chat_room', 'create', self.as_json) 
        # (channel_name, event_name, 이벤트에 전달해 줄 data)
    end

    
    def user_admit_room(user)
        # chat_room이 하나 만들어지고 commit이 될 때, 해당 메소드도 같이 시행하라
        Admission.create(user_id: user.id, chat_room_id: self.id)
    end
    
    # 채팅방이 만들어 질 때, 현재 이 채팅방을 만든 유저가
    # 이 채팅방의 마스터가 되고, 현재 방에 참가한 것으로 된다.
end
