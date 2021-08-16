String capitalize(String input){
    return input[0].toUpperCase()+input.substring(1);
  }

String httpHost(String route){
  String httpUrl = "http://10.0.2.2:8080";
  if (route.startsWith('/'))
    return '$httpUrl$route';

  return '$httpUrl/$route';
}

// Map<String, dynamic>
dynamic requestToken = {};