import 'package:meta/meta.dart';

class CommentsModel{
  CommentsModel({
  @required this.id,
    @required this.cName,
    @required this.cEmail,
    this.cMovieId,
    this.cTvSeriesId,
    @required this.cComment,
    this.cCreatedAt,
    this.cUpdatedAt,
  });
  final int id;
  final String cName;
  final String cEmail;
  final String cMovieId;
  final String cTvSeriesId;
  final String cComment;
  final String cCreatedAt;
  final String cUpdatedAt;
}