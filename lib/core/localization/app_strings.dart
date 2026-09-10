class AppStrings {
  static const Map<String, Map<String, String>> data = {
    'ru': {
      'play': 'Играть',
      'profile': 'Профиль',
      'settings': 'Настройки',
      'new_game': 'Новая игра',
      'history': 'История ходов',
      'status': 'Статус',
      'you': 'Ты',
      'victory': 'Победа',
      'defeat': 'Поражение',
      'draw': 'Ничья',
      'moves': 'Ходов',
      'time': 'Время',
      'player': 'Игрок',
      'bot': 'Роберт Полсон',
    },

    'en': {
      'play': 'Play',
      'profile': 'Profile',
      'settings': 'Settings',
      'new_game': 'New Game',
      'history': 'Move History',
      'status': 'Status',
      'you': 'You',
      'victory': 'Victory',
      'defeat': 'Defeat',
      'draw': 'Draw',
      'moves': 'Moves',
      'time': 'Time',
      'player': 'Player',
      'bot': 'Robert Paulson',
    },

    'ky': {
      'play': 'Ойноо',
      'profile': 'Профиль',
      'settings': 'Жөндөөлөр',
      'new_game': 'Жаңы оюн',
      'history': 'Жүрүш тарыхы',
      'status': 'Абалы',
      'you': 'Сен',
      'victory': 'Жеңиш',
      'defeat': 'Жеңилүү',
      'draw': 'Тең чыгуу',
      'moves': 'Жүрүштөр',
      'time': 'Убакыт',
      'player': 'Оюнчу',
      'bot': 'Роберт Полсон',
    },
  };

  static String text(String key, String lang) {
    return data[lang]?[key] ?? data['ru']![key] ?? key;
  }
}