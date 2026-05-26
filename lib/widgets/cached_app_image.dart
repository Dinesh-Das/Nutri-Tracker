import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

ImageProvider<Object> cachedNetworkImageProvider(String imageUrl) {
  final url = imageUrl.trim();
  if (_isMissingUrl(url)) {
    return const AssetImage('assets/images/Nutri.png');
  }
  return CachedNetworkImageProvider(url);
}

class CachedAppImage extends StatelessWidget {
  const CachedAppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorIcon = Icons.image_not_supported_outlined,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    if (_isMissingUrl(url)) {
      return _ImageFallback(
        width: width,
        height: height,
        icon: errorIcon,
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, _, __) => _ImageFallback(
        width: width,
        height: height,
        icon: errorIcon,
      ),
    );
  }
}

bool _isMissingUrl(String url) => url.isEmpty || url.toLowerCase() == 'null';

class CachedCircleImage extends StatelessWidget {
  const CachedCircleImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.errorIcon = Icons.person,
  });

  final String imageUrl;
  final double size;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedAppImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorIcon: errorIcon,
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    required this.width,
    required this.height,
    required this.icon,
  });

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
