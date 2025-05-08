import 'package:bettingapp/models/game_type.dart';
import 'package:bettingapp/models/draw.dart';
import 'package:bettingapp/models/user.dart';
import 'package:bettingapp/models/location.dart';

class Bet {
  final int? id;
  final String? ticketId;
  final String? betNumber;
  final double? amount;
  final bool? isClaimed;
  final bool? isRejected;
  final bool? isCombination;
  final String? betDate;
  final String? betDateFormatted;
  final String? createdAt;
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
    this.isClaimed,
    this.isRejected,
    this.isCombination,
    this.betDate,
    this.betDateFormatted,
    this.createdAt,
    this.gameType,
    this.draw,
    this.teller,
    this.location,
    this.customer,
  });
  
  factory Bet.fromJson(Map<String, dynamic> json) {
    return Bet(
      id: json['id'],
      ticketId: json['ticket_id'],
      betNumber: json['bet_number'],
      amount: json['amount'] is int 
          ? (json['amount'] as int).toDouble() 
          : json['amount'],
      isClaimed: json['is_claimed'],
      isRejected: json['is_rejected'],
      isCombination: json['is_combination'],
      betDate: json['bet_date'],
      betDateFormatted: json['bet_date_formatted'],
      createdAt: json['created_at'],
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
    );
  }
  
  factory Bet.fromMap(Map<String, dynamic> map) {
    return Bet(
      id: map['id'],
      ticketId: map['ticket_id'],
      betNumber: map['bet_number'],
      amount: map['amount'] is int 
          ? (map['amount'] as int).toDouble() 
          : map['amount'],
      isClaimed: map['is_claimed'],
      isRejected: map['is_rejected'],
      isCombination: map['is_combination'],
      betDate: map['bet_date'],
      betDateFormatted: map['bet_date_formatted'],
      createdAt: map['created_at'],
      gameType: map['game_type'] != null 
          ? GameType.fromMap(map['game_type']) 
          : null,
      draw: map['draw'] != null 
          ? Draw.fromMap(map['draw']) 
          : null,
      teller: map['teller'] != null 
          ? User.fromMap(map['teller']) 
          : null,
      location: map['location'] != null 
          ? Location.fromMap(map['location']) 
          : null,
      customer: map['customer'] != null 
          ? User.fromMap(map['customer']) 
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'bet_number': betNumber,
      'amount': amount,
      'is_claimed': isClaimed,
      'is_rejected': isRejected,
      'is_combination': isCombination,
      'bet_date': betDate,
      'bet_date_formatted': betDateFormatted,
      'created_at': createdAt,
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
    bool? isClaimed,
    bool? isRejected,
    bool? isCombination,
    String? betDate,
    String? betDateFormatted,
    String? createdAt,
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
      isClaimed: isClaimed ?? this.isClaimed,
      isRejected: isRejected ?? this.isRejected,
      isCombination: isCombination ?? this.isCombination,
      betDate: betDate ?? this.betDate,
      betDateFormatted: betDateFormatted ?? this.betDateFormatted,
      createdAt: createdAt ?? this.createdAt,
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
