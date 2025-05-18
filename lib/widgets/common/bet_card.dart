import 'package:flutter/material.dart';
import 'package:bettingapp/models/bet.dart';
import 'package:bettingapp/utils/app_colors.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class BetCard extends StatelessWidget {
  final Bet bet;
  final Function(int)? onCancelBet;
  final VoidCallback? onTap;
  final bool showCancelButton;
  final bool isCompactMode;

  const BetCard({
    Key? key,
    required this.bet,
    this.onCancelBet,
    this.onTap,
    this.showCancelButton = true,
    this.isCompactMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCancelled = bet.isRejected ?? false;
    final isClaimed = bet.isClaimed ?? false;
    
    // Compact mode is used in the CancelBetScreen
    if (isCompactMode) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bet Number
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            bet.betNumber ?? '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        bet.ticketId ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Expanded(
                  flex: 1,
                  child: Text(
                    bet.formattedAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Schedule
                Expanded(
                  flex: 1,
                  child: Text(
                    bet.draw?.drawTimeFormatted ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Full card mode used in BetListScreen
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isCancelled
              ? Colors.red.shade200
              : isClaimed
                  ? Colors.green.shade200
                  : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ticket ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        bet.ticketId ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Color(0xFFFFEBEE) // Light red
                        : isClaimed
                            ? Color(0xFFE8F5E9) // Light green
                            : Color(0xFFE3F2FD), // Light blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCancelled
                        ? 'Cancelled'
                        : isClaimed
                            ? 'Claimed'
                            : 'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCancelled
                          ? Color(0xFFD32F2F) // Deep red
                          : isClaimed
                              ? Color(0xFF2E7D32) // Deep green
                              : Color(0xFF1976D2), // Deep blue
                    ),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Bet details
            Row(
              children: [
                // Bet number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bet Number',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        bet.betNumber ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      bet.formattedAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Date and time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        bet.betDateFormatted ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Draw time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Draw Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      bet.draw?.drawTimeFormatted ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Only show cancel button for active bets that are not cancelled or claimed
            if (showCancelButton && !(isCancelled || isClaimed) && onCancelBet != null && bet.id != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Show confirmation dialog
                        Modal.showConfirmModal(
                          title: 'Cancel Bet',
                          message: 'Are you sure you want to cancel this bet?',
                          confirmText: 'Cancel Bet',
                          onConfirm: () {
                            onCancelBet!(bet.id!);
                          },
                          isDangerousAction: true,
                        );
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Bet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF5F5F5),
                        foregroundColor: Color(0xFF757575),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
