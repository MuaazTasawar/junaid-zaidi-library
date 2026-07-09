import 'package:equatable/equatable.dart';

/// Maps to Koha's `/api/v1/holds` resource.
///
/// `status`: Koha hold statuses — commonly 'W' (waiting/ready for
/// pickup) or 'T'/'pending' style in-queue states. LibConnect treats
/// any status of `'W'` as "ready for pickup" (HoldsScreen top
/// section) and everything else as "in queue" (bottom section, uses
/// [priority] for the "#N in queue" badge).
class Hold extends Equatable {
  const Hold({
    required this.holdId,
    required this.patronId,
    required this.biblioId,
    required this.status,
    required this.priority,
    required this.waitingdate,
    required this.expirationdate,
  });

  final int holdId;
  final int patronId;
  final int biblioId;
  final String status;
  final int priority;
  final DateTime? waitingdate;
  final DateTime? expirationdate;

  bool get isReadyForPickup => status == 'W';

  factory Hold.fromJson(Map<String, dynamic> json) {
    return Hold(
      holdId: json['hold_id'] as int,
      patronId: json['patron_id'] as int,
      biblioId: json['biblio_id'] as int,
      status: json['status'] as String,
      priority: json['priority'] as int? ?? 0,
      waitingdate: json['waitingdate'] != null
          ? DateTime.parse(json['waitingdate'] as String)
          : null,
      expirationdate: json['expirationdate'] != null
          ? DateTime.parse(json['expirationdate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hold_id': holdId,
      'patron_id': patronId,
      'biblio_id': biblioId,
      'status': status,
      'priority': priority,
      'waitingdate': waitingdate?.toIso8601String(),
      'expirationdate': expirationdate?.toIso8601String(),
    };
  }

  Hold copyWith({
    int? holdId,
    int? patronId,
    int? biblioId,
    String? status,
    int? priority,
    DateTime? waitingdate,
    DateTime? expirationdate,
  }) {
    return Hold(
      holdId: holdId ?? this.holdId,
      patronId: patronId ?? this.patronId,
      biblioId: biblioId ?? this.biblioId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      waitingdate: waitingdate ?? this.waitingdate,
      expirationdate: expirationdate ?? this.expirationdate,
    );
  }

  @override
  List<Object?> get props => [
    holdId,
    patronId,
    biblioId,
    status,
    priority,
    waitingdate,
    expirationdate,
  ];
}