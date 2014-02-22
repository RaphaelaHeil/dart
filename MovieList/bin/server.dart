// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartiverse_search;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
//import 'dart:uri';
//import 'dart:json';
import 'package:http_server/http_server.dart' as http_server;
import 'package:route/server.dart' show Router;
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:path/path.dart';
//import 'package:jsonp/jsonp.dart' as jsonp;
//import 'package:MovieList/search_engine.dart';


final Logger log = new Logger('DartiverseSearch');


// List of search-engines used.
//final List<SearchEngine> searchEngines = [
//  new StackOverflowSearchEngine(),
//  new GithubSearchEngine()
//];


/**
 * Handle an established [WebSocket] connection.
 *
 * The WebSocket can send search requests as JSON-formatted messages,
 * which will be responded to with a series of results and finally a done
 * message.
 */
void handleWebSocket(WebSocket webSocket) {
  log.info('New WebSocket connection');
  final searchPath = '../example_folder';
  final searchTerms = '*.mp4';
  // Listen for incoming data. We expect the data to be a JSON-encoded String.
  webSocket
    .map((string) => JSON.decode(string))
    .listen((json) {
      // The JSON object should contains a 'request' entry.
      var request = json['request'];
      switch (request) {
        case 'search':
         var response = {
            'response': 'searchResult',
            'source': 'source',
            'title': 'title',
            'link': 'link'
          };
         //webSocket.add(JSON.encode(response));
         
  
         
         
         FileSystemEntity.isDirectory(searchPath).then((isDir) {
           if (isDir) {
             final Directory startingDir = new Directory(searchPath);
             startingDir.list(recursive: true, followLinks: true)
               .listen((entity) {
                 print(entity);
                 if (entity is File) {
                   String filename = basenameWithoutExtension(entity.path).replaceAll(new RegExp(r'[_\W]'), ' ');
                   loadMovieData(filename)
                       .then((data){
                         var meta = data['movies'][0];
                         print(meta);
                         webSocket.add(JSON.encode({//meta));
                           'response': 'searchResult',
                           'thumbnail': meta['posters']['profile'],
                           'year': meta['year'],
                           'title': meta['title'],
                          'description':meta['critics_consensus']
                         }));
                       });
                   
                  
                 }
               });
           }
         });
          // Initiate a new search.
//          var input = json['input'];
//          log.info("Searching for '$input'");
//          int done = 0;
//          for (var engine in searchEngines) {
//            engine.search(input)
//              .listen((result) {
//                // The search-engine found a result. Send it to the client.
//                log.info("Got result from ${engine.name} for '$input': "
//                         "${result.title}");
//                var response = {
//                  'response': 'searchResult',
//                  'source': engine.name,
//                  'title': result.title,
//                  'link': result.link
//                };
//                webSocket.add(JSON.encode(response));
//              }, onError: (error) {
//                log.warning("Error while searching on ${engine.name}: $error");
//              }, onDone: () {
//                done++;
//                if (done == searchEngines.length) {
//                  // All search-engines are done. Send done message to the
//                  // client.
//                  webSocket.add(JSON.encode({ 'response': 'searchDone' }));
//                }
//              });
//          }
          break;

        default:
          log.warning("Invalid request: '$request'");
      }
    }, onError: (error) {
      log.warning('Bad WebSocket request');
    });
}

void list_movies () {
  final searchPath = '../example_folder';
  final searchTerms = '*.mp4';
  
  
  
  FileSystemEntity.isDirectory(searchPath).then((isDir) {
    if (isDir) {
      final Directory startingDir = new Directory(searchPath);
      startingDir.list(recursive: true, followLinks: true)
        .listen((entity) {
          //print(entity);
          String filename = basenameWithoutExtension(entity.path);
          if (entity is File) {
            print(filename.replaceAll(new RegExp(r'[_\W]'), ' '));
          }
        });
    }
//    else {
//      searchFile(new File(searchPath), searchTerms);
//    }
  });
  
  
}

