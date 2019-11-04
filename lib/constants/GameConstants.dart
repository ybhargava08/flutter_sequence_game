import 'package:flutter/material.dart';

class GameConstants {
    
    static const List<String> GAME_DECK = ['wild', '6D', '7D', '8D', '9D', '10D', 'QD', 'KD', 'AD', 'wild',
      '5D', '3H', '2H', '2S', '3S', '4S', '5S', '6S', '7S', 'AC',
      '4D', '4H', 'KD', 'AD', 'AC', 'KC', 'QC', '10C', '8S', 'KC',
      '3D', '5H', 'QD', 'QH', '10H', '9H', '8H', '9C', '9S', 'QC',
      '2D', '6H', '10D', 'KH', '3H', '2H', '7H', '8C', '10S', '10C',
      'AS', '7H', '9D', 'AH', '4H', '5H', '6H', '7C', 'QS', '9C',
      'KS', '8H', '8D', '2C', '3C', '4C', '5C', '6C', 'KS', '8C',
      'QS', '9H', '7D', '6D', '5D', '4D', '3D', '2D', 'AS', '7C',
      '10S', '10H', 'QH', 'KH', 'AH', '2C', '3C', '4C', '5C', '6C',
      'wild', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S', 'wild', 'J2', 'J2', 'J2', 'J2', 'J1', 'J1', 'J1', 'J1'];

      static const List<String> PLAYER_COLOR = ['red','teal'];

      static const double CARD_WIDTH_FACTOR = 0.09;

      static const double CARD_HEIGHT_FACTOR = 0.07;

      static Color bgColor = Colors.green[300];

      static Color textColor = Colors.white;

      static  const String REMOVE_GAME = 'removeGame';
      static  const String REMOVE_GAME_DISCARD = 'removeGameDiscard';
      static  const String REMOVE_USER = 'removeUser';
      static  const String RESET_DATA = 'resetData';
}