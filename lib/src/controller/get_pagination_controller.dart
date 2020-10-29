import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetPaginationController<T> implements PaginationBase<T> {
  bool finishPage = false;

  int page = 1;
  int pageSearch = 1;

  int numItemsPage = 0;

  var listFull = <T>[];
  bool oneMoreListFullPage = false;

  final Rx<AsyncSnapshotScrollPage<T>> _snapshotScroolPage =
      AsyncSnapshotScrollPage<T>.nothing().obs;

  AsyncSnapshotScrollPage<T> get snapshotScroolPage =>
      _snapshotScroolPage.value;

  List<T> get data => snapshotScroolPage.snapshot.data;

  set snapshotScroolPage(AsyncSnapshotScrollPage<T> value) =>
      _snapshotScroolPage.value = value;

  void handleDataFullList(
      {@required List<T> listData,
      @required bool scroollEndPage,
      @required VoidCallback newPageFuture}) {
    if (scroollEndPage) {
      togleLoadinglistFullScroll();
    }

    if (listData == null) {
      oneMoreListFullPage = false;
      refazFutureListFull();

      handleListEmpty();
    } else if (listData.isEmpty) {
      oneMoreListFullPage = false;

      if (numItemsPage == 0) {
        withError(Exception('First return cannot have zero elements. 😢'));
        //return;
      }
      finishPage = true;
    } else if (listData.length < 15 && numItemsPage == 0) {
      oneMoreListFullPage = false;

      withError(Exception(
          'First return cannot be a list of less than 15 elements. 😢'));
      //return;
    } else if (listData.length - numItemsPage < 0) {
      oneMoreListFullPage = false;

      wrapListFull(listData);

      finishPage = true;

      withData(listFull);
    } else if (listData.length - numItemsPage > 0 && numItemsPage != 0) {
      oneMoreListFullPage = false;

      withError(Exception(
          'It must return at most or number of elements on a page. 😢'));
    } else {
      if (numItemsPage == 0) {
        numItemsPage = listData.length;
      }

      if (oneMoreListFullPage) {
        final num = (page - 1) * numItemsPage;

        listFull.removeRange(num, listFull.length);
        listFull.addAll(listData);
        page++;
        oneMoreListFullPage = false;
        newPageFuture();
      } else {
        wrapListFull(listData);

        withData(listFull);
      }
    }
  }

  void handleListEmpty() {
    if (listFull.isNotEmpty) {
      withData(listFull);
    } else
      withError(Exception('It cannot return null. 😢'));
    //snapshotScroolPage =
    //snapshotScroolPage.withError(Exception('It cannot return null. 😢'));
  }

  void refazFutureListFull() {
    if (snapshotScroolPage.loadinglistFullScroll) {
      page--;
    }
  }

  void wrapListFull(List<T> listData) {
    listFull.addAll(listData);
  }

  FutureOr onClose() {
    _snapshotScroolPage.close();
  }

  @override
  void inState() =>
      snapshotScroolPage = snapshotScroolPage.inState(ConnectionState.none);

  @override
  void waiting() => snapshotScroolPage = AsyncSnapshotScrollPage<T>.waiting();

  @override
  void withData(List<T> data) =>
      snapshotScroolPage = snapshotScroolPage.withData(data);

  @override
  void withError(Object error) =>
      snapshotScroolPage = snapshotScroolPage.withError(error);

  @override
  void togleLoadinglistFullScroll() =>
      snapshotScroolPage = snapshotScroolPage.togleLoadinglistFullScroll();
}

@immutable
class AsyncSnapshotScrollPage<T> {
  final AsyncSnapshot<List<T>> snapshot;

  final bool loadinglistFullScroll;

  const AsyncSnapshotScrollPage._(this.snapshot,
      {this.loadinglistFullScroll = false})
      // para demais ter corpo também
      : assert(snapshot != null);

  const AsyncSnapshotScrollPage.waiting()
      : this._(const AsyncSnapshot.waiting());

  const AsyncSnapshotScrollPage.nothing()
      : this._(const AsyncSnapshot.nothing());

  AsyncSnapshotScrollPage<T> inState(ConnectionState state) =>
      AsyncSnapshotScrollPage<T>._(snapshot.inState(state));

  AsyncSnapshotScrollPage<T> withData(List<T> data) =>
      AsyncSnapshotScrollPage<T>._(
          AsyncSnapshot.withData(ConnectionState.done, data));

  AsyncSnapshotScrollPage<T> withError(Object error) =>
      AsyncSnapshotScrollPage<T>._(
          AsyncSnapshot.withError(ConnectionState.done, error));

  AsyncSnapshotScrollPage<T> togleLoadinglistFullScroll() =>
      AsyncSnapshotScrollPage<T>._(snapshot.inState(ConnectionState.done),
          loadinglistFullScroll: !loadinglistFullScroll);
}

class ListSearchBuild<T> {
  List<T> listSearch;
  bool isListSearchFull;

  ListSearchBuild({this.listSearch, this.isListSearchFull = false});
}

mixin PaginationBase<T> {
  void inState();

  void waiting();

  void withData(List<T> data);

  void withError(Object error);

  void togleLoadinglistFullScroll();
}
