import 'package:bettingapp/models/game_type.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/models/user.dart';
import 'package:bettingapp/models/location.dart';

import 'package:intl/intl.dart';

class Bet {
  final int? id;

  /// Returns a formatted amount, using API value if present, else fallback
  String get formattedAmount {
    if (amountFormatted?.isNotEmpty == true) {
      return '₱$amountFormatted';
    }
    if (amount == null) return '-';
    return '₱${NumberFormat('#,##0.##').format(amount)}';
  }

  /// Returns a formatted winning amount, using API value if present, else fallback
  String get formattedWinningAmount {
    if (winningAmountFormatted?.isNotEmpty == true) {
      return '₱$winningAmountFormatted';
    }
    if (winningAmount == null) return '-';
    return '₱${NumberFormat('#,##0.##').format(winningAmount)}';
  }

  // These fields are only set by the fromJson/factory
  final String? amountFormatted;
  final String? winningAmountFormatted;

  /// Returns a formatted label for Bet Type + Draw Time + D4 Sub-selection (if any)
  String get betTypeDrawLabel {
    final drawTime = draw?.drawTimeSimple ?? 'Unknown';
    final code = gameType?.code ?? 'Unknown';
    final isD4 = code.toUpperCase() == 'D4' || code.toUpperCase() == '4D';
    final d4Sub = d4SubSelection;
    if (isD4 && d4Sub != null && d4Sub.isNotEmpty) {
      return '$drawTime$code-$d4Sub';
    } else {
      return '$drawTime$code';
    }
  }

  final String? ticketId;
  final String? betNumber;
  final double? amount;
  final dynamic winningAmount;
  final bool? isLowWin;
  final bool? isClaimed;
  final bool? isRejected;
  final bool? isCombination;
  final String? betDate;
  final String? betDateFormatted;
  final String? createdAt;
  final String? claimedAt;
  final String? claimedAtFormatted;
  final String? d4SubSelection;
  final bool? isWinner;
  final GameType? gameType;
  final Draw? draw;
  final User? teller;
  final Location? location;
  final User? customer;
  
  Bet({
    this.id,
    this.ticketId,
    this.betNumber,
    this.amount,
    this.winningAmount,
    this.isLowWin,
    this.isClaimed,
    this.isRejected,
    this.isCombination,
    this.betDate,
    this.betDateFormatted,
    this.createdAt,
    this.claimedAt,
    this.claimedAtFormatted,
    this.d4SubSelection,
    this.isWinner,
    this.gameType,
    this.draw,
    this.teller,
    this.location,
    this.customer,
    this.amountFormatted,
    this.winningAmountFormatted,
  });

  
  factory Bet.fromJson(Map json) {
    // Print the json for debugging
    print('Parsing Bet.fromJson: $json');
    
    // Handle amount conversion safely
    double? parseAmount() {
      final amount = json['amount'];
      if (amount == null) return null;
      if (amount is int) return amount.toDouble();
      if (amount is double) return amount;
      if (amount is String) return double.tryParse(amount);
      return null;
    }
    
    // Handle winning amount conversion safely
    dynamic parseWinningAmount() {
      final winningAmount = json['winning_amount'];
      if (winningAmount == null) return null;
      if (winningAmount is int) return winningAmount;
      if (winningAmount is double) return winningAmount;
      if (winningAmount is String) {
        // Try to parse as int first
        final intValue = int.tryParse(winningAmount);
        if (intValue != null) return intValue;
        
        // If not an int, try as double
        return double.tryParse(winningAmount);
      }
      return winningAmount; // Return as is if can't parse
    }
    
    return Bet(
      id: json['id'],
      ticketId: json['ticket_id']?.toString(),
      betNumber: json['bet_number']?.toString(),
      amount: parseAmount(),
      winningAmount: parseWinningAmount(),
      isLowWin: json['is_low_win'],
      isClaimed: json['is_claimed'],
      isRejected: json['is_rejected'],
      isCombination: json['is_combination'],
      betDate: json['bet_date'],
      betDateFormatted: json['bet_date_formatted'],
      createdAt: json['created_at'],
      claimedAt: json['claimed_at'],
      claimedAtFormatted: json['claimed_at_formatted'],
      d4SubSelection: json['d4_sub_selection'],
      isWinner: json['is_winner'],
      gameType: json['game_type'] != null 
          ? GameType.fromJson(json['game_type']) 
          : null,
      draw: json['draw'] != null 
          ? Draw.fromJson(json['draw']) 
          : null,
      teller: json['teller'] != null 
          ? User.fromJson(json['teller']) 
          : null,
      location: json['location'] != null 
          ? Location.fromJson(json['location']) 
          : null,
      customer: json['customer'] != null 
          ? User.fromJson(json['customer']) 
          : null,
      amountFormatted: json['amount_formatted'],
      winningAmountFormatted: json['winning_amount_formatted'],
    );
  }
  
