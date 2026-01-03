class Roommate {
  Roommate({required this.id, required this.name, this.email, this.isYou = false});

  final String id;
  final String name;
  final String? email;
  final bool isYou;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isYou': isYou,
      };

  static Roommate fromJson(Map<String, dynamic> json) => Roommate(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        isYou: (json['isYou'] as bool?) ?? false,
      );
}

class ChoreHistoryEntry {
  ChoreHistoryEntry({required this.id, required this.completedByRoommateId, required this.completedAtIso});

  final String id;
  final String completedByRoommateId;
  final String completedAtIso;

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedByRoommateId': completedByRoommateId,
        'completedAtIso': completedAtIso,
      };

  static ChoreHistoryEntry fromJson(Map<String, dynamic> json) => ChoreHistoryEntry(
        id: json['id'] as String,
        completedByRoommateId: json['completedByRoommateId'] as String,
        completedAtIso: json['completedAtIso'] as String,
      );
}

class Chore {
  Chore({
    required this.id,
    required this.title,
    required this.createdAtIso,
    required this.currentTurnRoommateId,
    required this.nextTurnRoommateId,
    required this.history,
    this.repeatText,
  });

  final String id;
  final String title;
  final String createdAtIso;
  final String currentTurnRoommateId;
  final String nextTurnRoommateId;
  final List<ChoreHistoryEntry> history;
  final String? repeatText;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAtIso': createdAtIso,
        'repeatText': repeatText,
        'currentTurnRoommateId': currentTurnRoommateId,
        'nextTurnRoommateId': nextTurnRoommateId,
        'history': history.map((h) => h.toJson()).toList(),
      };

  static Chore fromJson(Map<String, dynamic> json) => Chore(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAtIso: json['createdAtIso'] as String,
        repeatText: json['repeatText'] as String?,
        currentTurnRoommateId: json['currentTurnRoommateId'] as String,
        nextTurnRoommateId: json['nextTurnRoommateId'] as String,
        history: (json['history'] as List<dynamic>? ?? [])
            .map((e) => ChoreHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Room {
  Room({required this.id, required this.name, this.inviteCode});

  final String id;
  final String name;
  final String? inviteCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'inviteCode': inviteCode,
      };

  static Room fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        name: json['name'] as String,
        inviteCode: json['inviteCode'] as String?,
      );
}

class Preferences {
  Preferences({
    required this.pushNotificationsEnabled,
    required this.reminderFrequency,
    required this.doNotDisturbEnabled,
  });

  final bool pushNotificationsEnabled;
  final String reminderFrequency; // Daily | Weekly | Off
  final bool doNotDisturbEnabled;

  Map<String, dynamic> toJson() => {
        'pushNotificationsEnabled': pushNotificationsEnabled,
        'reminderFrequency': reminderFrequency,
        'doNotDisturbEnabled': doNotDisturbEnabled,
      };

  static Preferences defaults() => Preferences(
        pushNotificationsEnabled: true,
        reminderFrequency: 'Daily',
        doNotDisturbEnabled: false,
      );

  static Preferences fromJson(Map<String, dynamic> json) => Preferences(
        pushNotificationsEnabled: (json['pushNotificationsEnabled'] as bool?) ?? true,
        reminderFrequency: (json['reminderFrequency'] as String?) ?? 'Daily',
        doNotDisturbEnabled: (json['doNotDisturbEnabled'] as bool?) ?? false,
      );
}

class PersistedState {
  PersistedState({
    required this.onboardingComplete,
    required this.proUnlocked,
    required this.room,
    required this.roommates,
    required this.chores,
    required this.preferences,
  });

  final bool onboardingComplete;
  final bool proUnlocked;
  final Room? room;
  final List<Roommate> roommates;
  final List<Chore> chores;
  final Preferences preferences;

  Map<String, dynamic> toJson() => {
        'onboardingComplete': onboardingComplete,
        'proUnlocked': proUnlocked,
        'room': room?.toJson(),
        'roommates': roommates.map((r) => r.toJson()).toList(),
        'chores': chores.map((c) => c.toJson()).toList(),
        'preferences': preferences.toJson(),
      };

  static PersistedState fromJson(Map<String, dynamic> json) => PersistedState(
        onboardingComplete: (json['onboardingComplete'] as bool?) ?? false,
        proUnlocked: (json['proUnlocked'] as bool?) ?? false,
        room: json['room'] == null ? null : Room.fromJson(json['room'] as Map<String, dynamic>),
        roommates: (json['roommates'] as List<dynamic>? ?? [])
            .map((e) => Roommate.fromJson(e as Map<String, dynamic>))
            .toList(),
        chores: (json['chores'] as List<dynamic>? ?? [])
            .map((e) => Chore.fromJson(e as Map<String, dynamic>))
            .toList(),
        preferences: json['preferences'] == null
            ? Preferences.defaults()
            : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
      );
}
