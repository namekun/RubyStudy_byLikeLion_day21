## Day21_180710

- pusher
  - how? 코드가 정말 간단함.
  - CUD chatroom
  - join
  - chat
- wysiwyg editor 



### pusher

https://github.com/pusher/pusher-http-ruby



1. 젬추가하고 설치

*gemfile.rb*

```ruby
#pusher 
gem 'pusher'
#authentication
gem 'devise'
#key encrypt
gem 'figaro'
--
   turbolink 지우기
```

- console에서 수행

2. 디바이스 설치 `rails g devise:install`
3. user 만들기 `rails g devise users`
4. 채팅방 만들기 `rails g scaffold chat_room`
5. 모델만들기 `rails g model chat` , `rails g model admission`

*chat_room.rb*

```ruby
class CreateChatRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_rooms do |t|
      t.string :title
      t.string :master_id
      
      t.integer :max_count
	  t.integer :admissions_count, default: 0
        
      t.timestamps
    end
  end
end

```

> counter_cache 를 사용해본다.

이렇게 chat, admission 에도 추가해주자.

6. *~/chat_app/app/models/admission.rb*

```ruby
class Admission < ApplicationRecord
    belongs_to :user
    belongs_to :chat_room, counter_cache: true
end
```

> counter_cache: True 이므로 chat_room에서 `t.integer :admissions_count`

*~/chat_app/app/models/chat.rb*

```ruby
class Chat < ApplicationRecord
    belongs_to :user
    belongs_to :chat_room
end
```

*~/chat_app/app/models/chat_room.rb*

```ruby
class ChatRoom < ApplicationRecord
    has_many :admissions
    has_many :users, through: :admissions
    
    has_many :chats
end
```

*user.rb*

```ruby
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :admissions
  has_many :chat_rooms, through: :admissions
  has_many :chats
end
```

7. `rails c`에서 User하나 만들어주자

```ruby
User.create(email: "aa@aa.aa", password: "123123", password_confirmation: "123123")
ChatRoom.create(title: "어서와 채팅은 처음이지?", master_id: User.first.id, max_count: 5)
u = User.first
c = Chatroom.first
Admission.create(user_id: u.id, chat_room_id: c.id)
 ChatRoom.first.admissions
 ChatRoom.first.admissions.size		// count랑 같은 역할, 하지만 쿼리가 1번만 돈다.
```

8. *chat_room.rb*

```ruby
class ChatRoom < ApplicationRecord
    has_many :admissions
    has_many :users, through: :admissions
    has_many :chats
    def master_admit_room(user) #인스턴스 메소드
            # chat_room 이 만들어지고 나면, 이 메소드도 같이 실행하라
        Admission.create(user_id: user.id, chat_room_id: self.id)
    end 
end
```

>  chat_room 이 만들어지고 나면, 이 메소드도 같이 실행하라

>     # after_commit :method_name, on: :create
>     #after_commit :master_admit_room, on: :create

9. *chat_controller.rb*

```ruby
  def user_admit_room
    # 현재 유저가 있는 방에서 join버튼을 눌렀을때 동작하는 액션
    @chat_room.user_admit_room(current_user)
    
  end
```

> 우리가 위에 chat_room.rb에서 만들어준 master가 방을 만들고, 입장한다. 코드랑 같으니까 저 코드또한 
>
> ```ruby
>     def user_admit_room(user) #인스턴스 메소드
>        # chat_room 이 만들어지고 나면, 이 메소드도 같이 실행하라
>         Admission.create(user_id: user.id, chat_room_id: self.id)
>     end
> ```
>
> 으로 메소드를 바꿔주자.

10. 터보링크관련 다 삭제 
11. *~/chat_app/app/views/chat_rooms/_form.html.erb*

```ruby
  
  <div class="form-group">
    <%= f.label :title %>
    <%= f.text_field :title %>  
  </div>
  
  <div class="form-group">
    <%= f.label :max_count %>
```    
```ruby
<table>
  <thead>
    <tr>
      <th>방제</th>
      <th>인원</th>
      <th>방장</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @chat_rooms.each do |chat_room| %>
      <tr>
        <td><%= chat_room.title %></td>
        <td><%= chat_room.admissions.size %> / <%= chat_room.max_count %></td>
        <td><%= chat_room.master_id %></td>
        <td><%= link_to 'Show', chat_room %></td>
        <td><%= link_to 'Edit', edit_chat_room_path(chat_room) %></td>
        <td><%= link_to 'Destroy', chat_room, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

13. controller 에 파라미터 넘겨주기

```ruby
    def chat_room_params
      params.fetch(:chat_room, {}).permit(:title, :max_count)
    end
