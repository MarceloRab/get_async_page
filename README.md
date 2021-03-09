# get_async_page

A reactive page on GetX in a super simple way from your stream or future to pagnination.

## Introduction

* This package has been depreciated. It has been merged into the package
  [search_app_bar_page](https://pub.dev/packages/search_app_bar_page). There are other features in 
  this and it is being transferred to null-safety.

Would you like to have a reactive page with just your stream or a pagination only with its function of collecting the page? Built with GetX, this widget offers
this facility. You can also add reactive parameters to rebuild your body. Like a change in authentication.
Errors, connectivity and standby widgets are configured in standard mode. Change them if desired.
See the example.

## Tips

The function [obxWidgetBuilder] is inside an Obx. Place reactive verables into it.

##### ✳️ There are two ways to add reactive variables.

* Boot your controller into a StatefulWidget. <p>
- Pass the reactive variable inside this function ```[obxWidgetBuilder]``` in GetStreamPage and GetStreamWidget. <p>
Note: In GetPaginationPage use only the parameter ```[rxBoolAuth]``` for reactivity of another reactive variable.
-----
* Add reactive authentication parameters. Insert your RxBool that changes with the authentication status to
reactivity. The body will be rebuilt when authentication is false.
Set ```[rxBoolAuth]``` to GetStreamPage and GetPaginationPage.

#### Example
- Using the pages with details. <p>
[Full Example](https://api.pub.dev/packages/get_async_page/example) for more details.

------

Any changes in reactive variables will reassemble the body of your page.

------
#### ✷ GetStreamPage

There is already a Scaffold waiting for the parameters.
```dart
class TestGetStreamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.find<Test2Controller>().changeAuth = false;
        Get.find<Test2Controller>().rxList.clear();
        return Future.value(true);
      },
      child: GetStreamPage<List<Person>>(
        title: Text(
          'Stream Page',
          style: TextStyle(fontSize: 18),
        ),
        stream: streamListPerson,

        ///--------------------------------------------
        /// ✅ Add RxBool auth and build the widget if it is false.
        ///---------------------------------------------
        rxBoolAuth: RxBoolAuth.input(
            rxBoolAuthm: Get.find<Test2Controller>().rxAuth,
            authFalseWidget: () => Center(
                  child: Text(
                    'Please login.',
                    style: TextStyle(fontSize: 22),
                  ),
                )),
        obxWidgetBuilder: (context, objesctStream) {
          ///------------------------------------------
          /// Build your body from the stream data.
          ///------------------------------------------
          final list = objesctStream;
          if (list.isEmpty) {
            return Center(
                child: Text(
              'NOTHING FOUND',
              style: TextStyle(fontSize: 14),
            ));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Name: ${list[index].name}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  // ignore: lines_longer_than_80_chars
                                  'Age: ${list[index].age.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                            ],
                          ),
                        ));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Stream<List<Person>> streamListPerson = (() async* {
    await Future<void>.delayed(Duration(seconds: 3));
    //yield null;
    yield dataListPerson;
    await Future<void>.delayed(Duration(seconds: 4));
    yield dataListPerson2;
    await Future<void>.delayed(Duration(seconds: 5));
    //throw Exception('Erro voluntario');
    yield dataListPerson3;
  })();
}

class Test2Controller extends GetxController {
  final rxAuth = false.obs;

  set changeAuth(bool value) => rxAuth.value = value;

  get isAuth => rxAuth.value;

  final rxList = <Person>[].obs;
}

class Test3Controller extends GetxController {
  final rx_2 = ''.obs;

  set rx_2(value) => rx_2.value = value;
}

class Person {
  final String name;

  final int age;

  Person({this.name, this.age});

  @override
  String toString() {
    return 'Person{name: $name, age: $age}';
  }
}
```

#### ✷ GetPaginationPage

```dart
class TestePaginationPage extends StatefulWidget {
  @override
  _TestePaginationPageState createState() => _TestePaginationPageState();
}

class _TestePaginationPageState extends State<TestePaginationPage> {
  Dio _dio;

  Future<List<Person>> _futureList(int page) async {
    final response =
        await _dio.get('/users', queryParameters: {'page': page, 'limit': 15});

    return (response.data as List)
        .map((element) => Person.fromMap(element))
        .toList();
  }

  @override
  void initState() {
    _dio = Dio(
        BaseOptions(baseUrl: 'https://5f988a5242706e001695875d.mockapi.io'));
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      ///------------------------------------------
      /// Test to check the reactivity of the screen.
      ///------------------------------------------

      if (!Get.find<Test2Controller>().isAuth) {
        Get.find<Test2Controller>().changeAuth = true;
      }
    });
  }

  @override
  void dispose() {
    Get.find<Test2Controller>().changeAuth = false;
    Get.find<Test2Controller>().rxList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetPaginationPage<Person>(
      title: Text(
        'Stream Page',
        style: TextStyle(fontSize: 18),
      ),

      ///--------------------------------------------
      /// ✅ Just configure your future function here.
      ///---------------------------------------------
      futureFetchPageItems: _futureList,

      ///--------------------------------------------
      /// ✅ Add RxBool auth and build the widget if it is false.
      ///---------------------------------------------
      rxBoolAuth: RxBoolAuth.input(
          rxBoolAuthm: Get.find<Test2Controller>().rxAuth,
          authFalseWidget: () => Center(
                child: Text(
                  'Please login.',
                  style: TextStyle(fontSize: 22),
                ),
              )),
      obxWidgetItemBuilder: (context, index, objectIndex) {
        ///------------------------------------------
        /// Build your body from the future data.
        ///------------------------------------------

        return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                title: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(50),
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: NetworkImage(
                        '${objectIndex.avatar}',
                      ),
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${objectIndex.name}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ));
      },
    );
  }
}
```
##### If you want to build your body independently, use ```[GetStreamWidget]```.
[Full Example](https://api.pub.dev/packages/get_async_page/example) for more details.

## Reactivity to the connection.

`[iconConnectyOffAppBar]` Appears when the connection status is off. There is already a default icon. 
If you don't want to present a choice `[hideDefaultConnectyIconOffAppBar]` = true; If you want to have a custom icon,
do `[hideDefaultConnectyIconOffAppBar]` = true; and set the `[iconConnectyOffAppBar]`.

`[widgetOffConnectyWaiting]` Only shows something when it is disconnected and does not yet have the 
first value of the stream. If the connection goes back to show the `[widgetWaiting]` until you 
receive the first data. Everyone already comes with They all come with default widgets.

Note: these images are from another package ( [search_app_bar_page](https://pub.dev/packages/search_app_bar_page) )
that have the same functions but with a SearchAppBar. The connection icon behaves the same way.

![20201007-203744-360x780](https://user-images.githubusercontent.com/41010018/95398660-c708c480-08dc-11eb-8b07-e0ffa816cbbc.gif)

