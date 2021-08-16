

class UserModel{
  final String firstName, surName, userName, email, createdOn, lastLogin;
  final List subscribed;

  UserModel({required this.firstName, required this.surName, required this.userName, required this.email, required this.createdOn, required this.lastLogin, required this.subscribed});
  
  factory UserModel.fromJson(data){
    return UserModel(
      firstName: data['firstname'],
      surName: data['surname'],
      userName: data['username'],
      email: data['email'],
      createdOn: data['createdOn'],
      lastLogin: data['lastLogin'],
      subscribed: data['subscribed']
    );
  }

  toMap(){
    return {
      'firstname': firstName,
      'surname': surName,
      'username': userName,
      'email': email,
      'createdOn': createdOn,
      'lastLogin': lastLogin,
      'subcribed': subscribed
    };
  }
}