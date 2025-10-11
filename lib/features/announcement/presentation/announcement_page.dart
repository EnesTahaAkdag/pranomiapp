import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/features/announcement/data/announcement_model.dart';
import 'package:pranomiapp/features/announcement/data/announcement_service.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/features/announcement/domain/announcement_type.dart';
import 'package:pranomiapp/features/announcement/presentation/announcement_state.dart';
import 'package:pranomiapp/features/announcement/presentation/announcement_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Announcement Page - MVVM Pattern with Provider
/// Following Single Responsibility: Only handles UI composition
class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnnouncementViewModel(locator<AnnouncementService>()),
      child: const _AnnouncementView(),
    );
  }
}

/// Main view widget - Listens to ViewModel changes
class _AnnouncementView extends StatelessWidget {
  const _AnnouncementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AnnouncementViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
    );
  }

  /// Builds body based on current state
  Widget _buildBody(BuildContext context, AnnouncementViewModel viewModel) {
    final state = viewModel.state;

    // Pattern matching on state type
    if (state is AnnouncementLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AnnouncementError) {
      return _ErrorView(
        error: state.message,
        onRetry: viewModel.fetchAnnouncements,
      );
    }

    if (state is AnnouncementLoaded) {
      if (state.isEmpty) {
        return _EmptyView(onRefresh: viewModel.refresh);
      }

      return RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: state.announcements.length,
          itemBuilder: (context, index) {
            final announcement = state.announcements[index];
            return AnnouncementCard(
              key: ValueKey(announcement.id),
              announcement: announcement,
            );
          },
        ),
      );
    }

    // Initial state or unknown state
    return const SizedBox.shrink();
  }
}

// ============================================================================
// REUSABLE UI COMPONENTS (Following Single Responsibility Principle)
// ============================================================================

/// Error view widget
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

/// Empty state view widget
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

/// Announcement card widget - Encapsulates single announcement display
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

/// Announcement header with title and icon
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

/// Announcement date display
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

/// Announcement HTML content display
class _AnnouncementContent extends StatelessWidget {
  final String description;

  // HTML style configuration - const for performance
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

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Launches URL in external browser
Future<void> _launchURL(String urlAddress) async {
  final Uri url = Uri.parse(urlAddress);

  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

/// Maps announcement type to corresponding icon
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