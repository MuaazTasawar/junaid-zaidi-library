import 'package:equatable/equatable.dart';

/// Maps 1:1 to Koha's `/api/v1/biblios/{biblio_id}` resource.
/// Field names are intentionally snake_case to match the Koha API
/// exactly (Golden Rule #6) rather than being Dart-idiomatic.
class Biblio extends Equatable {
  const Biblio({
    required this.biblioId,
    required this.title,
    required this.author,
    required this.edition,
    required this.isbn,
    required this.subject,
    required this.copyrightdate,
    required this.description,
  });

  final int biblioId;
  final String title;
  final String author;
  final String edition;
  final String isbn;
  final String subject;
  final int copyrightdate;
  final String description;

  factory Biblio.fromJson(Map<String, dynamic> json) {
    return Biblio(
      biblioId: json['biblio_id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      edition: json['edition'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
      subject: json['subject'] as String? ?? 'General',
      copyrightdate: json['copyrightdate'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'biblio_id': biblioId,
      'title': title,
      'author': author,
      'edition': edition,
      'isbn': isbn,
      'subject': subject,
      'copyrightdate': copyrightdate,
      'description': description,
    };
  }

  Biblio copyWith({
    int? biblioId,
    String? title,
    String? author,
    String? edition,
    String? isbn,
    String? subject,
    int? copyrightdate,
    String? description,
  }) {
    return Biblio(
      biblioId: biblioId ?? this.biblioId,
      title: title ?? this.title,
      author: author ?? this.author,
      edition: edition ?? this.edition,
      isbn: isbn ?? this.isbn,
      subject: subject ?? this.subject,
      copyrightdate: copyrightdate ?? this.copyrightdate,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    biblioId,
    title,
    author,
    edition,
    isbn,
    subject,
    copyrightdate,
    description,
  ];
}