```

14. controller에 filter 추가 <- 로그인 안하면 아무것도 할수없도록.

```ruby
  before_action :authenticate_user!, except: [:index]
  # user_signed_in? 은 안돼 redirect가 안되기 때문에
```

15. https://pusher.com/ 으로 들어가기 회원가입해서 키 보이도록한후
16. `figaro install`
17. *~/chat_app/config/application.yml* 

```ruby
development:
    Pusher_app_id: 
    Pusher_key: 
    Pusher_secret: 
    Pusher_cluster: 
```



18. ~/chat_app/config/initializers/pusher.rb 만들고 다음 내용 입력.

```ruby
require 'pusher'

Pusher.app_id = ENV["Pusher_app_id"]
Pusher.key = ENV["Pusher_key"]
Pusher.secret = ENV["Pusher_secret"]
Pusher.cluster = ENV["Pusher_cluster"]
Pusher.logger = Rails.logger
Pusher.encrypted = true
```



19. chat_room 이 만들어질때 다른곳에서도 동시에 보이도록

*chat_room.rb* 에다가

```ruby
 def create_chat_room_notification
   Pusher.trigger('chat_room','create', self.as_json)
   #(channel_name, event_name, data를 json형태로// self+().as_json 더 넣고 싶다면 추가로 넣으세염)
 end
```

20. *application.html.erb* 에 ` <script src="https://js.pusher.com/4.1/pusher.min.js"></script>` 를 자바스크립트 코드 밑에다가 추가
21. *index.html.erb*

```ruby
<script>
  $(document).on('ready', function() {
    // 자바 스크립트 function
    // 방이 만들어졌을때, 방에대한 data를 받아서 
    function room_created(data) {
      $('.chat_room_list').prepend(`
      <tr>
        <td></td>
        <td> / </td>
        <td></td>
        <td></td>
      </tr>`);
      alert("방이 추가되었습니다.");
    }
    var pusher = new Pusher('<%= ENV["Pusher_app_id"]%> ', {
      cluster: '<%= ENV["Pusher_cluster"] %>,
      encrypted: true
    });

    var channel = pusher.subscribe('chat_room');
    channel.bind('create', function(data) { // data 는 chat_room 에서 json형태로 보내줘서.
#채널이름이랑 메소드명은 chat_room.rb랑 같게
      console.log(data);
    });
    // 방 목록에 추가해주는 function
  });
</script>
```

> console에 나오는 data 양식
> ```console
> admissions_count: 0
> created_at: "2018-07-10T05:02:53.188Z"
> id: 8
> master_id: "bb@bb.bb"
> max_count: 5
> title:"dfdfdfdfs"
> updated_at:
> "2018-07-10T05:02:53.188Z"
> ```



- 이제 data를 넣어주자! 그리고string interpolation으로 내용표시

```ruby
<script>
  $(document).on('ready', function() {
    // 자바 스크립트 function
    // 방이 만들어졌을때, 방에대한 data를 받아서 
    function room_created(data) {
      $('.chat_room_list').prepend(`
      <tr>
        <td>${data.title}</td>
        <td><span class="current${data.id}">0</span> / ${data.max_count} </td>
        <td>${data.master_id}</td>
        <td><a href="/chat_rooms/${data.id}">show</a></td>
      </tr>`);
      alert("방이 추가되었습니다.");
    }
    var pusher = new Pusher("<%= ENV["Pusher_key"]%>", {
      cluster: "<%= ENV["Pusher_cluster"] %>",
      encrypted: true
    });

    var channel = pusher.subscribe('chat_room');
    channel.bind('create', function(data) {
      console.log(data);
      room_created(data);
    });
    // 방 목록에 추가해주는 function
  });
</script>
```

- 이제 업데이트 된 방이 현재인원이 아무것도없으니까 그거 추가해주자 (현재입원 업데이트)

  - 트리거를 하나 더 추가

  *admission.rb*

  ```ruby
      def user_join_chat_room_notification
          Pusher.trigger('chat_room', 'join', {chat_room_id: self.chat_room_id }.as_json )
          # 어떤 방에 들어가는지.
      end
  ```

  *index.html.erb*

  ```ruby
      channel.bind('join', function(data) {
        console.log(data);
      })
    });
  ```

  > {chat_room_id: 12} 이렇게 로그에 찍히네



- 완성된 index

```ruby
<table>
  <thead>
    <tr>
      <th>방제</th>
      <th>인원</th>
      <th>방장</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody class="chat_room_list">
    <% @chat_rooms.reverse.each do |chat_room| %>
      <tr>
        <td><%= chat_room.title %></td>
        <td><span class="current<%=chat_room.id %>"><%= chat_room.admissions.size %></span> / <%= chat_room.max_count %></td>
        <td><%= chat_room.master_id %></td>
        <td><%= link_to 'Show', chat_room %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Chat Room', new_chat_room_path %>

