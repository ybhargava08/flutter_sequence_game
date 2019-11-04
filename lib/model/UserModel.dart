class UserModel  {
     String name;
     String photoUrl;
     String id;
     String email;
     String color='red';

     UserModel(this.name,this.photoUrl,this.id,this.email,this.color);
   
     Map<String,String> toJson() {
           Map<String,String> map = Map();
           map['name'] = name;
           map['id'] = id;
           map['photoUrl'] = photoUrl;
           map['email'] = email;
           map['color'] = color;
           return map;
     }

     factory UserModel.fromJson(Map<dynamic,dynamic> map) {
          return UserModel(map['name'], map['photoUrl'], map['id'], map['email'],map['color']);
     }

     @override
  String toString() {
    return 'name '+name+' id '+id;
  }
}