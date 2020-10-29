import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get_async_page/get_async_page.dart';
import 'package:get_async_page/src/controller/connecty_controller.dart';
import 'package:get_async_page/src/controller/get_pagination_controller.dart';
import 'package:get_async_page/src/ui/widgets/connecty_widget.dart';

class GetPaginationPage<T> extends StatefulWidget {
  /// [initialData] List to be initialData.
  /// These widgets will not be displayed. [widgetOffConnectyWaiting] and
  /// [widgetWaiting]
  final List<T> initialData;

  ///[futureFetchPageItems] Return the list in parts or parts by query String
  ///filtered. We make the necessary changes on the device side to update the
  ///page to be requested. Eg: If numItemsPage = 6 and you receive 05 or 11
  ///or send empty, = >>> it means that the data is over.
  final FutureFetchPageItems<T> futureFetchPageItems;

  /// [numItemsPage] Automatically calculated when receiving the first data.
  /// If it has [initialData] it cannot be null.
  final int numItemsPage;

  /// [widgetErrorBuilder] Widget built by the Object error returned by the
  /// [futureFetchPageItems] error.
  final WidgetsErrorBuilder widgetErrorBuilder;

  /// [obxWidgetItemBuilder] Returns Widget from the object (<T>).
  /// This comes from the List <T> index.
  /// typedef WidgetsPaginationItemBuilder<T> = Widget Function(
  ///BuildContext context, int index, T objectIndex);

  final WidgetsPaginationItemBuilder<T> obxWidgetItemBuilder;

  /// [widgetOffConnectyWaiting] Only shows something when it is disconnected
  /// and still doesn't have the first value in the stream. If the connection
  /// comes back starts showing [widgetWaiting] until it shows the first data
  final Widget widgetWaiting;
  final Widget widgetOffConnectyWaiting;

  /// [widgetEndScrollPage] shown when the end of the page arrives and
  /// awaits the Future of the data on the next page
  final Widget widgetEndScrollPage;

  /// [floatingActionButton] , [pageDrawer] ,
  /// [floatingActionButtonLocation] ,
  /// [floatingActionButtonAnimator]  ...
  /// are passed on to the Scaffold.
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final FloatingActionButtonAnimator floatingActionButtonAnimator;
  final List<Widget> persistentFooterButtons;
  final Widget pageDrawer;
  final Widget pageEndDrawer;
  final Widget pageBottomNavigationBar;
  final Widget pageBottomSheet;
  final Color pageBackgroundColor;
  final bool resizeToAvoidBottomPadding;
  final bool resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color drawerScrimColor;
  final double drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;

  ///AppBar parameters
  ///
  final Color appBarbackgroundColor;
  final Widget title;
  final bool centerTitle;
  final IconThemeData iconTheme;
  final double elevation;
  final List<Widget> actions;

  /// [iconConnectyOffAppBar] Displayed on the AppBar when the internet
  /// connection is switched off.
  /// It is always the closest to the center.
  final Widget iconConnectyOffAppBar;
  final Color iconConnectyOffAppBarColor;

  ///[iconConnectyOffAppBar] Appears when the connection status is off.
  ///There is already a default icon. If you don't want to present a choice
  ///[hideDefaultConnectyIconOffAppBar] = true; If you want to have a
  ///custom icon, do [hideDefaultConnectyIconOffAppBar] = true; and set the
  ///[iconConnectyOffAppBar]`.
  final bool hideDefaultConnectyIconOffAppBar;

  ///  [rxBoolAuth] Insert your RxBool here that changes with the auth
  /// status to have reactivity.
  final RxBoolAuth rxBoolAuth;

  const GetPaginationPage(
      {Key key,
      @required this.futureFetchPageItems,
      @required this.obxWidgetItemBuilder,
      this.numItemsPage,
      this.widgetErrorBuilder,
      this.widgetWaiting,
      this.widgetOffConnectyWaiting,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.floatingActionButtonAnimator,
      this.persistentFooterButtons,
      this.pageDrawer,
      this.pageEndDrawer,
      this.pageBottomNavigationBar,
      this.pageBottomSheet,
      this.pageBackgroundColor,
      this.resizeToAvoidBottomPadding,
      this.resizeToAvoidBottomInset,
      this.primary = true,
      this.drawerDragStartBehavior = DragStartBehavior.start,
      this.extendBody = false,
      this.extendBodyBehindAppBar = false,
      this.drawerScrimColor,
      this.drawerEdgeDragWidth,
      this.drawerEnableOpenDragGesture = true,
      this.endDrawerEnableOpenDragGesture = true,
      this.appBarbackgroundColor,
      this.title,
      this.centerTitle = false,
      this.elevation = 4.0,
      this.actions = const <Widget>[],
      this.iconTheme,
      this.iconConnectyOffAppBar,
      this.hideDefaultConnectyIconOffAppBar = false,
      this.initialData,
      this.rxBoolAuth,
      this.iconConnectyOffAppBarColor,
      this.widgetEndScrollPage})
      : super(key: key);

