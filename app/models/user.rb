class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # belongs_toでなくhas many
  # hasumany時は複数形、注意！
  # default:class_name:"favorite" forein_key: "User.id"
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :books, dependent: :destroy
 
  # @user.active_relationshipsでユーザーのフォローしている(followed)人を呼び出す
  # Relationshipに格納されているfollwer_idとfollowed_idを呼び出す
  has_many :active_relationships,  class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id",dependent: :destroy
  
  # 見たいのはuserのフォローしているuser達の情報 ↓
  # active_relationshipsで、follower_idを指定して、Relationshipを取得(follwer_id=1)
  # followingsで持ってきたRelationshipに対してfollowedを実行
  # followedはfollowed_id = user_idなのでフォローされているユーザーの情報を呼び出す
  
  has_many :followings, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }

  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  # フォローする
  def follow(user_id)
    unless self == user_id
     self.active_relationships.find_or_create_by(followed_id: user_id.to_i, follower_id: self.id)
    end
  end
  # ユーザーのフォローを外す
  def unfollow(user_id)
   active_relationships.find_by(followed_id: user_id).destroy
  end
  # フォロー確認をおこなう
  def following?(user)
   followings.include?(user)
  end

  # 検索メソッド

end