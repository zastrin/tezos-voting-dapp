var contractAddress;
var keys;
var account;

function loadData() {
  contractAddress = "KT1Wv8Ted4b6raZDMoepkCPT8MkNFxyT2Ddo";
  eztz.node.setProvider("http://localhost:8732");
  var mnemonic = "utility orbit end win roast sail warrior toast cross banana news gossip swap theme piece"
  keys = eztz.crypto.generateKeys(mnemonic, "password");
  account = keys.pkh;
  console.log(account);
  
  eztz.rpc.getBalance(account).then(function(res) {
    $("#balance").html(res);
    $("#account").html(account);
  });

  eztz.contract.watch(contractAddress, 2, function(s){
    console.log("New storage", s);
    var candidateList = s.args[0];
    for (var i=1; i<= candidateList.length; i++) {
      $("#candidate-" + i).html(candidateList[i-1].args[1].int); 
    }
    $("#msg").html("");
  });
}

function voteForCandidate() {
  var candidate = $("#candidate").val();
  eztz.contract.send(contractAddress, account, keys, 0, '\"' + candidate + '\"', "0100000", 100000, 60000).then(function(res){
    console.log(res); // Operation result
    $("#msg").html("Please wait for the transaction to complete");
  }).catch(function(e){
    console.log(e);
    $("#msg").html("Error: " + e.error + " - " + e.errors[1].with.args[0].string);
  });
  
}

