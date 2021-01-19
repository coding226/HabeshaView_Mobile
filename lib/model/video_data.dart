import 'package:meta/meta.dart';
import 'package:next_hour/model/comments_model.dart';
import 'package:next_hour/model/seasons.dart';

class VideoDataModel {
  VideoDataModel({
    @required this.name,
    @required this.box,
    this.duration,
    this.cover,
    this.description,
    this.platforms,
    this.rating,
    this.screenshots,
    this.url,
    this.menuId,
    this.genre,
    this.maturityRating,
    this.genres,
    this.id,
    this.datatype,
    this.seasons,
    this.released,
    this.isLive,
    this.comments,
    this.aLang,
    this.videoLink,
    this.iFrameLink,
    this.readyUrl,
    this.url360,
    this.url480,
    this.url720,
    this.url1080,
  });
  final id;
  final List<String> genres;
  final String name;
  final String duration;
  final String box;
  final String cover;
  final String description;
  final List<String> platforms;
  final double rating;
  final String url;
  final List<String> screenshots;
  final menuId;
  final List<String> genre;
  final String maturityRating;
  final String datatype;
  final List<Seasons> seasons;
  final List<CommentsModel> comments;
  final String released;
  final String isLive;
  final String aLang;
  final String videoLink;
  final String iFrameLink;
  final String readyUrl;
  final String url360;
  final String url480;
  final String url720;
  final String url1080;

  String getPlatforms() {
    String platformText = "";
    if (platforms.length > 1) {
      for (int i = 0; i < platforms.length; i++) {
        if (i == 0) {
          platformText = platforms[0];
        } else {
          platformText = platformText + " | " + platforms[i];
        }
      }
    } else if (platforms.length == 1) {
      platformText = platforms[0];
    }

    return platformText;
  }

}
