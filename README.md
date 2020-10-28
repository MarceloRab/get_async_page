# get_async_page

A reactive page in GetX from a stream without the need to create a controller.

## Introduction

Would you like to have a reactive page with just your stream? Built with GetX, this widget offers 
this facility. You can add reactive resettables to rebuild your body as well. Like a change in auth. 
Errors, connectivity and standby widgets are configured in default mode. Change them if you wish. 
Check the example.

## Tips

The function [obxWidgetBuilder] is inside an Obx. Place reactive verables into it.

##### ✳️ There are two ways to add reactive variables.
1 ) Boot your controller into a StatefulWidget.<p>
1.2 - Pass the reactive variable get inside this function.
-----
2 ) Add the parameters to this list. It doesn't have to be a StatefulWidget.<p>
2.2 - Collect the reactive variable with .value => (So much for Rx or RxList).
-----
1 ) => for StatefulWidget
<p>
2 ) => for StatelessWidget, StatefulWidget 
or pass GetStreamPage directly.

#### Example
- Using the pages with details. <p>
[Full Example](https://api.pub.dev/packages/get_stream_page/example) for more details.

------
Any change in the variables will reassemble the body of your page. As in the example below. In the 
case below, there would be 03 ways to reconstruct the screen: the stream flow, rxAuth and rxList changes.
------
#### GetStreamPage

There is already a Scaffold waiting for the parameters. Quick example.
```dart
class TestGetStreamPage extends StatefulWidget {
  @override
  _TestGetStreamPageState createState() => _TestGetStreamPageState();
}

class _TestGetStreamPageState extends State<TestGetStreamPage> {
  Test2Controller controll_1;

  @override
  void initState() {
    /// ## ✳️ There are two ways to add reactive variables.
    ///-------------------------------------------------------------------
    /// ✅ 1) Boot your controller into a StatefulWidget.
    ///-------------------------------------------------------------------
    controll_1 = Get.find<Test2Controller>();
    super.initState();

    Future.delayed(const Duration(seconds: 10), () {
      ///------------------------------------------
      /// Test to check the reactivity of the screen.
      ///------------------------------------------
      /// 1) 👇🏼
      controll_1.changeAuth = true;
    });

    Future.delayed(const Duration(seconds: 15), () {
      ///------------------------------------------
      /// Test to check the reactivity of the screen.
      ///------------------------------------------
      /// 2) 👇🏼
      Get.find<Test2Controller>().rxList.addAll(dataListPerson);
    });
  }

  @override
    Widget build(BuildContext context) {
      return GetStreamPage<List<Person>>(
        title: Text(
          'Stream Page',
          style: TextStyle(fontSize: 18),
        ),
        stream: streamListPerson,
        listRx: [
          ///-------------------------------------------------------------------
          /// ✅ 2) Add the parameters to this list. No need
          ///  be a StatefulWidget. You can directly pass GetStreamPage.
          ///-------------------------------------------------------------------
          RxItem.input(Get.find<Test2Controller>().rxAuth, 'auth'),
          RxItem.input(Get.find<Test2Controller>().rxList, 'list_user'),
          RxItem.input(Get.find<Test3Controller>().rx_2, 'inter')
        ],
        widgetBuilder: (context, objesctStream, rxSet) {
          // ☑️ This function is inside an Obx. Place reactive verables into it.
          ///---------------------------------------------------------------
          /// 2.2) Collect the reactive variable with .value => (Rx or RxList)
          ///---------------------------------------------------------------
          /// Examples
          print(' TEST -- ${rxSet.getRx('auth').value.toString()} ');
          print(' TEST -- ${rxSet.getRx('list_user').value.length.toString()} ');
  
          ///-------------------------------------------------------------
          /// 1.2) Or pass the reactive variable get inside this function.
          ///-------------------------------------------------------------
          print(' TEST -- ${controll_1.isAuth.toString()} ');
  
          /// 1)
          if (!controll_1.isAuth) {
            /// Or 2) 👇🏼
            //if (!rxSet.getRx('auth').value) {
            return Center(
              child: Text(
                'Please login.',
                style: TextStyle(fontSize: 22),
              ),
            );
          }
  
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
      );
    }
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
##### If you want to build your body independently, use ```[GetStreamWidget]```.
[Full Example](https://api.pub.dev/packages/get_stream_page/example) for more details.



A new Flutter package project.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
