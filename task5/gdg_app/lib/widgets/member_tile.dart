import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class MemberTile extends StatelessWidget {
  final String memberId;
  final String memberName;
  final bool isLead;
  final VoidCallback? onRemove;
  final VoidCallback? onSetLead;

  const MemberTile({
    super.key,
    required this.memberId,
    required this.memberName,
    this.isLead = false,
    this.onRemove,
    this.onSetLead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLead ? AppColors.warning : AppColors.primary,
          child: Text(
            memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              memberName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isLead) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: AppColors.warning),
                    SizedBox(width: 4),
                    Text(
                      'Lead',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          memberId,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'lead':
                onSetLead?.call();
                break;
              case 'remove':
                onRemove?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isLead)
              const PopupMenuItem(
                value: 'lead',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Set as Lead'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
