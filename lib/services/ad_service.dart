import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_scanner/environment/environment.dart';

class AdService {
  AdService._privateConstructor();
  static final AdService instance = AdService._privateConstructor();

  BannerAd? _bannerAd;
  final ValueNotifier<bool> bannerLoadedNotifier = ValueNotifier(false);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  NativeAd? _nativeAd;

  /// Preload all ad types including a single banner ad instance
  Future<void> preloadAllAds() async {
    // Preload banner ad and track when loaded
    _bannerAd = BannerAd(
      adUnitId: Environment.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          bannerLoadedNotifier.value = true;
          if (kDebugMode) print('BannerAd loaded');
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) print('BannerAd failed to load: $error');
          ad.dispose();
          bannerLoadedNotifier.value = false;
        },
      ),
    )..load();

    // Interstitial
    InterstitialAd.load(
      adUnitId: Environment.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          if (kDebugMode) print('InterstitialAd loaded');
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) print('InterstitialAd failed to load: $error');
        },
      ),
    );

    // Rewarded
    RewardedAd.load(
      adUnitId: Environment.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          if (kDebugMode) print('RewardedAd loaded');
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) print('RewardedAd failed to load: $error');
        },
      ),
    );

    // App Open
    AppOpenAd.load(
      adUnitId: Environment.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          if (kDebugMode) print('AppOpenAd loaded');
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) print('AppOpenAd failed to load: $error');
        },
      ),
    );

    // Native Ad
    _nativeAd = NativeAd(
      adUnitId: Environment.nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (kDebugMode) print('NativeAd loaded');
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) print('NativeAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Show interstitial and reload after dismissed
  void showInterstitialAd(Function()? onAdClosed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;

          InterstitialAd.load(
            adUnitId: Environment.interstitialAdUnitId,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) => _interstitialAd = ad,
              onAdFailedToLoad: (error) {
                if (kDebugMode) {
                  print('Failed to reload InterstitialAd: $error');
                }
              },
            ),
          );

          if (onAdClosed != null) onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if (kDebugMode) print('InterstitialAd failed to show: $error');
        },
      );
      _interstitialAd!.show();
    }
  }

  /// Show rewarded ad and reload after dismissed
  void showRewardedAd(Function()? onReward) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;

          RewardedAd.load(
            adUnitId: Environment.rewardedAdUnitId,
            request: const AdRequest(),
            rewardedAdLoadCallback: RewardedAdLoadCallback(
              onAdLoaded: (ad) => _rewardedAd = ad,
              onAdFailedToLoad: (error) {
                if (kDebugMode) {
                  print('Failed to reload RewardedAd: $error');
                }
              },
            ),
          );
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if (kDebugMode) print('RewardedAd failed to show: $error');
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          if (onReward != null) onReward();
        },
      );
    }
  }

  /// Show app open ad and reload after dismissed
  void showAppOpenAd(Function()? onAdClosed) {
    if (_appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          AppOpenAd.load(
            adUnitId: Environment.appOpenAdUnitId,
            request: const AdRequest(),
            adLoadCallback: AppOpenAdLoadCallback(
              onAdLoaded: (ad) => _appOpenAd = ad,
              onAdFailedToLoad: (error) {
                if (kDebugMode) print('Failed to reload AppOpenAd: $error');
              },
            ),
          );
          if (onAdClosed != null) onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if (kDebugMode) print('AppOpenAd failed to show: $error');
        },
      );
      _appOpenAd!.show();
    }
  }

  /// Getter for singleton banner ad
  BannerAd? get bannerAd => _bannerAd;

  /// Getter for native ad
  NativeAd? get nativeAd => _nativeAd;

  /// Factory method: create a NEW BannerAd instance
  /// To use when you want multiple banner ads independently
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: Environment.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (kDebugMode) print('Created BannerAd loaded');
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) print('Created BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
}
