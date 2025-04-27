import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_secure/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  void addUserToFirestore(UserModel user) async {
    try {
      DocumentReference docRef =
          _storage.collection(UserModel.collectionName).doc(user.id);
      await docRef.set(user.toJson()).whenComplete(
          () => print('User added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  Future<bool> updateUser(UserModel model) async {
    bool isSuccess = false;

    await _storage
        .collection(UserModel.collectionName)
        .doc(model.id)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<UserModel> getUserById(String id) async {
    final DocumentReference<Map<String, dynamic>> collectionRef =
        _storage.collection(UserModel.collectionName).doc(id);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await collectionRef.get();

    final UserModel user =
        UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    return user;
  }

  Future<List<UserModel>> getAllUsers() async {
    final QuerySnapshot querySnapshot =
        await _storage.collection(UserModel.collectionName).get();
    final users = querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    return users;
  }
}
