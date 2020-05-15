// Copyright (c) 2017, 2020 rinukkusu, hayribakici. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:spotify/spotify.dart';

void main() async {
  var keyJson = await File('example/.apikeys').readAsString();
  var keyMap = json.decode(keyJson);

  var credentials = SpotifyApiCredentials(keyMap['id'], keyMap['secret']);
  var spotify = SpotifyApi(credentials);

  print('Artists:');
  var artists = await spotify.artists.list(['0OdUWJ0sBjDrqHygGUXeCF']);
  artists.forEach((x) => print(x.name));

  print('\nAlbum:');
  var album = await spotify.albums.get('2Hog1V8mdTWKhCYqI5paph');
  print(album.name);

  print('\nAlbum Tracks:');
  var tracks = await spotify.albums.getTracks(album.id).all();
  tracks.forEach((track) {
    print(track.name);
  });

  print('\nFeatured Playlist:');
  var featuredPlaylists = await spotify.playlists.featured.all();
  featuredPlaylists.forEach((playlist) {
    print(playlist.name);
  });

  print("\nSearching for \'Metallica\':");
  var search = await spotify.search
      .get('metallica')
      .first(2)
      .catchError((err) => print((err as SpotifyException).message));
  if (search == null) {
    return;
  }
  search.playlists.items.forEach((playlist){
    print('Playlist | ${playlist.name}');
  });
  search.artists.items.forEach((artist){
    print('Artist | ${artist.name}');
  });
  search.tracks.items.forEach((track){
    print('Track | ${track.name}');
  });
  search.albums.items.forEach((album){
    print('Album | ${album.name}');
  });
  var relatedArtists =
      await spotify.artists.relatedArtists('0OdUWJ0sBjDrqHygGUXeCF');
  print('\nRelated Artists: ${relatedArtists.length}');

  credentials = await spotify.getCredentials();
  print('\nCredentials:');
  print('Client Id: ${credentials.clientId}');
  print('Access Token: ${credentials.accessToken}');
  print('Credentials Expired: ${credentials.isExpired}');
}
