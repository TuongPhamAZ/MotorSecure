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

  /// Tìm kiếm các thông báo tương tự gần đây
  /// * `userId`: ID của người dùng
  /// * `title`: Tiêu đề của thông báo
  /// * `content`: Nội dung của thông báo chính
  /// * `timeFrame`: Khoảng thời gian để tìm kiếm (mặc định là 10 phút)
  Future<List<NotificationModel>> getRecentEmergencyNotifications({
    required String userId,
    required String title,
    required String content,
    Duration timeFrame = const Duration(minutes: 10),
    String? vehicleId, // không dùng nhưng vẫn giữ để khớp với signature
  }) async {
    try {
      // Thời gian hiện tại trừ đi khoảng thời gian cần kiểm tra
      final DateTime cutoffTime = DateTime.now().subtract(timeFrame);

      print("Tìm kiếm thông báo từ ${cutoffTime.toString()}");

      // Tách phần nội dung chính mà không chứa thời gian (nếu có thể)
      // Ví dụ: nếu nội dung là "Phát hiện trộm xe lúc 15:30:45", chỉ lấy "Phát hiện trộm xe"
      final String contentCore = _extractContentCore(content);

      // Bắt đầu tạo truy vấn
      Query query = _firestore
          .collection(NotificationModel.collectionName)
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .where('time', isGreaterThan: Timestamp.fromDate(cutoffTime))
          .orderBy('time', descending: true);

      final QuerySnapshot querySnapshot = await query.get();

      // Lọc sau khi truy vấn để kiểm tra nội dung có chứa phần chính không
      List<NotificationModel> similarNotifications = [];

      for (var doc in querySnapshot.docs) {
        final notification =
            NotificationModel.fromJson(doc.data() as Map<String, dynamic>);

        // Trích xuất phần nội dung chính của thông báo đã lưu
        final String savedContentCore =
            _extractContentCore(notification.content);

        // So sánh phần nội dung chính
        if (contentCore.isNotEmpty && savedContentCore.contains(contentCore)) {
          similarNotifications.add(notification);
        }
      }

      print(
          "Tìm thấy ${similarNotifications.length} thông báo tương tự gần đây");

      return similarNotifications;
    } catch (e) {
      print("Lỗi khi tìm thông báo gần đây: $e");
      return [];
    }
  }

  // Hàm trích xuất phần nội dung chính từ nội dung đầy đủ
  // Loại bỏ các phần động như thời gian, ngày tháng, etc.
  String _extractContentCore(String fullContent) {
    try {
      // Tìm và loại bỏ các mẫu thời gian phổ biến
      // Ví dụ: "lúc 15:30:45" hoặc "vào 15:30"
      RegExp timePattern = RegExp(r'(lúc|vào)\s+\d{1,2}:\d{1,2}(:\d{1,2})?');

      // Loại bỏ mẫu thời gian
      String contentWithoutTime = fullContent.replaceAll(timePattern, '');

      // Loại bỏ khoảng trắng dư thừa
      contentWithoutTime = contentWithoutTime.trim();

      // Nếu nội dung vẫn dài, lấy một phần đủ để xác định loại thông báo
      if (contentWithoutTime.length > 20) {
        return contentWithoutTime.substring(0, 20);
      }

      return contentWithoutTime;
    } catch (e) {
      // Nếu có lỗi, trả về nội dung gốc
      return fullContent;
    }
  }
}