  @override
  _GetPaginationPageState<T> createState() => _GetPaginationPageState<T>();
}

class _GetPaginationPageState<T> extends State<GetPaginationPage<T>> {
  final String className = '_ _SearchAppBarPaginationState ___ ...  ';
  Object _activeListFullCallbackIdentity;
  ConnectController _connectyController;
  StreamSubscription _subscriptionConnecty;

  bool downConnectyWithoutData = false;

  Widget _widgetConnecty;

  ScrollController _scrollController;

  Widget _widgetWaiting;

  Widget _widgetNothingFound;
  Widget _widgetEndScrollPage;

  Widget _iconConnectyOffAppBar;

  GetPaginationController<T> _controller;

  bool _haveInitialData;

  @override
  void initState() {
    if (widget.numItemsPage != null && widget.numItemsPage < 15) {
      throw Exception('The minimum value for the number of elements is 15.');
    }

    if (widget.initialData != null && widget.numItemsPage == null) {
      throw Exception(
          'It is necessary to pass the number of items per page so that '
          'can calculate the home page');
    }
    super.initState();

    _controller = GetPaginationController();
    _scrollController = ScrollController();
    _scrollController.addListener(pagesListener);

    _haveInitialData = widget.initialData != null;
    if (_haveInitialData) {
      if (_controller.numItemsPage != 0) {
        _controller.page =
            (widget.initialData.length / widget.numItemsPage).ceil();
      }

      _controller.listFull.addAll(widget.initialData);
      _controller.withData(widget.initialData);
    } else {
      _connectyController = ConnectController();
      _subscribeConnecty();
    }
    _buildwidgetConnecty();
    _buildWidgetsDefault();
    _futurePageSubscribe();
  }

  @override
  void dispose() {
    _unsubscribeListFullCallBack();
    _controller.onClose();
    _scrollController.removeListener(pagesListener);
    _scrollController.dispose();
    _unsubscribeConnecty();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GetPaginationPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialData != widget.initialData) {
      if (widget.initialData != null && widget.numItemsPage == null) {
        throw Exception(
            'It is necessary to pass the number of items per page so that '
            'can calculate the home page.');
      } else {
        _haveInitialData = widget.initialData != null;

        if (_haveInitialData) {
          if (downConnectyWithoutData) {
            downConnectyWithoutData = false;
            _unsubscribeConnecty();
          }
          if (widget.initialData.length > _controller.listFull.length) {
            _unsubscribeListFullCallBack();
            if (_controller.numItemsPage != 0) {
              _controller.page =
                  (widget.initialData.length / widget.numItemsPage).ceil();
            }

            _controller.listFull.clear();
            _controller.listFull.addAll(widget.initialData);
            _controller.withData(_controller.listFull);
          }
        }
      }
    }

