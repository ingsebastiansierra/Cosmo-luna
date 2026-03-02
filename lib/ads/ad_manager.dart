import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;
  static int _failCount = 0;

  // IDs de AdMob de PRUEBA (reemplazar con IDs reales al publicar)
  static const String rewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  static const String interstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  static const String bannerAdId = 'ca-app-pub-3940256099942544/6300978111';

  static Future<void> initialize() async {
    await loadRewardedAd();
    await loadInterstitialAd();
  }

  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({required Function onReward}) {
    if (_rewardedAd == null) {
      print('Rewarded ad not ready');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      onReward();
    });
    _rewardedAd = null;
  }

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  static void onLevelFailed() {
    _failCount++;
    if (_failCount >= 3) {
      showInterstitialAd();
      _failCount = 0;
    }
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Interstitial ad not ready');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner ad failed to load: $error');
        },
      ),
    );
  }
}
