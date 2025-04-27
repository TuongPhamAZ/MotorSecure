import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_secure/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(NotificationModel.collectionName)
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(NotificationModel.collectionName)
          .orderBy('time', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              NotificationModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<NotificationModel>> getNotificationsByUserId(
      String userId) async {
    try {
      print("Đang tìm thông báo cho userId: $userId");

      // Cần tạo index cho truy vấn này trong Firebase console
      final QuerySnapshot querySnapshot = await _firestore
          .collection(NotificationModel.collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('time', descending: true)
          .get();

      print("Số lượng thông báo tìm thấy: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isEmpty) {
        // Nếu không có kết quả, kiểm tra xem có dữ liệu thông báo không
        final allNotifications = await getAllNotifications();
        print("Tổng số thông báo trong hệ thống: ${allNotifications.length}");

        // In ra userId của các thông báo để kiểm tra
        for (var notification in allNotifications) {
          print(
              "Thông báo ID: ${notification.id}, userId: '${notification.userId}'");
        }
      }

      return querySnapshot.docs.map((doc) {
        print("Document data: ${doc.data()}");
        return NotificationModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Lỗi khi lấy thông báo theo userId: $e");
      // Thử truy vấn mà không sắp xếp, vì có thể chưa có index
      try {
        final QuerySnapshot querySnapshot = await _firestore
            .collection(NotificationModel.collectionName)
            .where('userId', isEqualTo: userId)
            .get();

        print("Thử lại không có orderBy: ${querySnapshot.docs.length} kết quả");

        return querySnapshot.docs
            .map((doc) =>
                NotificationModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } catch (e2) {
        print("Lỗi lần 2: $e2");
        return [];
      }
    }
  }

  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(NotificationModel.collectionName)
          .doc(id)
          .get();

      if (doc.exists) {
        return NotificationModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      await _firestore
          .collection(NotificationModel.collectionName)
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(NotificationModel.collectionName)
          .doc(notification.id)
          .update(notification.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