  factory Bet.fromMap(Map map) {
    // Handle amount conversion safely
    double? parseAmount() {
      final amount = map['amount'];
      if (amount == null) return null;
      if (amount is int) return amount.toDouble();
      if (amount is double) return amount;
      if (amount is String) return double.tryParse(amount);
      return null;
    }
    
    // Handle winning amount conversion safely
    dynamic parseWinningAmount() {
      final winningAmount = map['winning_amount'];
      if (winningAmount == null) return null;
      if (winningAmount is int) return winningAmount;
      if (winningAmount is double) return winningAmount;
      if (winningAmount is String) {
        // Try to parse as int first
        final intValue = int.tryParse(winningAmount);
        if (intValue != null) return intValue;
        
        // If not an int, try as double
        return double.tryParse(winningAmount);
      }
      return winningAmount; // Return as is if can't parse
    }
    
    return Bet(
      id: map['id'],
      ticketId: map['ticket_id']?.toString(),
      betNumber: map['bet_number']?.toString(),
      amount: parseAmount(),
      winningAmount: parseWinningAmount(),
      isLowWin: map['is_low_win'],
      isClaimed: map['is_claimed'],
      isRejected: map['is_rejected'],
      isCombination: map['is_combination'],
      betDate: map['bet_date'],
      betDateFormatted: map['bet_date_formatted'],
      createdAt: map['created_at'],
      claimedAt: map['claimed_at'],
      claimedAtFormatted: map['claimed_at_formatted'],
      d4SubSelection: map['d4_sub_selection'],
      isWinner: map['is_winner'],
      gameType: map['game_type'] != null 
          ? GameType.fromMap(map['game_type'] as Map) 
          : null,
      draw: map['draw'] != null 
          ? Draw.fromMap(map['draw'] as Map) 
          : null,
      teller: map['teller'] != null 
          ? User.fromMap(map['teller'] as Map) 
          : null,
      location: map['location'] != null 
          ? Location.fromMap(map['location'] as Map) 
          : null,
      customer: map['customer'] != null 
          ? User.fromMap(map['customer'] as Map) 
          : null,
      amountFormatted: map['amount_formatted'],
      winningAmountFormatted: map['winning_amount_formatted'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'bet_number': betNumber,
      'amount': amount,
      'winning_amount': winningAmount,
      'is_low_win': isLowWin,
      'is_claimed': isClaimed,
      'is_rejected': isRejected,
      'is_combination': isCombination,
      'bet_date': betDate,
      'bet_date_formatted': betDateFormatted,
      'created_at': createdAt,
      'claimed_at': claimedAt,
      'claimed_at_formatted': claimedAtFormatted,
      'd4_sub_selection': d4SubSelection,
      'is_winner': isWinner,
      'game_type': gameType?.toMap(),
      'draw': draw?.toMap(),
      'teller': teller?.toMap(),
      'location': location?.toMap(),
      'customer': customer?.toMap(),
    };
  }
  
  Bet copyWith({
    int? id,
    String? ticketId,
    String? betNumber,
    double? amount,
    int? winningAmount,
    bool? isLowWin,
    bool? isClaimed,
    bool? isRejected,
    bool? isCombination,
    String? betDate,
    String? betDateFormatted,
    String? createdAt,
    String? claimedAt,
    String? claimedAtFormatted,
    String? d4SubSelection,
    bool? isWinner,
    GameType? gameType,
    Draw? draw,
    User? teller,
    Location? location,
    User? customer,
  }) {
    return Bet(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      betNumber: betNumber ?? this.betNumber,
      amount: amount ?? this.amount,
      winningAmount: winningAmount ?? this.winningAmount,
      isLowWin: isLowWin ?? this.isLowWin,
      isClaimed: isClaimed ?? this.isClaimed,
      isRejected: isRejected ?? this.isRejected,
      isCombination: isCombination ?? this.isCombination,
      betDate: betDate ?? this.betDate,
      betDateFormatted: betDateFormatted ?? this.betDateFormatted,
      createdAt: createdAt ?? this.createdAt,
      claimedAt: claimedAt ?? this.claimedAt,
      claimedAtFormatted: claimedAtFormatted ?? this.claimedAtFormatted,
      d4SubSelection: d4SubSelection ?? this.d4SubSelection,
      isWinner: isWinner ?? this.isWinner,
      gameType: gameType ?? this.gameType,
      draw: draw ?? this.draw,
      teller: teller ?? this.teller,
      location: location ?? this.location,
      customer: customer ?? this.customer,
    );
  }
  
  @override
  String toString() {
    return 'Bet(id: $id, ticketId: $ticketId, betNumber: $betNumber, amount: $amount)';
  }
}
