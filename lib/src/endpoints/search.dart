// Copyright (c) 2018 hayribakici, ebarnsli. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of spotify;

class Search extends EndpointPaging {
  @override
  String get _path => 'v1/search';

  Search(SpotifyApiBase api) : super(api);

  SearchPages get(String searchQuery,
      [Iterable<SearchType> types = SearchType.all]) {
    var type = types.map((type) => type.key).join(',');
    return SearchPages(_api, '$_path?q=$searchQuery&type=${type}', {
      'playlists': (json) => PlaylistSimple.fromJson(json),
      'albums': (json) => AlbumSimple.fromJson(json),
      'artists': (json) => Artist.fromJson(json),
      'tracks': (json) => Track.fromJson(json)
    });
  }
}

class SearchType {
  final String _key;
  static const _album = 'album';
  static const _artist = 'artist';
  static const _playlist = 'playlist';
  static const _track = 'track';

  const SearchType(this._key);
  String get key => _key;

  static const album = SearchType(_album);
  static const artist = SearchType(_artist);
  static const playlist = SearchType(_playlist);
  static const track = SearchType(_track);
  static const all = [
    SearchType.album,
    SearchType.artist,
    SearchType.playlist,
    SearchType.track
  ];
}

class SearchResult {
  Page<Artist> artists;
  Page<Track> tracks;
  Page<AlbumSimple> albums;
  Page<PlaylistSimple> playlists;

  SearchResult([this.artists, this.tracks, this.playlists, this.albums]);

  int get length => artists?.items?.length ??
      tracks?.items?.length ??
      playlists?.items?.length ??
      albums?.items?.length;
}

class SearchPages extends _Pages<SearchResult> {
  final Map<String, ParserFunction<Object>> _pageMappers;

  SearchPages(SpotifyApiBase api, String path, this._pageMappers,
      [String pageKey, ParserFunction<Object> pageContainerParser])
      : super(api, path, pageKey, pageContainerParser);

  @override
  Future<SearchResult> getPage(int limit, int offset) async {
    var pathDelimiter = _path.contains('?') ? '&' : '?';
    var path = '$_path${pathDelimiter}limit=$limit&offset=$offset';
    return _api._get(path).then(_parseBundledPage);
  }

  SearchResult _parseBundledPage(String jsonString) {
    var map = json.decode(jsonString);
    final searchResult = SearchResult();
    _pageMappers.forEach((key, value) {
      if (map[key] != null) {
        Page createPage<T>(){
          final paging = Paging<T>.fromJson(map[key]);
          if (_pageContainerParser == null) {
            return Page<T>(paging, value);
          } else {
            var container = _pageContainerParser(map[key]);
            return Page<T>(paging, value, container);
          }
        }
        switch(key.substring(0, key.length - 1)){
          case SearchType._track:
            searchResult.tracks = createPage<Track>();
            break;
          case SearchType._artist:
            searchResult.artists = createPage<Artist>();
            break;
          case SearchType._album:
            searchResult.albums = createPage<AlbumSimple>();
            break;
          case SearchType._playlist:
            searchResult.playlists = createPage<PlaylistSimple>();
            break;
        }
      }
    });
    return searchResult;
  }
}