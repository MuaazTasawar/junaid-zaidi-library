import 'package:equatable/equatable.dart';

import '../../data/models/biblio.dart';
import '../../data/models/item.dart';

enum SearchStatus { idle, loading, loaded, error }
enum DetailStatus { idle, loading, loaded, error }
enum ScanStatus { idle, scanning, found, notFound }
enum SortOption { relevance, titleAsc, newest }

class CatalogState extends Equatable {
  const CatalogState({
    this.recentSearches = const [],
    this.popularBiblios = const [],
    this.searchStatus = SearchStatus.idle,
    this.query = '',
    this.results = const [],
    this.sortOption = SortOption.relevance,
    this.searchErrorMessage,
    this.detailStatus = DetailStatus.idle,
    this.selectedBiblio,
    this.selectedItems = const [],
    this.detailErrorMessage,
    this.relatedBiblios = const [],
    this.bookmarkedBiblioIds = const {},
    this.isPlacingHold = false,
    this.holdSuccess = false,
    this.holdErrorMessage,
    this.subjectBrowseStatus = SearchStatus.idle,
    this.subjectBrowseResults = const [],
    this.subjectBrowseErrorMessage,
    this.scanStatus = ScanStatus.idle,
    this.scannedItem,
    this.scannedBiblio,
    this.scanErrorMessage,
  });

  final List<String> recentSearches;
  final List<Biblio> popularBiblios;

  final SearchStatus searchStatus;
  final String query;
  final List<Biblio> results;
  final SortOption sortOption;
  final String? searchErrorMessage;

  final DetailStatus detailStatus;
  final Biblio? selectedBiblio;
  final List<Item> selectedItems;
  final String? detailErrorMessage;
  final List<Biblio> relatedBiblios;

  final Set<int> bookmarkedBiblioIds;

  final bool isPlacingHold;
  final bool holdSuccess;
  final String? holdErrorMessage;

  final SearchStatus subjectBrowseStatus;
  final List<Biblio> subjectBrowseResults;
  final String? subjectBrowseErrorMessage;

  final ScanStatus scanStatus;
  final Item? scannedItem;
  final Biblio? scannedBiblio;
  final String? scanErrorMessage;

  int get availableCopiesForSelected =>
      selectedItems.where((i) => i.isAvailable).length;

  CatalogState copyWith({
    List<String>? recentSearches,
    List<Biblio>? popularBiblios,
    SearchStatus? searchStatus,
    String? query,
    List<Biblio>? results,
    SortOption? sortOption,
    String? searchErrorMessage,
    bool clearSearchError = false,
    DetailStatus? detailStatus,
    Biblio? selectedBiblio,
    List<Item>? selectedItems,
    String? detailErrorMessage,
    bool clearDetailError = false,
    List<Biblio>? relatedBiblios,
    Set<int>? bookmarkedBiblioIds,
    bool? isPlacingHold,
    bool? holdSuccess,
    String? holdErrorMessage,
    bool clearHoldError = false,
    SearchStatus? subjectBrowseStatus,
    List<Biblio>? subjectBrowseResults,
    String? subjectBrowseErrorMessage,
    ScanStatus? scanStatus,
    Item? scannedItem,
    Biblio? scannedBiblio,
    String? scanErrorMessage,
    bool clearScanError = false,
  }) {
    return CatalogState(
      recentSearches: recentSearches ?? this.recentSearches,
      popularBiblios: popularBiblios ?? this.popularBiblios,
      searchStatus: searchStatus ?? this.searchStatus,
      query: query ?? this.query,
      results: results ?? this.results,
      sortOption: sortOption ?? this.sortOption,
      searchErrorMessage:
      clearSearchError ? null : (searchErrorMessage ?? this.searchErrorMessage),
      detailStatus: detailStatus ?? this.detailStatus,
      selectedBiblio: selectedBiblio ?? this.selectedBiblio,
      selectedItems: selectedItems ?? this.selectedItems,
      detailErrorMessage:
      clearDetailError ? null : (detailErrorMessage ?? this.detailErrorMessage),
      relatedBiblios: relatedBiblios ?? this.relatedBiblios,
      bookmarkedBiblioIds: bookmarkedBiblioIds ?? this.bookmarkedBiblioIds,
      isPlacingHold: isPlacingHold ?? this.isPlacingHold,
      holdSuccess: holdSuccess ?? this.holdSuccess,
      holdErrorMessage: clearHoldError ? null : (holdErrorMessage ?? this.holdErrorMessage),
      subjectBrowseStatus: subjectBrowseStatus ?? this.subjectBrowseStatus,
      subjectBrowseResults: subjectBrowseResults ?? this.subjectBrowseResults,
      subjectBrowseErrorMessage: subjectBrowseErrorMessage ?? this.subjectBrowseErrorMessage,
      scanStatus: scanStatus ?? this.scanStatus,
      scannedItem: scannedItem ?? this.scannedItem,
      scannedBiblio: scannedBiblio ?? this.scannedBiblio,
      scanErrorMessage: clearScanError ? null : (scanErrorMessage ?? this.scanErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    recentSearches,
    popularBiblios,
    searchStatus,
    query,
    results,
    sortOption,
    searchErrorMessage,
    detailStatus,
    selectedBiblio,
    selectedItems,
    detailErrorMessage,
    relatedBiblios,
    bookmarkedBiblioIds,
    isPlacingHold,
    holdSuccess,
    holdErrorMessage,
    subjectBrowseStatus,
    subjectBrowseResults,
    subjectBrowseErrorMessage,
    scanStatus,
    scannedItem,
    scannedBiblio,
    scanErrorMessage,
  ];
}