var _ = require("lodash");
var Promise = require("bluebird");

module.exports = {
    assertEvent: function(contract, filter,callback) {
        return new Promise((resolve, reject) => {
            var event = contract[filter.event]();
            event.watch();
            event.get((error, logs) => {
                var log = _.filter(logs, filter);
                if (!_.isEmpty(log)) {
                    resolve(log);
                    callback(log);
                } else {
                    throw Error("Failed to find filtered event for " + filter.event);
                }
            });
            event.stopWatching();
        });
    },
    toAscii: function(hex) {
        if(hex =="") return hex;
        hex = hex.split("00")[0];
        var str = "";
        var i = 0, l = hex.length;
        if (hex.substring(0, 2) === '0x') {
            i = 2;
        }
        for (; i < l; i+=2) {
            var code = parseInt(hex.substr(i, 2), 16);
            str += String.fromCharCode(code);
        }
        return str;
    },
    //BaseParams{amount:,account:,dataName:}
    assertRegistrationEvent: function(event,baseParams,successRegister){
        // console.log("==================== LOG EVENT START ========================= ");
        // console.log(JSON.stringify(event,null,2));
        // console.log("==================== LOG EVENT END ========================= ");
        var result = event[0].args.success;
        var price = event[0].args.price;
        var registeringAddress = event[0].args.dataOwner;
        var dataSourceName = this.toAscii(event[0].args.dataSourceName);
        assert.equal(result,successRegister,"Registration did not succeed first time");
        assert.equal(price.toNumber(),baseParams.amount,"Prices are not equal first time");
        assert.equal(registeringAddress,baseParams.account,"Registrerer address is not equal first time");
        assert.equal(dataSourceName,baseParams.dataName, "Data source names are not equal first time");
        return true;
    },

    assertApprovalEvent: function(event,params){
      var owner = event[0].args.owner;
      var spender = event[0].args.spender;
      var amount = event[0].args.value.toNumber();
      assert.equal(params.amount,amount,"allowed amount is not corrent");
      assert.equal(params.owner,owner,"owner address is not correct");
      assert.equal(params.spender,spender,"spender address is not correct");
      return true;
    },
    // params{dataName,price,ownerAddress,fromTX}
    registerAndThen: function(marketPlaceInstance,params,callback){
        var dataSource = params.dataName;
        var price = params.price;
        var ownerAddress = params.ownerAddress;
        var marketPlace;
        new Promise((resolve,reject)=>{
            var res =  marketPlaceInstance.register(dataSource,price, ownerAddress, {from:params.fromTX});
            resolve(res);
        }).then(tx=>{
            this.assertEvent(marketPlaceInstance,{ event:"Registered"},event=>{ //,args:{dataSourceName:dataSource} },event=>{
            var result = this.assertRegistrationEvent(event,{amount:price,account:ownerAddress,dataName:dataSource},true);
            assert(result,true,"Assertion Registred event did not go correct");
            new Promise((resolve,reject)=>{
                var res = marketPlaceInstance.getOwnerFromName.call(dataSource);
                resolve(res);
              }).then((ownerAddr)=>{
                assert.equal(ownerAddr, ownerAddress, "owner address do not match.");
                callback(marketPlaceInstance,params);
              });
          });
        });
    }
}