<script>
  $(document).on('ready', function() {
    // 자바 스크립트 function
    // 방이 만들어졌을때, 방에대한 data를 받아서 
    function room_created(data) {
      $('.chat_room_list').prepend(`
      <tr>
        <td>${data.title}</td>
        <td> <span class="current${data.id}">0</span> / ${data.max_count} </td>
        <td>${data.master_id}</td>
        <td><a href="/chat_rooms/${data.id}">show</a></td>
      </tr>`);
      alert("방이 추가되었습니다.");
    }
    
    function user_joined(data){
      var current = $(`.current${data.chat_room_id}`);
      current.text(parseInt(current.text())+1);
    }
    
    
    var pusher = new Pusher("<%= ENV["Pusher_key"]%>", {
      cluster: "<%= ENV["Pusher_cluster"] %>",
      encrypted: true
    });

    var channel = pusher.subscribe('chat_room');
    channel.bind('create', function(data) {
      console.log(data);
      room_created(data);
    });
    // 방 목록에 추가해주는 function
    channel.bind('join', function(data) {
      console.log(data);
      user_joined(data);
    });
    
    
  });
</script>
```



22. 로그인한 상태 /  로그인 안한 상태

```ruby
<% if user_signed_in? %>
<%= current_user.email %> / <%link_to 'log_out', destroy_user_session_path, method: :delete %>
<% else %>
<%= link_to 'log_in', new_user_session_path %>
<% end %>
```

23. 그 채팅방안에 들어가면 현재 있는 유저 보도록 *show.html.erb*

```ruby
나 : <%= current_user.email %>
<h3> 현재 로그인한 사람 </h3>
<% @chat_room.users.each do |user| %>
    <p><%=user.email %></p>
<% end %>

<hr/>
<%= link_to 'Join','', %>
```

24. *routes.rb* 에서 우리가 이전에 만든 ` def user_admit_room(user)` 를 사용해줄꺼야

```ruby
  resources :chat_rooms do
    member do
      post'/join' => 'chat_rooms#user_admit_room', as: 'join'
    end
  end
```

> `as:` 로 prefix 설정

25. 해당 url을 사용하여 show.html.erb 완성

`<%= link_to 'Join', join_chat_room_path(@chat_room), method: 'post' %>`

> ,`remote: true` 까지 주면 이게 Ajax로 동작한다.
>
> <form>, <a> 에도 적용가능
>
> 이렇게 바꾸면 chat_controller에서 `def user_admit_room` 를 거치는데 자바스크립트로 요청을 받을땐 erb를 보낼수있으니까 
>
> user_admit_room.js.erb라는 파일을 실행시킬수있게된다.

> 조인버튼을 지워주는 코드를 여기다가 넣으면 되겠지? ^^ 일단 ``<%= link_to 'Join', join_chat_room_path(@chat_room), method: 'post', remote: true, class: "join_room" %>` 한뒤에 
>
> ```js
> $('.join_room').
> ```
>
>  show.html.erb의 <script> 에서 조인버튼을 없애는 코드를 넣으면 나만없어지는게 아니라 join하지 않고 그 방에 들어있는 모든 사람의 조인 버튼이 사라지는것을 볼수있다. 오호라

26. show에서도 join이 동작이 되게끔

```ruby
나 : <%= current_user.email %>
<h3> 현재 이 방에 참여한 사람 </h3>
<div class="joined_user_list">
<% @chat_room.users.each do |user| %>
    <p><%=user.email %></p>
<% end %>
</div>

<hr/>
<%= link_to 'Join', join_chat_room_path(@chat_room), method: 'POST' %>
<%= link_to 'Edit', edit_chat_room_path(@chat_room) %> |
<%= link_to 'Back', chat_rooms_path %>

<script>
    $(document).on('ready', function(){
        
        function user_joined(data){
            $('.joined_user_list').append(`<p>${data.email}<p>`)
        }
        
        
      var pusher = new Pusher("<%= ENV["Pusher_key"]%>", {
      cluster: "<%= ENV["Pusher_cluster"] %>",
      encrypted: true
    });
    
    var channel = pusher.subscribe('chat_room');
    channel.bind('join', function(data) { //channel 에서 날라온 data
      console.log(data);
      user_joined(data);
    });
    })
    
</script>
```







### 과제

- 이 방에 이미 참여한 사람은 join버튼이 안보이게,
- 무제한으로 참여할수없도록.
