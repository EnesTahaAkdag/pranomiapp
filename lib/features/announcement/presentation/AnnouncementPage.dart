import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/features/announcement/data/AnnouncementModel.dart';
import 'package:pranomiapp/features/announcement/data/AnnouncementService.dart';
import 'package:pranomiapp/core/di/Injection.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/AnnouncementType.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  late final AnnouncementService _announcementService;
  List<AnnouncementModel>? _announcements;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _announcementService = locator<AnnouncementService>();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final announcements = await _announcementService.fetchAnnouncements();
      if (mounted) {
        setState(() {
          _announcements = announcements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Duyurular yüklenirken bir hata oluştu: ${e.toString()}";
          debugPrint("Error fetching announcements: $e");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorView(
        error: _error!,
        onRetry: _fetchAnnouncements,
      );
    }

    if (_announcements == null || _announcements!.isEmpty) {
      return _EmptyView(onRefresh: _fetchAnnouncements);
    }

    return RefreshIndicator(
      onRefresh: _fetchAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _announcements!.length,
        itemBuilder: (context, index) {
          final announcement = _announcements![index];
          return AnnouncementCard(
            key: ValueKey(announcement.id ?? index),
            announcement: announcement,
          );
        },
      ),
    );
  }
}

// Ayrı widget - Gereksiz rebuild'leri önler
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Tekrar Dene"),
            ),
          ],
        ),
      ),
    );
  }
}

// Ayrı widget - Gereksiz rebuild'leri önler
class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Gösterilecek duyuru bulunmamaktadır.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text("Yenile"),
          ),
        ],
      ),
    );
  }
}

// Ayrı widget class - Her item bağımsız rebuild olur
class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementCard({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnnouncementHeader(announcement: announcement),
            const SizedBox(height: 4),
            _AnnouncementDate(date: announcement.createdAt),
            const SizedBox(height: 8),
            _AnnouncementContent(description: announcement.description),
          ],
        ),
      ),
    );
  }
}

// Header - const olmayan Icon nedeniyle ayrı widget
class _AnnouncementHeader extends StatelessWidget {
  final AnnouncementModel announcement;

  const _AnnouncementHeader({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            announcement.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Icon(
          _getIconForType(
            parseAnnouncementType(announcement.announcementType),
          ),
          color: const Color(0xFFB00034),
          size: 36,
        ),
      ],
    );
  }
}

// Tarih - Cache için ayrı widget
class _AnnouncementDate extends StatelessWidget {
  final DateTime date;
  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  const _AnnouncementDate({required this.date});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Yayınlanma Tarihi: ${_dateFormat.format(date)}',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// HTML content - En ağır kısım, ayrı widget olarak cache'lenir
class _AnnouncementContent extends StatelessWidget {
  final String description;

  // HTML stil ayarları - const olarak tanımla, her build'de yeniden oluşturulmasın
  static final _htmlStyle = {
    "body": Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      fontSize: FontSize(16),
    ),
    "p": Style(
      margin: Margins.symmetric(vertical: 6.0),
      lineHeight: const LineHeight(1.4),
    ),
  };

  const _AnnouncementContent({required this.description});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: description,
      style: _htmlStyle,
      onLinkTap: (url, _, __) {
        _launchURL(url ?? "https://www.google.com");
      },
    );
  }
}

Future<void> _launchURL(String urlAddress) async {
  final Uri url = Uri.parse(urlAddress);

  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

IconData _getIconForType(AnnouncementType type) {
  switch (type) {
    case AnnouncementType.news:
      return Icons.newspaper;
    case AnnouncementType.announcement:
      return Icons.campaign;
    case AnnouncementType.changelog:
      return Icons.alt_route;
    case AnnouncementType.unknown:
    default:
      return Icons.info_outline;
  }
}