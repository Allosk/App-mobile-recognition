import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:myapp/scan_controller.dart';

class TopImageViewer extends GetView<ScanController> {
  const TopImageViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ScanController>(builder: (controller) => 
    Positioned(
      top: 50,
      child: SizedBox(
        width: Get.width,
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: controller.imageList.length,
      itemBuilder: (_, index){
        return SizedBox(
          height: 100,
          width: 75,
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(
                    1, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(
                        controller.imageList[index]),
                    ),
                  ),
                ),
              ),),),);
    })

    )
    ));
  }
}