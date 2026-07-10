import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../data/models/biblio.dart';
import '../../data/models/item.dart';
import '../../data/repositories/library_repository.dart';
import 'catalog_state.dart';

/// Owns catalog-wide state shared across Search, Search Results, Book
/// Detail, Subject Browse, and Scanner — registered as a singleton
/// (see Phase 9 architecture note) so navigating between these
/// screens doesn't reset in-progress search/detail/scan state.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState()) {
    _loadRecentSearches();
    _loadBookmarks();
    loadPopular();
  }

  final LibraryRepository _repository;

  static const String _searchBoxName = 'searchBox';
  static const String _recentSearchesKey = 'recentSearches';
  static const String _bookmarksBoxName = 'bookmarksBox';
  static const String _bookmarksKey = 'bookmarkedBiblioIds';
  static const int _maxRecentSearches = 10;

  // ── Recent searches ──────────────────────────────

  Future<void> _loadRecentSearches() async {
    final Box box = await Hive.openBox(_searchBoxName);
    final List<String> saved =
        (box.get(_recentSearchesKey) as List?)?.cast<String>() ?? [];
    emit(state.copyWith(recentSearches: saved));
  }

  Future<void> _addRecentSearch(String term) async {
    if (term.trim().isEmpty) return;
    final List<String> updated = [
      term,
      ...state.recentSearches.where((s) => s.toLowerCase() != term.toLowerCase()),
    ].take(_maxRecentSearches).toList();

    emit(state.copyWith(recentSearches: updated));

    final Box box = await Hive.openBox(_searchBoxName);
    await box.put(_recentSearchesKey, updated);
  }

  Future<void> loadPopular() async {
    try {
      final List<Biblio> all = await _repository.searchCatalog('');
      emit(state.copyWith(popularBiblios: all.take(6).toList()));
    } on LibraryException {
      // Popular strip is decorative; silently skip on failure.
    }
  }

  // ── Bookmarks ──────────────────────────────

  Future<void> _loadBookmarks() async {
    final Box box = await Hive.openBox(_bookmarksBoxName);
    final List<int> saved = (box.get(_bookmarksKey) as List?)?.cast<int>() ?? [];
    emit(state.copyWith(bookmarkedBiblioIds: saved.toSet()));
  }

  Future<void> toggleBookmark(int biblioId) async {
    final Set<int> updated = Set.of(state.bookmarkedBiblioIds);
    if (updated.contains(biblioId)) {
      updated.remove(biblioId);
    } else {
      updated.add(biblioId);
    }
    emit(state.copyWith(bookmarkedBiblioIds: updated));

    final Box box = await Hive.openBox(_bookmarksBoxName);
    await box.put(_bookmarksKey, updated.toList());
  }

  // ── Search ──────────────────────────────

  Future<void> search(String query) async {
    emit(state.copyWith(
      searchStatus: SearchStatus.loading,
      query: query,
      clearSearchError: true,
    ));

    try {
      final List<Biblio> results = await _repository.searchCatalog(query);
      emit(state.copyWith(
        searchStatus: SearchStatus.loaded,
        results: _applySort(results, state.sortOption),
      ));
      await _addRecentSearch(query);
    } on LibraryException catch (e) {
      emit(state.copyWith(searchStatus: SearchStatus.error, searchErrorMessage: e.message));
    }
  }

  void changeSortOption(SortOption option) {
    emit(state.copyWith(
      sortOption: option,
      results: _applySort(state.results, option),
    ));
  }

  List<Biblio> _applySort(List<Biblio> biblios, SortOption option) {
    final List<Biblio> sorted = List.of(biblios);
    switch (option) {
      case SortOption.titleAsc:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortOption.newest:
        sorted.sort((a, b) => b.copyrightdate.compareTo(a.copyrightdate));
      case SortOption.relevance:
        break; // preserve repository order
    }
    return sorted;
  }

  // ── Book detail ──────────────────────────────

  Future<void> loadBiblioDetail(int biblioId) async {
    emit(state.copyWith(detailStatus: DetailStatus.loading, clearDetailError: true));

    try {
      final Biblio biblio = await _repository.getBiblio(biblioId);
      final List<Item> items = await _repository.getItems(biblioId);
      final List<Biblio> sameSubject = await _repository.searchCatalog(biblio.subject);
      final List<Biblio> related =
      sameSubject.where((b) => b.biblioId != biblioId).take(5).toList();

      emit(state.copyWith(
        detailStatus: DetailStatus.loaded,
        selectedBiblio: biblio,
        selectedItems: items,
        relatedBiblios: related,
        holdSuccess: false,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(detailStatus: DetailStatus.error, detailErrorMessage: e.message));
    }
  }

  // ── Holds ──────────────────────────────

  Future<void> placeHold({required int patronId, required int biblioId}) async {
    emit(state.copyWith(isPlacingHold: true, clearHoldError: true));

    try {
      await _repository.placeHold(patronId: patronId, biblioId: biblioId);
      emit(state.copyWith(isPlacingHold: false, holdSuccess: true));
    } on LibraryException catch (e) {
      emit(state.copyWith(isPlacingHold: false, holdErrorMessage: e.message));
    }
  }

  void resetHoldFlow() {
    emit(state.copyWith(holdSuccess: false, clearHoldError: true));
  }

  // ── Subject browse ──────────────────────────────

  Future<void> browseSubject(String subject) async {
    emit(state.copyWith(subjectBrowseStatus: SearchStatus.loading));

    try {
      final List<Biblio> results = await _repository.searchCatalog(subject);
      emit(state.copyWith(
        subjectBrowseStatus: SearchStatus.loaded,
        subjectBrowseResults:
        results.where((b) => b.subject == subject).toList(),
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(
        subjectBrowseStatus: SearchStatus.error,
        subjectBrowseErrorMessage: e.message,
      ));
    }
  }

  // ── Scanner ──────────────────────────────

  Future<void> lookupBarcode(String barcode) async {
    emit(state.copyWith(scanStatus: ScanStatus.scanning, clearScanError: true));

    try {
      final List<Item> matches = await _repository.searchItems(barcode);
      if (matches.isEmpty) {
        emit(state.copyWith(scanStatus: ScanStatus.notFound));
        return;
      }

      final Item item = matches.first;
      final Biblio biblio = await _repository.getBiblio(item.biblioId);

      emit(state.copyWith(
        scanStatus: ScanStatus.found,
        scannedItem: item,
        scannedBiblio: biblio,
      ));
    } on LibraryException catch (e) {
      emit(state.copyWith(scanStatus: ScanStatus.notFound, scanErrorMessage: e.message));
    }
  }

  void resetScan() {
    emit(state.copyWith(scanStatus: ScanStatus.idle));
  }
}