import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static BannerAd createBottomBannerAd() {
    final adUnitId = Platform.isIOS
        ? dotenv.env['IOS_AD_UNIT_ID']!
        : dotenv.env['ANDROID_AD_UNIT_ID']!;

    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );
  }

  static Widget bottomBannerAdWidget(BannerAd? ad) {
    return ad == null
        ? SizedBox()
        : Container(
            height: ad.size.height.toDouble(),
            width: ad.size.width.toDouble(),
            child: AdWidget(ad: ad),
          );
  }
}
