import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdProvider extends ChangeNotifier {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isRewarded = false;

  BannerAd? get bannerAd => _bannerAd;
  bool get isRewarded => _isRewarded;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: dotenv.env['ADMOB_BANNER_ID'] ?? '',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => notifyListeners(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          notifyListeners();
        },
      ),
    );

    _bannerAd?.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? '',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          notifyListeners();
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: dotenv.env['ADMOB_REWARDED_ID'] ?? '',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          notifyListeners();
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          _isRewarded = true;
          notifyListeners();
        },
      );
      _rewardedAd = null;
      _loadRewardedAd();
      return true;
    }
    return false;
  }

  void resetReward() {
    _isRewarded = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
