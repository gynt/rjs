/*
In the node.js intro tutorial (http://nodejs.org/), they show a basic tcp
server, but for some reason omit a client connecting to it.  I added an
example at the bottom.
Save the following server in example.js:
*/

var vm = require('vm');


function Console() {

  this.init = this.reset = function() {
    this.stdout = "";
    this.stderr = "";
    this.stdwarn = "";
  };

  this.init();

  this.log = function(text) {
    this.stdout += text + "\n";
  };

  this.err = function(text) {
    this.stdout += text + "\n";
  };

  this.warn = function(text) {
    this.stdout += text + "\n";
  };

  this.dump = function() {
    var result = this.stdout;
    this.reset();
    return result;
  };

}

var sandboxes = {};

function createSandbox() {
  return {
    console: new Console(),
    require: require,
    exports: exports,
    module: module
  };
}

function createContext(sandbox) {
  return vm.createContext(sandbox);
}


var net = require('net');

var clients = {};

function PacketReader() {

  this.init = function() {
    this.size = "";
    this.remaining = undefined;
    this.data = "";
    this.focus = "size";
  };

  this.init();

  this.reset = function() {
    this.init();
  };

  this.onData = function(data) {

    if(this.focus == "size") {

      var semi = data.indexOf(";");

      if(semi==-1) {
        this.size += data;
        //console.log("Waiting for more data to determine size...");
        return;
      } else {
        this.size += data.slice(0, semi);
        this.remaining = parseInt(this.size);
        //console.log("Determined size: " + this.remaining.toString());
        this.focus = "read";
        data = data.slice(semi+1);
      }

    }

    if(this.focus == "read") {
      //console.log("Reading the data...");

      this.data += data;
      this.remaining -= data.length;

      if(this.remaining === 0) {
        //console.log("Done! Returning packet");
        return this.data;
      }

      //console.log("Waiting for more data...");
    }

    return undefined;
  };
}




var server = net.createServer(function(socket) {
  console.log("A CLIENT CONNECTED");
	socket.setEncoding('UTF-8');

	socket.on('end', function() {
	  console.log("CLIENT DISCONNECTED");
	});

	socket.on('data', function(data) {
	  //console.log("RECEIVING DATA: " + data);

	  if(!clients[socket]) {
	    clients[socket] = new PacketReader();
	    sandboxes[socket] = createSandbox();
	    createContext(sandboxes[socket]);
	  }

	  var packet = clients[socket].onData(data);
	  if(packet === undefined) {
	    return;
	  }
    clients[socket].reset();

    data = packet;

	  console.log("EXECUTING STATEMENT: " + data.slice(0,30));
	  //console.log(data);

	  var error;
	  var result;
	  var output;

    var sandbox = sandboxes[socket];

	  try {
  	  result = vm.runInContext(data, sandbox);
  	  //console.log("RESULT:");
  	  //console.log(result);
  	} catch(err) {
  	  //console.log("ERROR!");
      error = err.message;
  	}

	  socket.write(JSON.stringify({
	    result:result,
	    error:error,
	    output:vm.runInContext("console.dump()", sandbox)
	  }), () => {
	    //console.log("DONE WRITING");
	  });
	});
});

server.listen(1337, '127.0.0.1', () => {
  console.log("RUNNING...");
});
