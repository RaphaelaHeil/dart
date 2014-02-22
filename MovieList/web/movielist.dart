import 'dart:html';
import 'dart:convert';
import 'client.dart';

void main() {
  querySelector("#sample_text_id")
    ..text = "Click me!"
    ..onClick.listen(reverseText);
  
  var client = new Client();
  
  //client.getMovies();
  
  //var request = {
  // 'request': 'search',
  // 'input': 'title'
  //};
  //client.webSocket.send(JSON.encode(request));
}

void reverseText(MouseEvent event) {
  var text = querySelector("#sample_text_id").text;
  var buffer = new StringBuffer();
  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
  }
  querySelector("#sample_text_id").text = buffer.toString();
}
