enum AnnouncementType {
  news,
  announcement,
  changelog,
  unknown,
}

AnnouncementType parseAnnouncementType(String type) {
  switch (type.toLowerCase()) {
    case 'news':
      return AnnouncementType.news;
    case 'announcement':
      return AnnouncementType.announcement;
    case 'changelog':
      return AnnouncementType.changelog;
    default:
      return AnnouncementType.unknown;
  }
}