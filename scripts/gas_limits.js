const utils = require("./utils");
const config = require("./config_web3");
const web3 = config.web3;
const EnigmaContract = config.EnigmaContract;
const MarketPlaceContract = config.MarketPlaceContract;

async function testLimitProviders(){
    let regNum =50000;
    let enigma = await EnigmaContract.deployed();
    let owner = web3.eth.accounts[0];
    let marketPlace = await MarketPlaceContract.deployed();
    for(var i=0;i < regNum; i++){
      await marketPlace.register((i+1+"Name"),1,owner,{from:owner,gas:6000000});
	  if(i % 10 == 0){
      	console.log(i+1);
      }
      let providers =0;
      try{
      	providers = await marketPlace.getAllProviders.call({gas:6000000});//{from:owner,gas:6000000});
      	console.log("return = " + providers.length);
      }catch(e){
      	console.log("Error! MAX = " + (i+1) + " (returned " + value + " )");
      	try{
      		await marketPlace.register("Isan", 1 , owner, {from:owner,gas:5000000});
      		console.log("managed to reg !! ");
      	}catch(e){
      		console.log("after fail = failed ! ");
      	}
      }
    }
}

testLimitProviders();