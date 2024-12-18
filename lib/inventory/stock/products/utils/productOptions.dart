import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../helpers/themes/colors.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../views/productDetails.dart';
import '../services/productsService.dart';
import '../services/stockService.dart';
import 'PopUpTabs/deleteProductDialog.dart';
import 'PopUpTabs/modifyStockDialog.dart';

class ProductOptions extends StatefulWidget {

  final VoidCallback onClose;
  final String nombre;
  final String cant;
  final double precio;
  final int id;
  final String barCode;
  final String descripcion;
  final int stock;
  final int catId;
  final Function(double) columnHeight;
  final Future<void> Function() onProductDeleted;
  final void Function(
      bool
      ) onShowBlur;
  final Future<void> Function() onProductModified;

  final dynamic columnH;

  const ProductOptions({super.key, required this.onClose, required this.nombre, required this.cant, required this.precio, required this.columnH, required void Function(bool p1) onShowBlureight, required this.id, required this.barCode, required this.stock, required this.catId, required this.descripcion, required this.onProductDeleted, required this.onShowBlur, required this.columnHeight, required this.onProductModified,
  });

  @override
  State<ProductOptions> createState() => _ProductOptionsState();
}

class _ProductOptionsState extends State<ProductOptions> {

  final GlobalKey _columnKey = GlobalKey();
  double _columnHeight = 0.0;
  final productService = ProductService();
  final stockService = StockService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHeight();
    });
  }

  void _calculateHeight() {
    final RenderBox? renderBox =
    _columnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _columnHeight = renderBox.size.height;
        widget.columnHeight(_columnHeight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: (){
          widget.onShowBlur(false);
          widget.onClose();
        },
        child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
            color: Colors.transparent,
            child: Column(
              key: _columnKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02,
                          vertical: MediaQuery.of(context).size.width * 0.009,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors3.whiteColor,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02, horizontal: MediaQuery.of(context).size.width * 0.0247),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.nombre,
                                style: TextStyle(
                                  color: AppColors3.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Cant.: ",
                                    style: TextStyle(color: AppColors3.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                                  ),
                                  Text(
                                    //'${widget.cant}',//products_global[index]['cant_cart'] == null ? 'Agotado' : '${products_global[index]['cant_cart']['cantidad']}',
                                    widget.cant == '0' ? 'Agotado' : '${widget.cant}',
                                    style: TextStyle(
                                        color: AppColors3.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Precio: ",
                                    style: TextStyle(color: AppColors3.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Text(
                                      '\$${widget.precio} MXN',//"\$${products_global[]['price']} MXN",
                                      style: TextStyle(
                                        color: AppColors3.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                        )))
                              ])
                            ]))),
                Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.01,
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors3.whiteColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextButton(
                                onPressed: () {
                                  widget.onClose();
                                  Navigator.push(context,
                                    CupertinoPageRoute(
                                      builder: (context) => ProductDetails(
                                          idProduct: widget.id,
                                          nameProd: widget.nombre,
                                          descriptionProd: widget.descripcion,
                                          catId: widget.catId,
                                          barCode: widget.barCode,
                                          stock: widget.stock,
                                          precio: widget.precio,
                                          onProductModified: () async {
                                            await productService.refreshProducts(widget.catId);
                                          },
                                          onShowBlur: widget.onShowBlur
                                      ),
                                    ),
                                  ).then((_) {
                                    widget.onShowBlur(false);
                                  });
                                },
                                style: const ButtonStyle(
                                  alignment: Alignment.centerLeft,
                                ),
                                child: const Text(
                                  'Detalles',
                                  style: TextStyle(
                                      color: AppColors3.primaryColor
                                  ),
                                ),
                              ),
                          ],
                        ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors3.primaryColor.withOpacity(0.3)),
                            bottom: BorderSide(color: AppColors3.primaryColor.withOpacity(0.3)),
                          )
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                widget.onClose();
                                showDialog(
                                    context: context,
                                    builder: (builder) {
                                      return ModifyProductStockDialog(nombreProd: widget.nombre, cantProd: widget.stock, onModify: (int currentStock) async {
                                        await stockService.updateProductStock(idProduct: widget.id, stockValue: widget.stock, controllerValue: currentStock);
                                        if (mounted) {
                                          print('hola');
                                          showOverlay(
                                            context,
                                            const CustomToast(
                                              message: 'Producto modificado',
                                            ),
                                          );
                                        }
                                        await widget.onProductModified();
                                      },
                                        idProd: widget.id,
                                      );
                                    }
                                ).then((_) {
                                  widget.onShowBlur(false);
                                });
                              },
                              style: const ButtonStyle(
                                  alignment: Alignment.centerLeft
                              ),
                              child: const Text(
                                'Modificar stock',
                                style: TextStyle(
                                    color: AppColors3.primaryColor
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                     Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                            TextButton(
                                onPressed: () {
                                  widget.onClose();
                                  widget.onShowBlur(true);
                                  showDeleteProductConfirmationDialog(context, () async {
                                    await productService.deleteProduct(widget.id);
                                    if (mounted) {
                                      showOverlay(
                                        context,
                                        const CustomToast(
                                          message: 'Producto eliminado',
                                        ),
                                      );
                                    }
                                    await widget.onProductDeleted();
                                  }).then((_) {
                                    widget.onShowBlur(false);
                                  });
                                },
                                style: const ButtonStyle(
                                    alignment: Alignment.centerLeft
                                ),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(
                                      color: AppColors3.redDelete)))
                                ])
                              ]))
                    ]))));
  }
}
