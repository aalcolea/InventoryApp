import 'dart:async';
import 'dart:convert';
import '../../../themes/colors.dart';
import '../../utils/listenerBlurr.dart';
import '../forms/categoryForm.dart';
import '../../products/views/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;

import '../forms/editCategoryForm.dart';
class Categories extends StatefulWidget {
  final GlobalKey<ProductsState> productsKey;
  final void Function(
      bool,
      ) onHideBtnsBottom;
  final void Function(
      bool,
      ) onShowBlur;
  final Listenerblurr listenerblurr;

  const Categories({super.key, required this.onHideBtnsBottom, required this.onShowBlur, required this.productsKey, required this.listenerblurr});


  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  late StreamSubscription<bool> keyboardVisibilitySubscription;
  late KeyboardVisibilityController keyboardVisibilityController;
  bool visibleKeyboard = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String? _selectedCategory;
  late int selectedCategoryId;
  List<String> selectedCategories = [];
  bool isSelecting = false;
  final String baseURL = 'https://inventorioapp-ea98995372d9.herokuapp.com/api/categories'; //'http://192.168.101.140:8080/api/categories';
  bool hasMoreItems = true;
  String categoryName = '';
  String? categoryImage;
  bool isLoading = false;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
            widget.onHideBtnsBottom(visibleKeyboard);
          });
        });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void _clearSelectedCategory() {
    setState(() {
      _selectedCategory = null;
    });
  }

  void toggleSelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        if (selectedCategories.isEmpty) {
          isSelecting = false;
        }
      } else {
        selectedCategories.add(category);
        isSelecting = true;
      }
    });
    print("Selected Categories: $selectedCategories");
    print("Is Selecting: $isSelecting");
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    loadFirstItems();
    widget.listenerblurr.registrarObservador((newValue){

    });
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  ///test alan functiosn
  ///init tiene una function
  ///TODO ESTO IRA A UN SERVICIO
  int limit = 6;
  int offset = 0;
  List<Map<String, dynamic>> items = [];
  Future<void> loadFirstItems() async{
    try{
      setState(() {
        items.clear();
        offset = 0;
        hasMoreItems = true;
      });
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        items = fetchedItems;
        offset += limit;
        isLoading = false;
      });
      _ensureAddCatAtTheEnd();
    }catch(e){
      print('Error al cargar los items $e');
    }
  }
  Future<void> loadItems() async{
    if (!hasMoreItems) return;
    try{
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        isLoading = false;
        // Only add new items that don't already exist in the items list
        for (var newItem in fetchedItems) {
          bool exists = items.any((item) => item['id'] == newItem['id']);
          if (!exists) {
            items.add(newItem);
          }
        }

        if (fetchedItems.length < limit) {
          hasMoreItems = false; // No more items to load
        }
        offset += limit;
      });
      _ensureAddCatAtTheEnd();
      print(offset);
    }catch(e){
      print('Error al cargar mas productos $e');
    }
  }

  void _ensureAddCatAtTheEnd() {
    items.removeWhere((item) => item['category'] == 'addCat');
    for (int i = 5; i <= items.length; i += 6) {
      items.insert(i, {'category': 'addCat', 'id': 'addCat'});
    }
    if (items.length % 6 != 0) {
      items.add({'category': 'addCat', 'id': 'addCat'});
    } else {
      items.add({'category': 'addCat', 'id': 'addCat'});
      return;
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems({int limit = 6, int offset = 0}) async{
    final response = await http.get(Uri.parse(baseURL + '?limit=$limit&offset=$offset'));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item){
        return {
          'id' : item['id'],
          'category': item['nombre'],
          'image': item['foto'],
        };
      }).toList();
    }else{
      throw Exception('Error al obtener datos de la API');
    }
  }

  Future<void> deleteItem(String categoryId) async {
    try {
      final String deleteUrl = '$baseURL/$categoryId';
      print('Intentando eliminar la categoría con ID: $categoryId');
      print('URL para eliminar: $deleteUrl');
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 204) {
        setState(() {
          items.removeWhere((item) => item['id'] == categoryId);
          selectedCategories.remove(categoryId);
        });
        print('Categoría con ID: $categoryId eliminada exitosamente');
        await loadFirstItems();
        isSelecting = false;
        selectedCategories.clear();
      } else {
        print('Error al eliminar la categoría $categoryId: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar la categoría $categoryId: $e');
    }
  }
  ///termian test alan functions

  @override
  Widget build(BuildContext context) {
    int itemsPerPage = 6;
    return isLoading == false ? Container(
      color: AppColors.bgColor,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: 580,
              ///ENVOLVER EN NOTIFICATION DECIA GPT, AUN EN PRUEBAS
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollEndNotification && hasMoreItems && scrollInfo.metrics.extentAfter == 0) {
                    loadItems();
                  }
                  return true;
                },
                child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: (items.length / itemsPerPage).ceil(),
                    itemBuilder: (context, pageIndex) {
                      int startIndex = pageIndex * itemsPerPage;
                      int endIndex = startIndex + itemsPerPage;
                      if (endIndex > items.length) {
                        endIndex = items.length;
                      }
                      var currentPageItems = items.sublist(startIndex, endIndex);
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.02,
                          bottom: MediaQuery.of(context).size.width * 0.01,
                          left: MediaQuery.of(context).size.width * 0.01,
                          right: MediaQuery.of(context).size.width * 0.01,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: currentPageItems.length,
                        itemBuilder: (context, index) {
                          var item = currentPageItems[index];
                          return item['category'] == 'addCat' ?
                          InkWell(
                            onTap: () {
                              if (isSelecting) {

                              } else {
                                widget.onShowBlur(true);
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return CategoryForm(
                                        onLoad: (load) {
                                          isLoading = load;
                                        }
                                    );
                                  },
                                ).then((_){
                                  loadFirstItems();
                                  widget.onShowBlur(false);
                                });
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.1),
                              color: Colors.transparent,
                              shadowColor: Colors.transparent,
                              child: Padding(
                                  padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.02,
                                    right: MediaQuery.of(context).size.width * 0.02,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteColor,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.blackColor.withOpacity(0.3),
                                                offset: const Offset(4, 4),
                                                blurRadius: 5,
                                                spreadRadius: 0.1,
                                              )
                                            ],
                                          ),
                                          height: MediaQuery.of(context).size.width * 0.35,
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Icon(
                                                CupertinoIcons.add,
                                                color: AppColors.primaryColor.withOpacity(0.3),
                                                size: MediaQuery.of(context).size.width * 0.15,
                                              )
                                          )
                                      ),
                                    ],
                                  )
                              ),
                            ),
                          ) : InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategoryId = item['id'];
                                if (isSelecting) {
                                  if (selectedCategories.contains(item['id'].toString())) {
                                    selectedCategories.remove(item['id'].toString());
                                    if (selectedCategories.isEmpty) {
                                      isSelecting = false;
                                    }
                                  } else {
                                    selectedCategories.add(item['id'].toString());
                                  }
                                } else {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => Products(selectedCategory: item['category'].toString(), onBack: _clearSelectedCategory, selectedCategoryId: selectedCategoryId, onShowBlur: widget.onShowBlur,listenerblurr: widget.listenerblurr),
                                    ),
                                  );
                                }
                              });
                            },
                            onLongPress: () {
                              toggleSelection(item['id'].toString());
                              categoryName = item['category'];
                              categoryImage = item['image'];
                              print(categoryImage);
                            },
                            child: Card(
                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.07),
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.02,
                                      right: MediaQuery.of(context).size.width * 0.02
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteColor,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.blackColor.withOpacity(0.3),
                                                offset: const Offset(4, 4),
                                                blurRadius: 5,
                                                spreadRadius: 0.1,
                                              )
                                            ],
                                          ),
                                          height: MediaQuery.of(context).size.width * 0.35,
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  item['image'],
                                                  fit: BoxFit.fitWidth,
                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child;
                                                    } else {
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          value: loadingProgress.expectedTotalBytes != null
                                                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                              : null,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                                    return Container(
                                                        color: Colors.transparent,
                                                        child: Column(
                                                          children: [
                                                            Flexible(
                                                              child: Image.asset('assets/imgLog/notFound.jpg',
                                                                fit: BoxFit.fill,),),
                                                            const Text('Imagen no disponible'),
                                                          ],
                                                        )
                                                    );
                                                  },
                                                ),
                                              ),
                                              Visibility(
                                                visible: selectedCategories.contains(item['id'].toString()) ? true : false,
                                                child: Container(
                                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01, left: MediaQuery.of(context).size.width * 0.01),
                                                  alignment: Alignment.topLeft,
                                                  decoration: BoxDecoration(
                                                      color: AppColors.blackColor.withOpacity(0.3),
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                          color: AppColors.primaryColor,
                                                          width: MediaQuery.of(context).size.width * 0.01
                                                      )
                                                  ),
                                                  height: MediaQuery.of(context).size.width * 0.4,
                                                  width: MediaQuery.of(context).size.width * 0.5,
                                                  child: const Icon(
                                                    CupertinoIcons.check_mark_circled,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                            "${item['category']}",
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).size.height * 0.017,
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            ),
                          );
                        },
                      );
                    }
                ),
              ),
            ),
          ),
          Visibility(
            visible: isSelecting,
            child: Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height * 0.05,
              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.04, bottom: MediaQuery.of(context).size.width * 0.01, left: MediaQuery.of(context).size.width * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  selectedCategories.length == 1 ? FloatingActionButton(
                    onPressed: () {
                      widget.onShowBlur(true);
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return EditCategoryForm(
                            catID: int.parse(selectedCategories[0]),
                            catName: categoryName,
                            onLoad: (load) {
                              isLoading = load;
                            },
                            catImage: categoryImage,
                          );
                        },
                      ).then((_){
                        loadFirstItems();
                        widget.onShowBlur(false);
                        setState(() {
                          selectedCategories.clear();
                          isSelecting = false;
                        });
                      });
                    },
                    backgroundColor: AppColors.whiteColor,
                    heroTag: null,
                    child: const Icon(Icons.edit, color: AppColors.primaryColor),
                  ) : Container(),
                  Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            selectedCategories.clear();
                            isSelecting = false;
                          });
                        },
                        backgroundColor: AppColors.whiteColor,
                        heroTag: null,
                        child: const Icon(Icons.cancel, color: AppColors.primaryColor),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      FloatingActionButton(
                        onPressed: () async {
                          isLoading = true;
                          List<String> categoriesToDelete = List.from(selectedCategories);
                          for (String categoryId in categoriesToDelete) {
                            await deleteItem(categoryId);
                          }
                        },
                        backgroundColor: AppColors.whiteColor,
                        heroTag: null,
                        child: const Icon(Icons.delete, color: AppColors.redDelete,),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ) : const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
      ),
    );
  }
}
