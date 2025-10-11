import 'package:pranomiapp/features/announcement/data/announcement_model.dart';

/// Base state class for announcements
/// Following Single Responsibility Principle - each state represents one condition
abstract class AnnouncementState {
  const AnnouncementState();
}

/// Initial state before any data is loaded
class AnnouncementInitial extends AnnouncementState {
  const AnnouncementInitial();
}

/// Loading state when fetching data
class AnnouncementLoading extends AnnouncementState {
  const AnnouncementLoading();
}

/// Success state with loaded announcements
class AnnouncementLoaded extends AnnouncementState {
  final List<AnnouncementModel> announcements;

  const AnnouncementLoaded(this.announcements);

  bool get isEmpty => announcements.isEmpty;
  bool get isNotEmpty => announcements.isNotEmpty;
}

/// Error state with error message
class AnnouncementError extends AnnouncementState {
  final String message;

  const AnnouncementError(this.message);
}