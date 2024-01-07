import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FreeSDMIcon {
  FreeSDMIcon._();

  //for command page
  //powerpoint
  static SvgPicture powerpoint = SvgPicture.asset(
      'assets/microsoftpowerpoint.svg',
      color: Colors.white38,
  );

  static SvgPicture powerpointActive = SvgPicture.asset(
    'assets/microsoftpowerpoint.svg',
    color: const Color.fromRGBO(171, 196, 250, 1.0)
  );

  //netflix
  static SvgPicture netflix = SvgPicture.asset(
    'assets/netflix.svg',
    color: Colors.white38,
  );

  static SvgPicture netflixActive = SvgPicture.asset(
    'assets/netflix.svg',
    color: const Color.fromRGBO(171, 196, 250, 1.0),
  );

  //YouTube
  static SvgPicture youtube = SvgPicture.asset(
    'assets/youtube.svg',
    color: Colors.white38,
  );

  static SvgPicture youtubeActive = SvgPicture.asset(
    'assets/youtube.svg',
    color: const Color.fromRGBO(171, 196, 250, 1.0),
  );
}
