import 'package:async/async.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class SubCategoryComponent extends StatefulWidget {
  final int? catId;
  final Function(bool val) onDataLoaded;

  SubCategoryComponent({required this.catId, required this.onDataLoaded});

  @override
  _SubCategoryComponentState createState() => _SubCategoryComponentState();
}

class _SubCategoryComponentState extends State<SubCategoryComponent> {
  AsyncMemoizer<CategoryResponse> _asyncMemoizer = AsyncMemoizer();

  Category allValue = Category(id: -1, name: "All");

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CategoryResponse>(
      future: _asyncMemoizer.runOnce(() => getSubCategoryList(catId: widget.catId.validate())),
      builder: (context, snap) {
        if (snap.hasData) {
          if (snap.data!.categoryList!.isEmpty) {
            widget.onDataLoaded.call(false);
            return Offstage();
          } else {
            if (!snap.data!.categoryList!.contains(allValue)) {
              snap.data!.categoryList!.insert(0, allValue);
            }
            widget.onDataLoaded.call(true);

            return Column(
              children: [
                16.height,
                Text(language!.lblSubcategories, style: boldTextStyle()),
                HorizontalList(
                  itemCount: snap.data!.categoryList!.length,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (_, index) {
                    Category data = snap.data!.categoryList![index];

                    return Observer(
                      builder: (_) {
                        bool isSelected = filterStore.selectedSubCategoryId == index;

                        return ChoiceChip(
                          label: Text(data.name.validate(), style: primaryTextStyle(color: isSelected ? Colors.white : textPrimaryColorGlobal)),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          onSelected: (bool selected) {
                            filterStore.setSelectedSubCategory(catId: index);
                            LiveStream().emit("updateData", data.id.validate());
                          },
                          backgroundColor: context.scaffoldBackgroundColor,
                          labelStyle: TextStyle(color: Colors.white),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }
        }

        return snapWidgetHelper(snap, loadingWidget: Offstage());
      },
    );
  }
}
