class DetailedTallysheet {
  final String? date;
  final String? dateFormatted;
  final GameType? gameType;
  final double? totalAmount;
  final String? totalAmountFormatted;
  final List<BetDetail>? bets;
  final Map<String, List<BetDetail>>? betsByGameType;
  final int? total;
  final int? currentPage;

  DetailedTallysheet({
    this.date,
    this.dateFormatted,
    this.gameType,
    this.totalAmount,
    this.totalAmountFormatted,
    this.bets,
    this.betsByGameType,
    this.total,
    this.currentPage,
  });

  factory DetailedTallysheet.fromJson(Map<String, dynamic> json) {
    // Parse bets list
    List<BetDetail>? betsList;
    if (json['bets'] != null) {
      betsList = List<BetDetail>.from(json['bets'].map((x) => BetDetail.fromJson(x)));
    }
    
    // Parse bets by game type
    Map<String, List<BetDetail>>? betsByGameType;
    if (json['bets_by_game_type'] != null) {
      betsByGameType = {};
      json['bets_by_game_type'].forEach((key, value) {
        if (value is List) {
          betsByGameType![key] = List<BetDetail>.from(
            value.map((x) => BetDetail.fromJson(x))
          );
        }
      });
    }
    
    return DetailedTallysheet(
      date: json['date'],
      dateFormatted: json['date_formatted'],
      gameType: json['game_type'] != null ? GameType.fromJson(json['game_type']) : null,
      totalAmount: json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null,
      totalAmountFormatted: json['total_amount_formatted'],
      bets: betsList,
      betsByGameType: betsByGameType,
      total: json['pagination'] != null ? json['pagination']['total'] : null,
      currentPage: json['pagination'] != null ? json['pagination']['current_page'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> betsByGameTypeJson = {};
    betsByGameType?.forEach((key, value) {
      betsByGameTypeJson[key] = value.map((x) => x.toJson()).toList();
    });
    
    return {
      'date': date,
      'date_formatted': dateFormatted,
      'game_type': gameType?.toJson(),
      'total_amount': totalAmount,
      'total_amount_formatted': totalAmountFormatted,
      'bets': bets?.map((x) => x.toJson()).toList(),
      'bets_by_game_type': betsByGameTypeJson,
      'pagination': {
        'total': total,
        'current_page': currentPage,
      },
    };
  }
}

class GameType {
  final int? id;
  final String? code;
  final String? name;

  GameType({
    this.id,
    this.code,
    this.name,
  });

  factory GameType.fromJson(Map<String, dynamic> json) {
    return GameType(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class BetDetail {
  final dynamic betNumber;
  final double? amount;
  final String? amountFormatted;
  final String? gameTypeCode;
  final List<int>? betIds;
  final List<int>? ticketIds;
  final int? ticketCount;
  final String? drawTime;
  final String? drawTimeFormatted;
  final String? drawTimeSimple;
  final String? d4SubSelection;
  final String? displayType;

  BetDetail({
    this.betNumber,
    this.amount,
    this.amountFormatted,
    this.gameTypeCode,
    this.betIds,
    this.ticketIds,
    this.ticketCount,
    this.drawTime,
    this.drawTimeFormatted,
    this.drawTimeSimple,
    this.d4SubSelection,
    this.displayType,
  });

  factory BetDetail.fromJson(Map<String, dynamic> json) {
    // Parse bet_ids and ticket_ids arrays if they exist
    List<int>? betIds;
    if (json['bet_ids'] != null) {
      try {
        betIds = List<int>.from(json['bet_ids'].map((x) {
          // Handle different types safely
          if (x is int) return x;
          if (x is String) {
            return int.tryParse(x) ?? 0; // Use tryParse with fallback
          }
          return 0; // Default fallback
        }));
      } catch (e) {
        // If parsing fails, create an empty list
        betIds = [];
      }
    }
    
    List<int>? ticketIds;
    if (json['ticket_ids'] != null) {
      try {
        ticketIds = List<int>.from(json['ticket_ids'].map((x) {
          // Handle different types safely
          if (x is int) return x;
          if (x is String) {
            return int.tryParse(x) ?? 0; // Use tryParse with fallback
          }
          return 0; // Default fallback
        }));
      } catch (e) {
        // If parsing fails, create an empty list
        ticketIds = [];
      }
    }
    
    // Parse ticket count safely
    int? ticketCount;
    if (json['ticket_count'] != null) {
      if (json['ticket_count'] is int) {
        ticketCount = json['ticket_count'];
      } else if (json['ticket_count'] is String) {
        ticketCount = int.tryParse(json['ticket_count']) ?? 0;
      } else {
        ticketCount = 0;
      }
    }
    
    return BetDetail(
      betNumber: json['bet_number'],
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      amountFormatted: json['amount_formatted'],
      gameTypeCode: json['game_type_code'],
      betIds: betIds,
      ticketIds: ticketIds,
      ticketCount: ticketCount,
      drawTime: json['draw_time'],
      drawTimeFormatted: json['draw_time_formatted'],
      drawTimeSimple: json['draw_time_simple'],
      d4SubSelection: json['d4_sub_selection'],
      displayType: json['display_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bet_number': betNumber,
      'amount': amount,
      'amount_formatted': amountFormatted,
      'game_type_code': gameTypeCode,
      'bet_ids': betIds,
      'ticket_ids': ticketIds,
      'ticket_count': ticketCount,
      'draw_time': drawTime,
      'draw_time_formatted': drawTimeFormatted,
      'draw_time_simple': drawTimeSimple,
      'd4_sub_selection': d4SubSelection,
      'display_type': displayType,
    };
  }
}
