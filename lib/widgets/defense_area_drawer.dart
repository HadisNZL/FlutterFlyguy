import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/colors.dart';
import '../models/login_init/defense_area_model.dart';

/// 防区列表侧滑抽屉
class DefenseAreaDrawer extends ConsumerWidget {
  const DefenseAreaDrawer({
    required this.defenseAreas,
    required this.currentAreaId,
    required this.onAreaSelected,
    super.key,
  });
  final List<DefenseArea> defenseAreas;
  final int currentAreaId;
  final Function(int areaId) onAreaSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: drawerWidth,
        color: AppColors.colorWhite,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildAreaList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16),
      child: IconButton(
        icon: const Icon(Icons.close, size: 28, color: AppColors.color999999),
        onPressed: () => Navigator.of(context).pop(),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildAreaList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: defenseAreas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final area = defenseAreas[index];
        final isSelected = area.areaId == currentAreaId;
        return _buildAreaCard(area, isSelected);
      },
    );
  }

  Widget _buildAreaCard(DefenseArea area, bool isSelected) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () {
          onAreaSelected(area.areaId);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFA726)
                  : const Color(0xFFE0E0E0),
              width: isSelected ? 2.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                area.areaName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              if (area.tag != null && area.tag!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFA726)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    area.tag!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFA726),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.home, size: 18, color: Color(0xFFFFA726)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatAddress(area.address),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(AFAddress address) {
    if (address.addressLine != null && address.addressLine!.isNotEmpty) {
      final parts = <String>[address.addressLine!];
      if (address.city != null) parts.add(address.city!);
      if (address.state != null) parts.add(address.state!);
      if (address.country != null) parts.add(address.country!);
      if (address.zip != null) parts.add(address.zip!);
      return parts.join(',');
    }
    return '尚未添加E911地址信息';
  }
}
