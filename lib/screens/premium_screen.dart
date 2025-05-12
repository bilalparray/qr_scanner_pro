import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  Future<void> _showRewardedAd(BuildContext context) async {
    final adProvider = context.read<AdProvider>();
    final success = await adProvider.showRewardedAd();

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Thank you for watching the ad! Premium features unlocked.'),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load ad. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Features'),
      ),
      body: Consumer<AdProvider>(
        builder: (context, adProvider, child) {
          final isRewarded = adProvider.isRewarded;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium Features',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.high_quality,
                        title: 'High-Quality Export',
                        description: 'Export codes in high resolution',
                        isUnlocked: isRewarded,
                      ),
                      _buildFeatureItem(
                        icon: Icons.history,
                        title: 'Unlimited History',
                        description: 'Store unlimited scan history',
                        isUnlocked: isRewarded,
                      ),
                      _buildFeatureItem(
                        icon: Icons.palette,
                        title: 'Advanced Customization',
                        description: 'More color options and styles',
                        isUnlocked: isRewarded,
                      ),
                      _buildFeatureItem(
                        icon: Icons.batch_prediction,
                        title: 'Batch Generation',
                        description: 'Generate multiple codes at once',
                        isUnlocked: isRewarded,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!isRewarded)
                ElevatedButton(
                  onPressed: () => _showRewardedAd(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Watch Ad to Unlock Premium Features',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isUnlocked,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: isUnlocked ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
}
