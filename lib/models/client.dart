import 'package:clever_realtor/services/logger_service.dart';

class Client {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final double? budgetMin;
  final double? budgetMax;
  final List<String>? preferredLocations;
  final List<int>? preferredRooms;
  final List<String>? propertyTypes;
  final double? minSquareMeters;
  final String? preferredStyle;
  final bool? hasParking;
  final String? notes;
  final DateTime? desiredMoveInDate;
  final List<String>? amenities;

  Client.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        phone = json['phone'],
        budgetMin = _parseDouble(json['budgetMin']),
        budgetMax = _parseDouble(json['budgetMax']),
        preferredLocations = _parseStringList(json['preferredLocations']),
        preferredRooms = _parsePreferredRooms(json['preferredRooms']),
        propertyTypes = _parseStringList(json['propertyTypes']),
        minSquareMeters = _parseDouble(json['minSquareMeters']),
        preferredStyle = json['preferredStyle'],
        hasParking = json['hasParking'],
        notes = json['notes'],
        desiredMoveInDate = json['desiredMoveInDate'] != null
            ? DateTime.parse(json['desiredMoveInDate'])
            : null,
        amenities = _parseStringList(json['amenities']);

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    return null;
  }

  static List<int>? _parsePreferredRooms(dynamic rooms) {
    if (rooms == null) return null;
    try {
      if (rooms is List) {
        return rooms.map((room) {
          if (room is int) return room;
          if (room is double) return room.toInt();
          if (room is String) return int.parse(room);
          if (room is Map && room['low'] != null) {
            var low = room['low'];
            if (low is int) return low;
            if (low is double) return low.toInt();
            if (low is String) return int.parse(low);
          }
          LoggerService.error('Invalid room value', room);
          return 0;
        }).toList();
      }
      return null;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error parsing preferred rooms',
        {'error': e, 'rooms': rooms},
        stackTrace,
      );
      return null;
    }
  }

  static List<Client> parseClientsList(List? data) {
    try {
      return (data ?? []).map((e) => Client.fromJson(e)).toList();
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error parsing clients data',
        {'error': e, 'data': data},
        stackTrace,
      );
      return [];
    }
  }
}
