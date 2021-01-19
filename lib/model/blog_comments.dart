import 'package:meta/meta.dart';

class BlogComments{
  BlogComments({
   this.id,
    @required this.cName,
    @required this.cEmail,
    @required this.cBlogId,
    @required this.cComment,
    this.cCreatedAt,
    this.cUpdatedAt,
  });
  final int id;
  final String cBlogId;
  final String cName;
  final String cEmail;
  final String cComment;
  final String cCreatedAt;
  final String cUpdatedAt;
}