Future<String> getAsString(Uri uri) {
  
  HttpClient client = new HttpClient();
  return client.getUrl(uri)
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse resp) => resp.transform(new Utf8Decoder()).fold(new StringBuffer(), (buf, next) {
        buf.write(next); return buf;
      }))
      .then((StringBuffer buf) => buf.toString());
}

Future loadMovieData(String title){
  int limit = 2;
  int page = 1;
  String apikey = '5e3cg6kag4fsezhu9nj5jzyq';
  //String title = 'ice age';
  String url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?page_limit=$limit&page=$page&apikey=$apikey&q=$title";
  
  return getAsString(Uri.parse(url.replaceAll(new RegExp(r'\s+'),'+')))
      .then((String data){
        return JSON.decode(data);
      });
}
void main() {
  //list_movies();
  int limit = 2;
  int page = 1;
  String apikey = '5e3cg6kag4fsezhu9nj5jzyq';
  String title = 'ice age';
  String url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?page_limit=$limit&page=$page&apikey=$apikey&q=$title";
  //jsonp.fetch(uri: url)
  //  .then((proxy) {
  //    print(proxy.data);
  //  });
  //print(url.replaceAll(new RegExp(r'\s+'),'+'));
  //print(Uri.parse(url.replaceAll(new RegExp(r'\s+'),'+')));
  //getAsString(Uri.parse(url.replaceAll(new RegExp(r'\s+'),'+')))
  //
  loadMovieData('ice age')
  .then((data){
    print (data);
  });
  //catchError((e){
  //  print(e);
  //});
  
//  HttpClient client = new HttpClient();
//  client.getUrl(Uri.parse(url))
//    .then((HttpClientRequest request) {
//      // Prepare the request then call close on it to send it.
//      return request.close();
//    })
//    .then((HttpClientResponse response) {
//     // Process the response.
//      print(response);
//    });
  // Set up logger.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  var buildPath = Platform.script.resolve('../build/').toFilePath();
  if (!new Directory(buildPath).existsSync()) {
    log.severe("The 'build/' directory was not found. Please run 'pub build'.");
    return;
  }

  int port = 9223;  // TODO use args from command line to set this

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
    log.info("Search server is running on "
             "'http://${server.address.address}:$port/'");
    var router = new Router(server);

    // The client will connect using a WebSocket. Upgrade requests to '/ws' and
    // forward them to 'handleWebSocket'.
    router.serve('/ws')
      .transform(new WebSocketTransformer())
      .listen(handleWebSocket);

    // Set up default handler. This will serve files from our 'build' directory.
    var virDir = new http_server.VirtualDirectory(buildPath);
    // Disable jail root, as packages are local symlinks.
    virDir.jailRoot = false;
    virDir.allowDirectoryListing = true;
    virDir.directoryHandler = (dir, request) {
      // Redirect directory requests to index.html files.
      //var indexUri = new Uri.file(dir.path).resolve('index.html');
      var indexUri = new Uri.file(dir.path).resolve('movielist.html');
      virDir.serveFile(new File(indexUri.toFilePath()), request);
    };

    // Add an error page handler.
    virDir.errorPageHandler = (HttpRequest request) {
      log.warning("Resource not found: ${request.uri.path}");
      request.response.statusCode = HttpStatus.NOT_FOUND;
      request.response.close();
    };

    // Serve everything not routed elsewhere through the virtual directory.
    virDir.serve(router.defaultStream);

    // Special handling of client.dart. Running 'pub build' generates
    // JavaScript files but does not copy the Dart files, which are
    // needed for the Dartium browser.
    router.serve("/movielist.dart").listen((request) {
      Uri clientScript = Platform.script.resolve("../web/movielist.dart");
      virDir.serveFile(new File(clientScript.toFilePath()), request);
    });
    
    router.serve("/client.dart").listen((request) {
      Uri clientScript = Platform.script.resolve("../web/client.dart");
      virDir.serveFile(new File(clientScript.toFilePath()), request);
    });
  });
}
