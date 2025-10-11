import 'package:flutter/foundation.dart';
import 'package:pranomiapp/features/announcement/data/announcement_service.dart';
import 'package:pranomiapp/features/announcement/presentation/announcement_state.dart';

/// ViewModel for Announcement feature
/// Following MVVM pattern with Provider for state management
/// Single Responsibility: Manages announcement business logic and state
class AnnouncementViewModel extends ChangeNotifier {
  final AnnouncementService _announcementService;

  // Private state, exposed through getter
  AnnouncementState _state = const AnnouncementInitial();

  /// Current state of announcements
  AnnouncementState get state => _state;

  /// Constructor with dependency injection
  /// Following Dependency Inversion Principle
  AnnouncementViewModel(this._announcementService) {
    // Auto-load announcements when ViewModel is created
    fetchAnnouncements();
  }

  /// Fetches announcements from the service
  /// Updates state accordingly
  Future<void> fetchAnnouncements() async {
    // Set loading state
    _updateState(const AnnouncementLoading());

    try {
      // Fetch data from service
      final announcements = await _announcementService.fetchAnnouncements();

      // Update state based on result
      if (announcements != null) {
        _updateState(AnnouncementLoaded(announcements));
      } else {
        _updateState(const AnnouncementError('Veri alınamadı'));
      }
    } catch (e) {
      // Handle errors gracefully
      final errorMessage = 'Duyurular yüklenirken bir hata oluştu: ${e.toString()}';
      _updateState(AnnouncementError(errorMessage));
      debugPrint('Error fetching announcements: $e');
    }
  }

  /// Refresh announcements (pull-to-refresh)
  Future<void> refresh() async {
    await fetchAnnouncements();
  }

  /// Updates state and notifies listeners
  /// Private method to ensure encapsulation
  void _updateState(AnnouncementState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}