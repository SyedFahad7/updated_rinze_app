import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/string_utils.dart';
import '../../../order_timeline_tile.dart';

class HistoryOrderTrackingTab extends StatefulWidget {
  const HistoryOrderTrackingTab({
    super.key,
    required this.orderStatuses,
    required this.currentStatus,
  });

  final List<dynamic> orderStatuses;
  final String currentStatus;

  @override
  State<HistoryOrderTrackingTab> createState() =>
      _HistoryOrderTrackingTabState();
}

class _HistoryOrderTrackingTabState extends State<HistoryOrderTrackingTab> {
  late List<dynamic> backendStatuses;

  List statuses = [
    'confirmed',
    'readyForPickup',
    'orderPickedUp',
    'reachedCollectionCentre',
    'readyForDelivery',
    'outForDelivery',
    'delivered',
  ];

  @override
  void initState() {
    super.initState();
    backendStatuses = widget.orderStatuses;
  }

  // Call this method whenever backendStatuses changes
  void updateStatuses(List<dynamic> newStatuses) {
    setState(() {
      backendStatuses = newStatuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    backendStatuses = widget.orderStatuses;
    final serviceStatuses = backendStatuses
        .where((status) => [
              'inWashing',
              'inIroning',
              'inDryCleaning',
              'inDeepCleaning',
            ].contains(status['status']))
        .map((status) => status['status'])
        .toList();

    final allStatuses = [
      ...statuses.sublist(0, 4),
      ...serviceStatuses,
      ...statuses.sublist(4),
    ];

    final currentStatusIndex = allStatuses.indexOf(widget.currentStatus);

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.halfWhite,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        border: Border.all(
          color: AppColors.black.withOpacity(0.06),
          width: 2.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allStatuses.length,
              itemBuilder: (context, index) {
                final status = allStatuses[index];
                final isPast = index <= currentStatusIndex;

                final backendStatus = backendStatuses.firstWhere(
                    (s) => s['status'] == status,
                    orElse: () => null);

                final dateTime = backendStatus != null
                    ? DateTime.parse(backendStatus['updatedAt'])
                    : null;

                final formattedDateTime = dateTime != null
                    ? '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}  ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
                    : 'Pending';

                // Determine the image to show based on the status
                String imagePath;
                switch (status) {
                  case 'confirmed':
                    imagePath = 'assets/images/confirmed.png';
                    break;
                  case 'readyForPickup':
                    imagePath = 'assets/images/ready_for_pickup.png';
                    break;
                  case 'orderPickedUp':
                    imagePath = 'assets/images/order_picked_up.png';
                    break;
                  case 'reachedCollectionCentre':
                    imagePath = 'assets/images/reached_collection_centre.png';
                    break;
                  case 'readyForDelivery':
                    imagePath = 'assets/images/ready_for_delivery.png';
                    break;
                  case 'outForDelivery':
                    imagePath = 'assets/images/out_for_delivery.png';
                    break;
                  case 'delivered':
                    imagePath = 'assets/images/delivered.png';
                    break;
                  default:
                    imagePath = 'assets/images/default_status.png';
                }

                return OrderTimelineTile(
                  isFirst: index == 0,
                  isLast: index == allStatuses.length - 1,
                  isPast: isPast,
                  title: capitalize(splitString(status)),
                  dateTime: formattedDateTime,
                  imagePath: imagePath, // Pass the image path to the tile
                  showImage: index ==
                      currentStatusIndex, // Show image only for current status
                );
              },
            ),
          ),
          Image.asset('assets/images/washing_machine_grey.png'),
        ],
      ),
    );
  }
}
