import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/features/announcement/data/AnnouncementModel.dart';
import 'package:pranomiapp/features/announcement/data/AnnouncementService.dart';
import 'package:pranomiapp/core/di/Injection.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyurular'), // Announcements
        centerTitle: true,
        // backgroundColor: const Color(0xFF2C2C2C), // Or your app's standard AppBar color
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchAnnouncements,
                child: const Text("Tekrar Dene"),
              ),
            ],
          ),
        ),
      );
    }

    if (_announcements == null || _announcements!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Gosterilecek duyuru bulunmamaktadır.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAnnouncements,
              child: const Text("Yenile"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _announcements!.length,
        itemBuilder: (context, index) {
          final announcement = _announcements![index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yayınlanma Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(announcement.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Html(
                    data: announcement.description,
                    style: {
                      "body": Style(
                        // Remove default browser margins for the body tag within Html widget
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(16),
                      ),
                      "p": Style(
                        // Adjust paragraph margins if needed, or line height
                        margin: Margins.symmetric(vertical: 6.0),
                        lineHeight: const LineHeight(1.4),
                      ),
                      // Add more styles for other HTML tags like h1, h2, ul, li etc. if needed
                    },
                    onLinkTap: (url, _, __) {
                      _launchURL(url ?? "https://www.google.com");
                    },
                    // You can also add onLinkTap, onImageTap etc. from flutter_html
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _launchURL(String urlAddress) async {
  final Uri url = Uri.parse(urlAddress);

  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
