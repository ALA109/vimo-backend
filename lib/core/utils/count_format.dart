String formatCount(int n) {
  if (n >= 1000000000) return '${(n/1000000000).toStringAsFixed(n % 1000000000 == 0 ? 0 : 1)}B';
  if (n >= 1000000) return '${(n/1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
  if (n >= 1000) return '${(n/1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
  return '$n';
}
