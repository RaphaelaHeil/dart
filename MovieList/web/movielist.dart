import 'dart:html';
import 'dart:convert';
import 'client.dart';


import 'dart:async' show Future;

InputElement title;
InputElement filter;
TableSectionElement returnlist;
List<Movie> movies;

void main() {
 title = querySelector('#title')
      ..onInput.listen(request);
 
 
  filter = querySelector('#filter')
      ..onInput.listen(request);
  
  
  returnlist = querySelector('#movieTable tbody');
  
  movies = new List<Movie>();
  
  readyNames(movies).then((_){
    updateTable();
    
  });
  var client = new Client();
}

void test(Event e){
  print((e.target as InputElement).value);
  
}

void updateTable(){

    returnlist.children.clear();  
  
    for(Movie m in movies){
      TableCellElement t = new TableCellElement();
      TableCellElement y = new TableCellElement();
           
      t.text = m.title;
      y.text = m.year;
           
      TableRowElement r = new TableRowElement();
      r.children.add(t);
      r.children.add(y);
      
      r.onClick.listen(showDetails);
           
      returnlist.children.add(r);
    }  
}

void showDetails(Event e){
  
  
}

void request(Event e){
  String _t = title.value;
  String _f = filter.value;
  
  
  if(_t.length > 3){
    //send request to server with title & filter values
    // receive and parse request
    print(_t +"  "+ _f);
  }
  
}

Future readyNames(List<Movie> mo){
  var path = 'dummy.json';
  return HttpRequest.getString(path).then(_parseMovies);
}

void _parseMovies(String jsonString){

    List movieMap = JSON.decode(jsonString)["movies"];

    for(int i=0; i<movieMap.length; i++){
      Movie m = new Movie.fromJSON(movieMap[i]);
      m.printM();
      movies.add(m);
    }   
  }



class Movie{
  
  String jsonString = HttpRequest.getString("dummy.json").toString();
  
  String title;
  String year;
  String description;
  String thumbnail;//... other stuff/detail view ?
  
  
  Movie({String t, String y, String d}){
    title = t; year=y; description = d;
  }
  
  Movie.fromJSON(Map movie){
    title = movie["title"];
    year = movie["year"];
    description = movie["description"];
  }
  
  void printM(){
    print(title + year + description);
  }
  
}

