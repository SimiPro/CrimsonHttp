/// Handles favicon requests
/// If [pathToFavicon] is null, then it 
/// servers the favicon in the current folder, or the 
/// {current folder}/public/favicon.ico
class Favicon implements CrimsonEndpoint {

  String pathToFavicon;
  
  Favicon([String this.pathToFavicon = null]);
  
  CrimsonHttpServer server;
  
  /// If [pathToFavicon] is null, attempts to load the favicon.ico in the 
  /// current folder, or the current folder/public.
  /// If [pathToFavicon] is not null, then it will attempt to load favicon.ico
  /// from that location
  void handle(HttpRequest request, HttpResponse response, void next(var error), success()) {
    
    //check whether this request is for favicon.
    if (request.uri.endsWith("/favicon.ico") == false) {
      //if not, simply exit by calling next, and returing.
      //server.logger.debug("Request is not for favicon");
      return next(null);
    }
    
    server.logger.debug("Handling favicon");
    
    //otherwise, this request is for the favicon.
    onSuccess(List data) {
      response.setHeader("Content-Type", "image/x-icon");
      response.setHeader("Content-Length", "${data.length}");
      response.setHeader("Cache-Control", "public, max-age=86400"); //1 day
      response.outputStream.write(data);
      success();
    };
    
    on404NotFound() {
      CrimsonHttpException ex = new CrimsonHttpException(HttpStatus.NOT_FOUND, "favicon.ico not found");
      next(ex);
    };
    
    if (this.pathToFavicon == null) {
      _loadFromPath("./favicon.ico", onSuccess, fail() {
        //failure handler - try the next in line...
        _loadFromPath("./public/favicon.ico", onSuccess, on404NotFound);
      });  
    }
    else {
      //load from the custom path set.
      _loadFromPath(pathToFavicon, onSuccess, on404NotFound);
    }
    
    
  }
  
  
  _loadFromPath(String path, success(List data), fail()) {
    File file = new File(path);
    
    file.fullPath((String fullPath) {
      print(fullPath);
    });
    
    
    file.onError = (String error) {
      server.logger.debug("${path} doesn't exist: ${error}");
      fail();
    };
    
    
    server.logger.debug("trying to open file");
    
    file.exists((bool exists) {
      if (exists) {
        server.logger.debug("${path} exists, so reading");
        file.readAsBytes((List buffer) {
          server.logger.debug("successfully read ${path}");
          success(buffer);
        });
      }
      else {
        server.logger.debug("${path} doesn't exist");
        fail();
      }
    });
    
    
   
  }
  
  
  final String NAME = "FAVICON";
  
}