    if (_controller.listFull.isEmpty) {
      if (oldWidget.futureFetchPageItems != widget.futureFetchPageItems) {
        if (_activeListFullCallbackIdentity != null) {
          _unsubscribeListFullCallBack();

          _controller.inState();
        }

        _futurePageSubscribe();
      }
    }
  }

  void pagesListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 3 &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      if (!_controller.finishPage) {
        if (!_controller.snapshotScroolPage.loadinglistFullScroll) {
          if (_controller.listFull.length -
                  (_controller.page * _controller.numItemsPage) ==
              0) {
            _controller.page++;
          } else {
            _controller.oneMoreListFullPage = true;
          }
          if (_activeListFullCallbackIdentity != null) {
            _unsubscribeListFullCallBack();
          }
          _controller.togleLoadinglistFullScroll();
          // nao recebe pagina quebrada atá acabar os dados
          _futurePageSubscribe(scroollEndPage: true);
        }
      }
    }
  }

  void _futurePageSubscribe({bool scroollEndPage = false}) {
    final Object callbackIdentity = Object();
    _activeListFullCallbackIdentity = callbackIdentity;
    widget.futureFetchPageItems(_controller.page).then<void>((List<T> data) {
      if (_activeListFullCallbackIdentity == callbackIdentity) {
        if (data != null) {
          if (downConnectyWithoutData) {
            downConnectyWithoutData = false;
            _unsubscribeConnecty();
          }

          _controller.handleDataFullList(
              listData: data,
              scroollEndPage: scroollEndPage,
              newPageFuture: () {
                _futurePageSubscribe(scroollEndPage: true);
              });
        }
      }
    }, onError: (Object error) {
      if (_activeListFullCallbackIdentity == callbackIdentity) {
        _controller.oneMoreListFullPage = false;
        _controller.refazFutureListFull();

        _controller.withError(error);
      }
    });

    if (!scroollEndPage) {
      _controller.waiting();
    }
  }

  void _buildwidgetConnecty() {
    if (widget.iconConnectyOffAppBar == null &&
        !widget.hideDefaultConnectyIconOffAppBar) {
      _iconConnectyOffAppBar = ConnectyWidget(
        color: widget.iconConnectyOffAppBarColor,
      );
    } else if (widget.hideDefaultConnectyIconOffAppBar) {
      if (widget.iconConnectyOffAppBar != null) {
        _iconConnectyOffAppBar = widget.iconConnectyOffAppBar;
      }
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    final increasedActions = <Widget>[];
    increasedActions.addAll(widget.actions);

    if (_iconConnectyOffAppBar != null) {
      increasedActions.insert(0, _iconConnectyOffAppBar);
    }

    return AppBar(
      backgroundColor:
          widget.appBarbackgroundColor ?? Theme.of(context).appBarTheme.color,
      iconTheme: widget.iconTheme ?? Theme.of(context).appBarTheme.iconTheme,
      title: widget.title,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      actions: increasedActions,
    );
  }

  Widget buildBody() {
    if (downConnectyWithoutData) {
      // Apenas anuncia quando nao tem a primeira data e esta sem conexao
      return _widgetConnecty;
    }

    return Obx(() {
      if (widget.rxBoolAuth?.auth?.value == false) {
        return widget.rxBoolAuth.authFalseWidget();
      }
      if (_controller.snapshotScroolPage.snapshot.connectionState ==
          ConnectionState.waiting) {
        return _widgetWaiting;
      }

      if (_controller.snapshotScroolPage.snapshot.hasError) {
        return buildwidgetError(_controller.snapshotScroolPage.snapshot.error);
      }

      if (_controller.data.isEmpty) {
        return _widgetNothingFound;
      }
      return ListView.builder(
        controller: _scrollController,
        itemCount: (_controller.snapshotScroolPage.loadinglistFullScroll)
            ? _controller.data.length + 1
            : _controller.data.length,
        itemBuilder: (ctx, index) {
          if (index == _controller.data.length) {
            return _widgetEndScrollPage;
          }

          return widget.obxWidgetItemBuilder(
              context, index, _controller.data[index]);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        body: buildBody(),
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
        persistentFooterButtons: widget.persistentFooterButtons,
        drawer: widget.pageDrawer,
        endDrawer: widget.pageEndDrawer,
        bottomNavigationBar: widget.pageBottomNavigationBar,
        bottomSheet: widget.pageBottomSheet,
        backgroundColor: widget.pageBackgroundColor,
        resizeToAvoidBottomPadding: widget.resizeToAvoidBottomPadding,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary,
        drawerDragStartBehavior: widget.drawerDragStartBehavior,
        extendBody: widget.extendBody,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawerScrimColor: widget.drawerScrimColor,
        drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture);
  }

  void _unsubscribeListFullCallBack() {
    _activeListFullCallbackIdentity = null;
  }

  void _unsubscribeConnecty() {
    if (_subscriptionConnecty != null) {
      _subscriptionConnecty.cancel();
      _subscriptionConnecty = null;
      _connectyController.onClose();
    }
  }

  void _subscribeConnecty() {
    _subscriptionConnecty =
        _connectyController.connectStream.listen((bool isConnected) {
      if (!isConnected && (!_haveInitialData)) {
        setState(() {
          downConnectyWithoutData = true;
        });
      } else if (isConnected && (!_haveInitialData)) {
        _controller.waiting();
      }
    });
  }

  Widget buildwidgetError(Object error) {
    if (widget.widgetErrorBuilder == null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'We found an error.\n'
                  'Error: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ]);
    } else {
      return widget.widgetErrorBuilder(error);
    }

    //return _widgetError;
  }

  Widget buildWidgetError(Object error) {
    if (widget.widgetErrorBuilder == null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'We found an error.\n'
                  'Error: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ]);
    } else {
      return widget.widgetErrorBuilder(error);
    }

    //return _widgetError;
  }

  void _buildWidgetsDefault() {
    if (widget.widgetOffConnectyWaiting == null) {
      _widgetConnecty = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Check connection...',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      );
    } else {
      _widgetConnecty = widget.widgetOffConnectyWaiting;
    }
    if (widget.widgetWaiting == null) {
      _widgetWaiting = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      _widgetWaiting = widget.widgetWaiting;
    }

    if (widget.widgetEndScrollPage == null) {
      _widgetEndScrollPage = Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, top: 10),
          width: 30,
          height: 30,
          child: const CircularProgressIndicator(),
        ),
      );
    } else {
      _widgetEndScrollPage = widget.widgetEndScrollPage;
    }
  }
}
