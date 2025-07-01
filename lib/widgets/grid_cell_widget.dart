
import 'package:flutter/material.dart';
import 'package:flutter_zip_game/utils/constants.dart';
import '../models/grid_cell.dart';

class GridCellWidget extends StatelessWidget {
  final GridCell cell;
  final bool isHighlighted;
  final double size;

  const GridCellWidget({
    Key? key,
    required this.cell,
    this.isHighlighted = false,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.highlightColor.withOpacity(0.3) : AppColors.gridCellColor,
        borderRadius: BorderRadius.circular(8.0), // Add rounded corners
        border: Border.all(
          color: AppColors.gridBorderColor,
          width: 0.5,
        ),
        boxShadow: [ // Add subtle shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: _buildCellContent(context),
      ),
    );
  }

  Widget? _buildCellContent(BuildContext context) {
    if (cell.number != null) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHighlighted ? AppColors.highlightColor : AppColors.primaryColor,
          boxShadow: [
            BoxShadow(
              color: isHighlighted ? AppColors.highlightColor.withOpacity(0.7) : AppColors.primaryColor.withOpacity(0.4),
              blurRadius: isHighlighted ? 12 : 6,
              spreadRadius: isHighlighted ? 3 : 1,
              offset: Offset(0, isHighlighted ? 4 : 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            cell.number.toString(),
            style: AppTextStyles.number.copyWith(fontSize: size * 0.5),
          ),
        ),
      );
    }
    return Container(
      width: size * 0.15,
      height: size * 0.15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gridBorderColor,
      ),
    );
  }
}
