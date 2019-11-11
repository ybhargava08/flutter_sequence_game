import 'dart:async';

class CardBloc {
  static CardBloc _cardBloc;

  factory CardBloc() => _cardBloc ??= CardBloc._();

  CardBloc._();

  static const String TEXT_CARD = 'Text Card';
  static const String PHOTO_CARD = 'Photo Card';

  String cardType = TEXT_CARD;

  StreamController<String> _cardTypeController;

  String getCardType() {
    return cardType;
  }

  openController() {
      _cardTypeController = StreamController.broadcast();
  }

  StreamController<String> getController() {
    return _cardTypeController;
  }

  addToController(bool isOn) {
    if (!_isControllerClosed()) {
      cardType = isOn ? PHOTO_CARD : TEXT_CARD;
      _cardTypeController.sink.add(cardType);
    }
  }

  _isControllerClosed() {
    return _cardTypeController == null || _cardTypeController.isClosed;
  }

  closeController() {
    if (!_isControllerClosed()) {
      _cardTypeController.close();
    }
  }
}
