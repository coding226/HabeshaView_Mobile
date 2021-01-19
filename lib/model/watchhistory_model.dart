
import 'package:next_hour/model/watch_history_mt.dart';

class WatchHistoryModel {
  int id;
  var wUserId;
  var wMovieId;
  var tvId;
  String wCreatedAt;
  String wUpdatedAt;
  List<WatchHistoryData> mWatchHistoryData;
  List<WatchHistoryData> tWatchHistoryData;

  WatchHistoryModel({
    this.id,
    this.wUserId,
    this.wMovieId,
    this.tvId,
    this.wCreatedAt,
    this.wUpdatedAt,
    this.mWatchHistoryData,
    this.tWatchHistoryData,
  });
}