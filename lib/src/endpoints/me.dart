// Copyright (c) 2019, chances, rinukkusu. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of spotify;

class Me extends EndpointPaging {
  @override
  String get _path => 'v1/me';

  Me(SpotifyApiBase api) : super(api);

  Future<User> get() async {
    var jsonString = await _api._get(_path);
    var map = json.decode(jsonString);

    return User.fromJson(map);
  }

  Future<Player> currentlyPlaying() async {
    var jsonString = await _api._get('$_path/player/currently-playing');

    if (jsonString.isEmpty) {
      return Player();
    }

    var map = json.decode(jsonString);
    return Player.fromJson(map);
  }

  Future<Iterable<Track>> recentlyPlayed() async {
    var jsonString = await _api._get('$_path/player/recently-played');
    var map = json.decode(jsonString);

    var items = map['items'] as Iterable<dynamic>;
    return items.map((item) => Track.fromJson(item['track']));
  }

  Future<Iterable<Track>> topTracks() async {
    var jsonString = await _api._get('$_path/top/tracks');
    var map = json.decode(jsonString);

    var items = map['items'] as Iterable<dynamic>;
    return items.map((item) => Track.fromJson(item));
  }

  Future<Iterable<Device>> devices() async {
    return _api._get('$_path/player/devices').then(_parseDeviceJson);
  }

  Iterable<Device> _parseDeviceJson(String jsonString) {
    var map = json.decode(jsonString);

    var items = map['devices'] as Iterable<dynamic>;
    return items.map((item) => Device.fromJson(item));
  }
}