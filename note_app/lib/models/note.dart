import 'package:flutter/material.dart';

class Note {
    int? id;
    String title;
    String content;
    DateTime modifiedTime;
    Color color;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
    required this.color,
  });

  // Phương thức chuyển đổi Note thành một Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'modifiedTime': modifiedTime.toIso8601String(), // Chuyển đổi DateTime thành String
      'color': color.value, // Lấy giá trị màu sắc
    };
  }

  // Phương thức tạo Note từ một Map
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      modifiedTime: DateTime.parse(map['modifiedTime']), // Chuyển đổi String thành DateTime
      color: Color(map['color']), // Tạo màu từ giá trị
    );
  }

  // Phương thức sao chép một Note với id mới
  Note copy({int? id}) {
    return Note(
      id: id ?? this.id,
      title: title,
      content: content,
      modifiedTime: modifiedTime,
      color: color,
    );
  }
}
