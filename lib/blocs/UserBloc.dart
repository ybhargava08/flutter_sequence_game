import 'package:google_sign_in/google_sign_in.dart';
import 'package:sequence/model/UserModel.dart';

class UserBloc {
  static UserBloc _userBloc;
  factory UserBloc() => _userBloc ??=UserBloc._();
  UserBloc._();

  UserModel _user;

  setCurrUser(GoogleSignInAccount _googleUser) {
        _user = UserModel(_googleUser.displayName, _googleUser.photoUrl, _googleUser.id, _googleUser.email,'');
  }

  UserModel getCurrUser() {
       return _user;
  }
}